local isSyncOverridden = false
local serverWeather = Config.StartWeather
local CurrentWeather = serverWeather
local lastWeather = serverWeather
local baseTime = Config.BaseTime
local timeOffset = Config.TimeOffset
local timer = 0
local freezeTime = Config.FreezeTime
local blackout = Config.Blackout
local transitionDuration = 0

exports('setSyncOverride', function(state)
    isSyncOverridden = state
end)

exports('transitionSync', function(weather, hour, minute, duration)
    isSyncOverridden = true
    
    -- transition weather
    if weather and weather ~= CurrentWeather then
        SetWeatherTypeOverTime(weather, duration / 1000.0)
        CurrentWeather = weather
        lastWeather = weather
    end

    -- transition time
    if hour then
        CreateThread(function()
            local startT = GetGameTimer()
            local startH = GetClockHours()
            local startM = GetClockMinutes()
            local startTotal = startH * 60 + startM
            local targetTotal = hour * 60 + (minute or 0)
            local diff = targetTotal - startTotal
            if diff > 720 then diff = diff - 1440
            elseif diff < -720 then diff = diff + 1440 end
            
            while GetGameTimer() - startT < duration and isSyncOverridden do
                local progress = (GetGameTimer() - startT) / duration
                local currentTotal = (startTotal + (diff * progress)) % 1440
                if currentTotal < 0 then currentTotal = currentTotal + 1440 end
                
                local h = math.floor(currentTotal / 60)
                local m = math.floor(currentTotal % 60)
                NetworkOverrideClockTime(h, m, 0)
                Wait(0)
            end
            
            if isSyncOverridden then
                NetworkOverrideClockTime(hour, minute or 0, 0)
            end
        end)
    end
end)

RegisterNetEvent('aksync:updateWeather')
AddEventHandler('aksync:updateWeather', function(NewWeather, newblackout)
    serverWeather = NewWeather
    blackout = newblackout
    if not isSyncOverridden then
        CurrentWeather = NewWeather
    end
end)

local lastTimeTransition = 0
RegisterNetEvent('aksync:updateTime', function(base, offset, freeze, duration)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base

    if duration and duration > 0 and not isSyncOverridden then
        local thisTransition = GetGameTimer()
        lastTimeTransition = thisTransition
        transitionDuration = duration
        
        CreateThread(function()
            local startT = GetGameTimer()
            local startH = GetClockHours()
            local startM = GetClockMinutes()
            local startTotal = startH * 60 + startM
            
            local targetH = math.floor(((baseTime + timeOffset) / 60) % 24)
            local targetM = math.floor((baseTime + timeOffset) % 60)
            local targetTotal = targetH * 60 + targetM
            
            local diff = targetTotal - startTotal
            if diff > 720 then diff = diff - 1440
            elseif diff < -720 then diff = diff + 1440 end
            
            while GetGameTimer() - startT < duration and not isSyncOverridden and lastTimeTransition == thisTransition do
                local progress = (GetGameTimer() - startT) / duration
                local currentTotal = (startTotal + (diff * progress)) % 1440
                if currentTotal < 0 then currentTotal = currentTotal + 1440 end
                
                local h = math.floor(currentTotal / 60)
                local m = math.floor(currentTotal % 60)
                NetworkOverrideClockTime(h, m, 0)
                Wait(0)
            end
        end)
    end
end)

CreateThread(function()
    local lastTick = GetGameTimer()
    while true do
        Wait(500)
        if not isSyncOverridden then
            if lastWeather ~= CurrentWeather then
                lastWeather = CurrentWeather
                SetWeatherTypeOverTime(CurrentWeather, 15.0)
            end

            SetArtificialLightsState(blackout)
            SetArtificialLightsStateAffectsVehicles(false)
            
            if lastWeather == 'XMAS' then
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
            else
                SetForceVehicleTrails(false)
                SetForcePedFootstepsTracks(false)
            end

            local now = GetGameTimer()
            local delta = (now - lastTick) / 1000.0
            lastTick = now

            PauseClock(freezeTime)
            if not freezeTime then
                SetMillisecondsPerGameMinute(math.floor(Config.TimeScale * 1000))
                baseTime = baseTime + (delta * (1.0 / Config.TimeScale)) 
            end

            serverHour = math.floor(((baseTime + timeOffset) / 60) % 24)
            serverMinute = math.floor((baseTime + timeOffset) % 60)
            
            if GetGameTimer() - lastTimeTransition > transitionDuration then
                NetworkOverrideClockTime(serverHour, serverMinute, 0)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        if not isSyncOverridden then
            ClearWeatherTypePersist()
            SetWeatherTypePersist(lastWeather)
            SetWeatherTypeNow(lastWeather)
            SetWeatherTypeNowPersist(lastWeather)
        end
    end
end)

exports('transitionBack', function(duration)
    if not isSyncOverridden then return end
    TriggerServerEvent('aksync:requestSync')
    exports.aksync:transitionSync(serverWeather, serverHour, serverMinute, duration)
    SetTimeout(duration, function()
        isSyncOverridden = false
    end)
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('aksync:requestSync')
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/weather', _U('help_weathercommand'), {{ name=_('help_weathertype'), help=_U('help_availableweather')}})
    TriggerEvent('chat:addSuggestion', '/time', _U('help_timecommand'), {{ name=_('help_timehname'), help=_U('help_timeh')}, { name=_('help_timemname'), help=_U('help_timem')}})
    TriggerEvent('chat:addSuggestion', '/freezetime', _U('help_freezecommand'))
    TriggerEvent('chat:addSuggestion', '/freezeweather', _U('help_freezeweathercommand'))
    TriggerEvent('chat:addSuggestion', '/morning', _U('help_morningcommand'))
    TriggerEvent('chat:addSuggestion', '/noon', _U('help_nooncommand'))
    TriggerEvent('chat:addSuggestion', '/evening', _U('help_eveningcommand'))
    TriggerEvent('chat:addSuggestion', '/night', _U('help_nightcommand'))
    TriggerEvent('chat:addSuggestion', '/blackout', _U('help_blackoutcommand'))
end)

RegisterNetEvent('aksync:notify', function(data)
    exports.ox_lib:notify(data)
end)