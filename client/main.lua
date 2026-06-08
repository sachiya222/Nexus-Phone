-- client/main.lua
local phoneOpen = false

RegisterCommand('nexus_openphone', function()
    if not phoneOpen then
        -- Fetch player data from our new server script
        lib.callback('nexus_phone:server:GetPlayerProfile', false, function(playerData)
            if playerData then
                phoneOpen = true
                SetNuiFocus(true, true)
                
                -- Send the data to our visual screen
                SendNUIMessage({
                    type = "openPhone",
                    player = playerData
                })
            end
        end)
    end
end, false)

RegisterKeyMapping('nexus_openphone', 'Open Nexus Phone', 'keyboard', 'M')

RegisterNUICallback('closePhone', function(data, cb)
    phoneOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "closePhone" })
    cb('ok')
end)
