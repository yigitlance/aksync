CurrentWeather = Config.StartWeather
local baseTime = Config.BaseTime
local timeOffset = Config.TimeOffset
local freezeTime = Config.FreezeTime
local blackout = Config.Blackout
local newWeatherTimer = Config.WeatherSettings[CurrentWeather] and Config.WeatherSettings[CurrentWeather].duration or 60

RegisterServerEvent('aksync:requestSync')
AddEventHandler('aksync:requestSync', function(duration)
    TriggerClientEvent('aksync:updateWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('aksync:updateTime', -1, baseTime, timeOffset, freezeTime, duration)
end)
RegisterCommand('freezetime', function(source)
    freezeTime = not freezeTime
    if source ~= 0 then
        TriggerClientEvent('aksync:notify', source, {
            title = _U('title_info'),
            description = freezeTime and _U('time_frozenc') or _U('time_unfrozenc'),
            type = 'info'
        })
    else
        print(freezeTime and _U('time_now_frozen') or _U('time_now_unfrozen'))
    end
    TriggerEvent('aksync:requestSync')
end, true)

RegisterCommand('freezeweather', function(source)
    Config.DynamicWeather = not Config.DynamicWeather
    if source ~= 0 then
        TriggerClientEvent('aksync:notify', source, {
            title = _U('title_info'),
            description = not Config.DynamicWeather and _U('dynamic_weather_disabled') or _U('dynamic_weather_enabled'),
            type = not Config.DynamicWeather and 'warning' or 'success'
        })
    else
        print(not Config.DynamicWeather and _U('weather_now_frozen') or _U('weather_now_unfrozen'))
    end
end, true)

RegisterCommand('weather', function(source, args)
    local newWeather = args[1] and string.upper(args[1])
    if not newWeather then
        if source == 0 then print(_U('weather_invalid_syntax'))
        else TriggerClientEvent('aksync:notify', source, {title = _U('title_error'), description = _U('weather_invalid_syntaxc'), type = 'error'}) end
        return
    end

    local validWeatherType = false
    for _, wtype in ipairs(Config.AvailableWeatherTypes) do
        if wtype == newWeather then
            validWeatherType = true
            break
        end
    end

    if not validWeatherType then
        if source == 0 then print(_U('weather_invalid'))
        else TriggerClientEvent('aksync:notify', source, {title = _U('title_error'), description = _U('weather_invalidc'), type = 'error'}) end
        return
    end

    CurrentWeather = newWeather
    Config.DynamicWeather = true -- tbh this is how we shouldnt do it but idgaf for now 
    newWeatherTimer = Config.WeatherSettings[newWeather] and Config.WeatherSettings[newWeather].duration or 60
    TriggerEvent('aksync:requestSync')

    if source ~= 0 then
        TriggerClientEvent('aksync:notify', source, {title = _U('title_info'), description = _U('weather_willchangeto', string.lower(newWeather)), type = 'info'})
    else
        print(_U('weather_updated'))
    end
end, true)

RegisterCommand('blackout', function(source)
    blackout = not blackout
    if source == 0 then
        print(blackout and _U('blackout_enabled') or _U('blackout_disabled'))
    else
        TriggerClientEvent('aksync:notify', source, {
            title = _U('title_info'),
            description = blackout and _U('blackout_enabledc') or _U('blackout_disabledc'),
            type = blackout and 'success' or 'warning'
        })
    end
    TriggerEvent('aksync:requestSync')
end, true)

local function setTime(source, hour, minute)
    ShiftToHour(hour)
    ShiftToMinute(minute)
    if source ~= 0 then
        local newtime = ('%02d:%02d'):format(hour, minute)
        TriggerClientEvent('aksync:notify', source, {title = _U('title_success'), description = _U('time_changec', newtime), type = 'success'})
    else
        print(_U('time_change', hour, minute))
    end
    TriggerEvent('aksync:requestSync', Config.TimeTransitionDuration)
end

RegisterCommand('morning', function(source)
    setTime(source, 9, 0)
end, true)

RegisterCommand('noon', function(source)
    setTime(source, 12, 0)
end, true)

RegisterCommand('evening', function(source)
    setTime(source, 18, 0)
end, true)

RegisterCommand('night', function(source)
    setTime(source, 23, 0)
end, true)

function ShiftToMinute(minute)
    timeOffset = timeOffset - ( ( (baseTime+timeOffset) % 60 ) - minute )
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ( ( ((baseTime+timeOffset)/60) % 24 ) - hour ) * 60
end

RegisterCommand('time', function(source, args)
    local argh = tonumber(args[1])
    local argm = tonumber(args[2]) or 0

    if argh and argh >= 0 and argh < 24 and argm >= 0 and argm < 60 then
        setTime(source, argh, argm)
    else
        if source == 0 then print(_U('time_invalid'))
        else TriggerClientEvent('aksync:notify', source, {title = _U('title_error'), description = _U('time_invalidc'), type = 'error'}) end
    end
end, true)

CreateThread(function()
    while true do
        Wait(1000)
        local newBaseTime = os.time(os.date("!*t")) / Config.TimeScale + 360
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime			
        end
        baseTime = newBaseTime
    end
end)

CreateThread(function()
    while true do
        Wait(10000)
        TriggerClientEvent('aksync:updateTime', -1, baseTime, timeOffset, freezeTime)
        Wait(20000)
    end
end)

CreateThread(function()
    while true do
        local waitInterval = Config.WeatherUsesGameTime and math.floor(Config.TimeScale * 1000) or 60000
        Wait(waitInterval)
        if Config.DynamicWeather then
            newWeatherTimer = newWeatherTimer - 1
            if newWeatherTimer <= 0 then
                NextWeatherStage()
            end
        end
    end
end)

local function GetNextWeather()
    local totalWeight = 0
    for _, settings in pairs(Config.WeatherSettings) do
        totalWeight = totalWeight + settings.weight
    end

    if totalWeight <= 0 then 
        warn("All weather weights are set to 0 in config! Defaulting to EXTRASUNNY.")
        return "EXTRASUNNY" 
    end

    local randomValue = math.random(1, totalWeight)
    local currentSum = 0

    for weather, settings in pairs(Config.WeatherSettings) do
        currentSum = currentSum + settings.weight
        if randomValue <= currentSum then
            return weather
        end
    end
    return "EXTRASUNNY"
end

function NextWeatherStage()
    CurrentWeather = GetNextWeather()
    newWeatherTimer = Config.WeatherSettings[CurrentWeather] and Config.WeatherSettings[CurrentWeather].duration or 60
    TriggerEvent("aksync:requestSync")
end