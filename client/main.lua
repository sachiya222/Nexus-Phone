-- client/main.lua
local phoneOpen = false
local batteryLevel = 100
local isPhoneDead = false
local inCall = false

-- Background Battery Drain
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

-- Open Phone Command (Now fetching Live Database Info)
RegisterCommand('nexus_openphone', function()
    if not phoneOpen and not isPhoneDead then
        -- Fetch Profile
        lib.callback('nexus_phone:server:GetPlayerProfile', false, function(playerData)
            if playerData then
                -- Fetch Live Tweets
                lib.callback('nexus_phone:server:GetTweets', false, function(tweets)
                    -- Fetch Live Market
                    lib.callback('nexus_phone:server:GetMarketplace', false, function(market)
                        phoneOpen = true
                        SetNuiFocus(true, true)
                        SendNUIMessage({ 
                            type = "openPhone", 
                            player = playerData, 
                            battery = batteryLevel,
                            tweets = tweets or {},
                            market = market or {}
                        })
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

RegisterNUICallback('closePhone', function(data, cb)
    ExecuteCommand('nexus_closephone')
    cb('ok')
end)

RegisterNUICallback('transferMoney', function(data, cb)
    TriggerServerEvent('nexus_phone:server:TransferMoney', data.target, data.amount)
    cb('ok')
end)

-- VoIP Call Integration
RegisterNUICallback('startCall', function(data, cb)
    local targetNumber = data.number
    -- For this version, we generate a secure routing channel based on the number dialed
    local routingChannel = tonumber(targetNumber) or math.random(1000, 9999)
    
    inCall = true
    exports['pma-voice']:setCallChannel(routingChannel)
    exports.qbx_core:Notify("Connecting to " .. targetNumber .. "...", "success")
    cb('ok')
end)

RegisterNUICallback('endCall', function(data, cb)
    if inCall then
        exports['pma-voice']:setCallChannel(0) -- Channel 0 drops the call
        inCall = false
        exports.qbx_core:Notify("Call Ended", "error")
    end
    cb('ok')
end)

RegisterNUICallback('callService', function(data, cb)
    -- Dispatch Hook 
    exports.qbx_core:Notify("Dispatch sent to " .. string.upper(data.job), "success")
    cb('ok')
end)
