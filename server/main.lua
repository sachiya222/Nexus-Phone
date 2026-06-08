-- server/main.lua
local exports = exports

-- 1. Fetch Core Player Profile (Name, Bank, Job, Phone Number)
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

-- 2. Powerbank Battery Item
exports.qbx_core:CreateUseableItem('powerbank', function(source, item)
    local src = source
    exports.ox_inventory:RemoveItem(src, 'powerbank', 1)
    TriggerClientEvent('nexus_phone:client:ChargeBattery', src, 50)
end)

-- 3. Live Bank Transfer Logic
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

-- 4. Database Fetch: NexTweets (New!)
lib.callback.register('nexus_phone:server:GetTweets', function(source)
    -- This asks the database to grab the 50 most recent tweets
    local tweets = MySQL.query.await('SELECT * FROM nexus_phone_tweets ORDER BY time DESC LIMIT 50', {})
    return tweets
end)

-- 5. Database Fetch: Marketplace (New!)
lib.callback.register('nexus_phone:server:GetMarketplace', function(source)
    local items = MySQL.query.await('SELECT * FROM nexus_phone_market ORDER BY time DESC LIMIT 50', {})
    return items
end)
