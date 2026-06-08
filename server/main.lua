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
