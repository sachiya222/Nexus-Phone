-- client/main.lua
local phoneOpen = false
local batteryLevel = 100
local isPhoneDead = false

-- Battery Drain Background Thread
CreateThread(function()
    while true do
        Wait(120000) -- Drains 1% every 2 minutes (adjust as needed)
        if batteryLevel > 0 then
            batteryLevel = batteryLevel - 1
            -- Tell the UI to update the battery bar
            SendNUIMessage({ type = "updateBattery", battery = batteryLevel })
            
            if batteryLevel <= 0 then
                isPhoneDead = true
                -- Force close the phone if it dies while they are using it
                if phoneOpen then
                    ExecuteCommand('nexus_closephone')
                end
            end
        end
    end
end)

-- Event triggered when player uses a Power Bank
RegisterNetEvent('nexus_phone:client:ChargeBattery', function(amount)
    batteryLevel = batteryLevel + amount
    if batteryLevel > 100 then batteryLevel = 100 end
    isPhoneDead = false
    
    -- Update UI and show a Qbox notification
    SendNUIMessage({ type = "updateBattery", battery = batteryLevel })
    exports.qbx_core:Notify("Phone charged to " .. batteryLevel .. "%", "success")
end)

-- Open Phone Command
RegisterCommand('nexus_openphone', function()
    if not phoneOpen and not isPhoneDead then
        lib.callback('nexus_phone:server:GetPlayerProfile', false, function(playerData)
            if playerData then
                phoneOpen = true
                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = "openPhone",
                    player = playerData,
                    battery = batteryLevel
                })
            end
        end)
    elseif isPhoneDead then
        exports.qbx_core:Notify("Your phone is dead. Buy a Power Bank.", "error")
    end
end, false)

RegisterKeyMapping('nexus_openphone', 'Open Nexus Phone', 'keyboard', 'M')

-- Internal command to cleanly close phone
RegisterCommand('nexus_closephone', function()
    phoneOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "closePhone" })
end, false)

RegisterNUICallback('closePhone', function(data, cb)
    ExecuteCommand('nexus_closephone')
    cb('ok')
end)
