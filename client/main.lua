-- client/main.lua
local phoneOpen = false
local batteryLevel = 100
local isPhoneDead = false
local inCall = false

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
                lib.callback('nexus_phone:server:GetTweets', false, function(tweets)
                    lib.callback('nexus_phone:server:GetMarketplace', false, function(market)
                        lib.callback('nexus_phone:server:GetAutoSell', false, function(autosell)
                            phoneOpen = true
                            SetNuiFocus(true, true)
                            SendNUIMessage({ 
                                type = "openPhone", 
                                player = playerData, 
                                battery = batteryLevel,
                                tweets = tweets or {},
                                market = market or {},
                                autosell = autosell or {}
                            })
                        end)
                    end)
                end)
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

RegisterNUICallback('closePhone', function(data, cb) ExecuteCommand('nexus_closephone') cb('ok') end)

-- NUI Data Relays
RegisterNUICallback('transferMoney', function(data, cb)
    TriggerServerEvent('nexus_phone:server:TransferMoney', data.target, data.amount)
    cb('ok')
end)

RegisterNUICallback('postTweet', function(data, cb)
    TriggerServerEvent('nexus_phone:server:PostTweet', data.message)
    exports.qbx_core:Notify("Tweet Sent!", "success")
    cb('ok')
end)

RegisterNUICallback('postMarket', function(data, cb)
    TriggerServerEvent('nexus_phone:server:PostMarket', data.title, data.desc, data.price)
    exports.qbx_core:Notify("Item listed on Marketplace!", "success")
    cb('ok')
end)

RegisterNUICallback('postAutoSell', function(data, cb)
    TriggerServerEvent('nexus_phone:server:PostAutoSell', data.vehicle, data.desc, data.price)
    exports.qbx_core:Notify("Vehicle listed on AutoSell!", "success")
    cb('ok')
end)

-- VoIP Relays
RegisterNUICallback('startCall', function(data, cb)
    local routingChannel = tonumber(data.number) or math.random(1000, 9999)
    inCall = true
    exports['pma-voice']:setCallChannel(routingChannel)
    exports.qbx_core:Notify("Connecting to " .. data.number .. "...", "success")
    cb('ok')
end)

RegisterNUICallback('endCall', function(data, cb)
    if inCall then
        exports['pma-voice']:setCallChannel(0)
        inCall = false
        exports.qbx_core:Notify("Call Ended", "error")
    end
    cb('ok')
end)

-- Emergency Dispatch Relay
RegisterNUICallback('callService', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    TriggerServerEvent('nexus_phone:server:CallService', data.job, coords)
    exports.qbx_core:Notify("Dispatch sent to " .. string.upper(data.job) .. " units.", "success")
    cb('ok')
end)

-- Catch Dispatch Alert from Server
RegisterNetEvent('nexus_phone:client:ReceiveDispatch', function(jobSent, coords)
    exports.qbx_core:Notify("DISPATCH: 10-71 / Alert from Citizen", "error", 7500)
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Emergency Dispatch Call")
    EndTextCommandSetBlipName(blip)
    
    -- Remove the blip automatically after 2 minutes
    SetTimeout(120000, function()
        RemoveBlip(blip)
    end)
end)
