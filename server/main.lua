-- server/main.lua
local exports = exports

-- Register a secure callback to fetch Qbox data
lib.callback.register('nexus_phone:server:GetPlayerProfile', function(source)
    -- Grab the player using Qbox's core export
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
-- server/main.lua (Add to bottom)

-- Register the Power Bank as a usable item in ox_inventory
exports.qbx_core:CreateUseableItem('powerbank', function(source, item)
    local src = source
    
    -- Remove 1 power bank from their inventory
    exports.ox_inventory:RemoveItem(src, 'powerbank', 1)
    
    -- Send a signal to the player's game to charge the phone by 50%
    TriggerClientEvent('nexus_phone:client:ChargeBattery', src, 50)
end)
