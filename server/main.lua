-- server/main.lua
local exports = exports

-- ==========================================
-- 1. DATABASE AUTO-BUILDER (Runs on startup)
-- ==========================================
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    print('^5[Nexus Phone]^0 Verifying Database Tables...')
    
    local sqlCommands = [[
        CREATE TABLE IF NOT EXISTS `nexus_phone_contacts` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `citizenid` varchar(50) NOT NULL,
          `name` varchar(50) NOT NULL,
          `number` varchar(50) NOT NULL,
          `iban` varchar(50) DEFAULT NULL,
          PRIMARY KEY (`id`),
          KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `nexus_phone_messages` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `sender` varchar(50) NOT NULL,
          `receiver` varchar(50) NOT NULL,
          `message` text NOT NULL,
          `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          `is_read` int(11) NOT NULL DEFAULT '0',
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `nexus_phone_tweets` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `citizenid` varchar(50) NOT NULL,
          `firstName` varchar(50) NOT NULL,
          `lastName` varchar(50) NOT NULL,
          `handle` varchar(50) NOT NULL,
          `message` varchar(280) NOT NULL,
          `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          `likes` int(11) NOT NULL DEFAULT '0',
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `nexus_phone_grams` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `citizenid` varchar(50) NOT NULL,
          `username` varchar(50) NOT NULL,
          `image_url` varchar(255) NOT NULL,
          `caption` varchar(255) DEFAULT NULL,
          `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          `likes` int(11) NOT NULL DEFAULT '0',
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `nexus_phone_market` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `citizenid` varchar(50) NOT NULL,
          `seller_name` varchar(50) NOT NULL,
          `seller_number` varchar(50) NOT NULL,
          `item_name` varchar(50) NOT NULL,
          `price` int(11) NOT NULL,
          `description` varchar(255) DEFAULT NULL,
          `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        CREATE TABLE IF NOT EXISTS `nexus_phone_settings` (
          `citizenid` varchar(50) NOT NULL,
          `wallpaper` varchar(255) DEFAULT 'default',
          `streamer_mode` int(11) NOT NULL DEFAULT '0',
          PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]]

    -- Execute the creation
    MySQL.query(sqlCommands, {}, function()
        print('^2[Nexus Phone]^0 Database Tables Built & Ready!')
    end)
end)


-- ==========================================
-- 2. CORE SERVER LOGIC
-- ==========================================

-- Fetch Core Player Profile
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

-- Powerbank Battery Item
exports.qbx_core:CreateUseableItem('powerbank', function(source, item)
    local src = source
    exports.ox_inventory:RemoveItem(src, 'powerbank', 1)
    TriggerClientEvent('nexus_phone:client:ChargeBattery', src, 50)
end)

-- Live Bank Transfer Logic
RegisterNetEvent('nexus_phone:server:TransferMoney', function(targetId, amount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local Target = exports.qbx_core:GetPlayer(tonumber(targetId))
    amount = tonumber(amount)

    if not Player then return end
    if not Target or tonumber(src) == tonumber(targetId) then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Invalid account ID.'})
        return
    end

    if amount and amount > 0 and Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount, "Nexus Phone Transfer")
        Target.Functions.AddMoney('bank', amount, "Nexus Phone Transfer")
        
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Transferred $'..amount..' to Account '..targetId})
        TriggerClientEvent('ox_lib:notify', Target.PlayerData.source, {type = 'inform', description = 'Received $'..amount..' transfer.'})
        
        TriggerClientEvent('nexus_phone:client:UpdateBankUI', src, Player.PlayerData.money.bank)
        TriggerClientEvent('nexus_phone:client:UpdateBankUI', Target.PlayerData.source, Target.PlayerData.money.bank)
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Insufficient funds.'})
    end
end)

-- Database Fetch: NexTweets
lib.callback.register('nexus_phone:server:GetTweets', function(source)
    local tweets = MySQL.query.await('SELECT * FROM nexus_phone_tweets ORDER BY time DESC LIMIT 50', {})
    return tweets
end)

-- Database Fetch: Marketplace
lib.callback.register('nexus_phone:server:GetMarketplace', function(source)
    local items = MySQL.query.await('SELECT * FROM nexus_phone_market ORDER BY time DESC LIMIT 50', {})
    return items
end)
