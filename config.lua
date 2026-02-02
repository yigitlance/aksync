Config                  = {}

Config.DynamicWeather   = true -- Set this to false if you don't want the weather to change dynamically

-- On server start
Config.StartWeather           = 'EXTRASUNNY' -- Default weather                         default: 'EXTRASUNNY'
Config.BaseTime               = 6            -- Time                                    default: 8
Config.TimeOffset             = 0            -- Time offset                             default: 0
Config.FreezeTime             = false        -- freeze time                             default: true
Config.TimeTransitionDuration = 3000         -- Duration (ms) for smooth time changes   default: 3000
Config.TimeScale              = 30.0         -- How many real seconds per game minute   default: 30.0
Config.WeatherUsesGameTime    = false        -- true: weather follows TimeScale, false: IRL minutes
Config.Blackout               = false        -- Set blackout                            default: false
Config.Locale                 = 'en'         -- Languages : en, fr, pt, tr, pt_br, de, es, it

-- dynamic weather settings (needs Config.DynamicWeather = true)
-- weight: higher number means higher chance to be selected
-- duration: how many IN-GAME minutes the weather lasts
Config.WeatherSettings = {
    ['EXTRASUNNY']  = { weight = 20, duration = 90 },
    ['CLEAR']       = { weight = 20, duration = 60 },
    ['NEUTRAL']     = { weight = 15, duration = 60 },
    ['SMOG']        = { weight = 6,  duration = 45 },
    ['FOGGY']       = { weight = 6,  duration = 30 },
    ['OVERCAST']    = { weight = 10, duration = 45 },
    ['CLOUDS']      = { weight = 10, duration = 45 },
    ['CLEARING']    = { weight = 7,  duration = 30 },
    ['RAIN']        = { weight = 6,  duration = 20 },
    ['THUNDER']     = { weight = 4,  duration = 15 },
    ['SNOW']        = { weight = 0,  duration = 1 },
    ['BLIZZARD']    = { weight = 0,  duration = 1 },
    ['SNOWLIGHT']   = { weight = 0,  duration = 1 },
    ['XMAS']        = { weight = 0,  duration = 1 },
    ['HALLOWEEN']   = { weight = 0,  duration = 1 },
}

Config.AvailableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}