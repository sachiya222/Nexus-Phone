-- server/main.lua
local exports = exports

-- Auto-Build Database (Will do nothing if tables already exist)
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    local sqlCommands = [[
        CREATE TABLE IF NOT EXISTS `nexus_phone_contacts` (`id` int(11) NOT NULL AUTO_INCREMENT, `citizenid` varchar(50) NOT NULL, `name` varchar(50) NOT NULL, `number` varchar(50) NOT NULL, `iban` varchar(50) DEFAULT NULL, PRIMARY KEY (`id`), KEY `citizenid` (`citizenid`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        CREATE TABLE IF NOT EXISTS `nexus_phone_messages` (`id` int(11) NOT NULL AUTO_INCREMENT, `sender` varchar(50) NOT NULL, `receiver` varchar(50) NOT NULL, `message` text NOT NULL, `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, `is_read` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        CREATE TABLE IF NOT EXISTS `nexus_phone_tweets` (`id` int(11) NOT NULL AUTO_INCREMENT, `citizenid` varchar(50) NOT NULL, `firstName` varchar(50) NOT NULL, `lastName` varchar(50) NOT NULL, `handle` varchar(50) NOT NULL, `message` varchar(280) NOT NULL, `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, `likes` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        CREATE TABLE IF NOT EXISTS `nexus_phone_grams` (`id` int(11) NOT NULL AUTO_INCREMENT, `citizenid` varchar(50) NOT NULL, `username` varchar(50) NOT NULL, `image_url` varchar(255) NOT NULL, `caption` varchar(255) DEFAULT NULL, `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, `likes` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        CREATE TABLE IF NOT EXISTS `nexus_phone_market` (`id` int(11) NOT NULL AUTO_INCREMENT, `citizenid` varchar(50) NOT NULL, `seller_name` varchar(50) NOT NULL, `seller_number` varchar(50) NOT NULL, `item_name` varchar(50) NOT NULL, `price` int(11) NOT NULL, `description` varchar(255) DEFAULT NULL, `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        CREATE TABLE IF NOT EXISTS `nexus_phone_settings` (`citizenid` varchar(50) NOT NULL, `wallpaper` varchar(255) DEFAULT 'default', `streamer_mode` int(11) NOT NULL DEFAULT '0', PRIMARY KEY (`citizenid`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]]
    MySQL.query(sqlCommands, {}, function() end)
end)

-- Fetch Profile
lib.callback.register('nexus_phone:server:GetPlayerProfile', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if player then
        return {
            citizenid = player.PlayerData.citizenid,
            firstname = player.PlayerData.charinfo.firstname,
            lastname = player.PlayerData.charinfo.lastname,
            bank = player.PlayerData.money.bank,
            job = player.PlayerData.job.label,
            phoneNumber = player.PlayerData.charinfo.phone
        }
    end
    return nil
end)

exports.qbx_core:CreateUseableItem('powerbank', function(source, item)
    local src = source
    exports.ox_inventory:RemoveItem(src, 'powerbank', 1)
    TriggerClientEvent('nexus_phone:client:ChargeBattery', src, 50)
end)

RegisterNetEvent('nexus_phone:server:TransferMoney', function(targetId, amount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local Target = exports.qbx_core:GetPlayer(tonumber(targetId))
    amount = tonumber(amount)

    if not Player then return end
    if not Target or tonumber(src) == tonumber(targetId) then TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Invalid account ID.'}) return end
    if amount and amount > 0 and Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount, "Nexus Phone Transfer")
        Target.Functions.AddMoney('bank', amount, "Nexus Phone Transfer")
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Transferred $'..amount})
        TriggerClientEvent('ox_lib:notify', Target.PlayerData.source, {type = 'inform', description = 'Received $'..amount})
        TriggerClientEvent('nexus_phone:client:UpdateBankUI', src, Player.PlayerData.money.bank)
        TriggerClientEvent('nexus_phone:client:UpdateBankUI', Target.PlayerData.source, Target.PlayerData.money.bank)
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Insufficient funds.'})
    end
end)

-- GET Requests (Reading from DB)
lib.callback.register('nexus_phone:server:GetTweets', function(source)
    return MySQL.query.await('SELECT * FROM nexus_phone_tweets ORDER BY time DESC LIMIT 50', {})
end)

lib.callback.register('nexus_phone:server:GetMarketplace', function(source)
    return MySQL.query.await('SELECT * FROM nexus_phone_market ORDER BY time DESC LIMIT 50', {})
end)

-- POST Requests (Writing to DB)
RegisterNetEvent('nexus_phone:server:PostTweet', function(message)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player or not message then return end

    local handle = Player.PlayerData.charinfo.firstname .. "_" .. Player.PlayerData.charinfo.lastname
    
    MySQL.insert('INSERT INTO nexus_phone_tweets (citizenid, firstName, lastName, handle, message) VALUES (?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        handle,
        message
    })
end)

RegisterNetEvent('nexus_phone:server:PostMarket', function(title, desc, price)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player or not title or not price then return end

    MySQL.insert('INSERT INTO nexus_phone_market (citizenid, seller_name, seller_number, item_name, price, description) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid,
        Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
        Player.PlayerData.charinfo.phone,
        title,
        tonumber(price),
        desc
    })
end)
