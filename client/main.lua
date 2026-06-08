local phoneOpen = false

-- Command to open the phone
RegisterCommand('nexus_openphone', function()
    if not phoneOpen then
        phoneOpen = true
        
        -- Give the player's mouse/keyboard focus to the UI
        SetNuiFocus(true, true)
        
        -- Send a message to our app.js to show the screen
        SendNUIMessage({
            type = "openPhone"
        })
    end
end, false)

-- Bind the command to the 'M' key by default
RegisterKeyMapping('nexus_openphone', 'Open Nexus Phone', 'keyboard', 'M')

-- Callback from the UI when the Escape key is pressed
RegisterNUICallback('closePhone', function(data, cb)
    phoneOpen = false
    
    -- Give controls back to the player's character
    SetNuiFocus(false, false)
    
    -- Tell the UI to hide itself
    SendNUIMessage({
        type = "closePhone"
    })
    
    cb('ok')
end)
