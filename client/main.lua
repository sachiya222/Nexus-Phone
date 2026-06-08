local phoneOpen = false
local batteryLevel = 100
local isPhoneDead = false

CreateThread(function()
    while true do
        Wait(120000) 
        if batteryLevel > 0 then
            batteryLevel = batteryLevel - 1
            SendNUIMessage({ type = "updateBattery", battery = batteryLevel })
            if batteryLevel <= 0 then
                isPhoneDead = true
                if phoneOpen then ExecuteCommand('nexus_closephone') end
            end
        end
    end
end)

RegisterNetEvent('nexus_phone:client:ChargeBattery', function(amount)
    batteryLevel = batteryLevel + amount
    if batteryLevel > 100 then batteryLevel = 100 end
    isPhoneDead = false
    SendNUIMessage({ type = "updateBattery", battery = batteryLevel })
    exports.qbx_core:Notify("Phone charged to " .. batteryLevel .. "%", "success")
end)

RegisterNetEvent('nexus_phone:client:UpdateBankUI', function(newBalance)
    SendNUIMessage({ type = "updateBank", balance = newBalance })
end)

RegisterCommand('nexus_openphone', function()
    if not phoneOpen and not isPhoneDead then
        lib.callback('nexus_phone:server:GetPlayerProfile', false, function(playerData)
            if playerData then
                phoneOpen = true
                SetNuiFocus(true, true)
                SendNUIMessage({ type = "openPhone", player = playerData, battery = batteryLevel })
            end
        end)
    elseif isPhoneDead then
        exports.qbx_core:Notify("Your phone is dead. Buy a Power Bank.", "error")
    end
end, false)

RegisterKeyMapping('nexus_openphone', 'Open Nexus Phone', 'keyboard', 'M')

RegisterCommand('nexus_closephone', function()
    phoneOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "closePhone" })
end, false)

RegisterNUICallback('closePhone', function(data, cb)
    ExecuteCommand('nexus_closephone')
    cb('ok')
end)

-- Bank Transfer Callback from UI
RegisterNUICallback('transferMoney', function(data, cb)
    TriggerServerEvent('nexus_phone:server:TransferMoney', data.target, data.amount)
    cb('ok')
end)
