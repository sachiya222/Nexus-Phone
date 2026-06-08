local exports = exports

lib.callback.register('nexus_phone:server:GetPlayerProfile', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if player then
        return {
            firstname = player.PlayerData.charinfo.firstname,
            lastname = player.PlayerData.charinfo.lastname,
            bank = player.PlayerData.money.bank,
            job = player.PlayerData.job.label
        }
    end
    return nil
end)

exports.qbx_core:CreateUseableItem('powerbank', function(source, item)
    local src = source
    exports.ox_inventory:RemoveItem(src, 'powerbank', 1)
    TriggerClientEvent('nexus_phone:client:ChargeBattery', src, 50)
end)

-- Bank Transfer Logic
RegisterNetEvent('nexus_phone:server:TransferMoney', function(targetId, amount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local Target = exports.qbx_core:GetPlayer(tonumber(targetId))
    amount = tonumber(amount)

    -- Security checks
    if not Player then return end
    if not Target or tonumber(src) == tonumber(targetId) then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Invalid account ID.'})
        return
    end

    -- Process Money
    if amount and amount > 0 and Player.PlayerData.money.bank >= amount then
        -- Remove from sender, add to receiver
        Player.Functions.RemoveMoney('bank', amount, "Nexus Phone Transfer")
        Target.Functions.AddMoney('bank', amount, "Nexus Phone Transfer")
        
        -- Notifications
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Transferred $'..amount..' to Account '..targetId})
        TriggerClientEvent('ox_lib:notify', Target.PlayerData.source, {type = 'inform', description = 'Received $'..amount..' transfer.'})
        
        -- Update Sender UI
        TriggerClientEvent('nexus_phone:client:UpdateBankUI', src, Player.PlayerData.money.bank)
        -- Update Receiver UI (if their phone happens to be open)
        TriggerClientEvent('nexus_phone:client:UpdateBankUI', Target.PlayerData.source, Target.PlayerData.money.bank)
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Insufficient funds.'})
    end
end)
