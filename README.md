# Aksync

aksync is an improved version of **vSync** specially for [**lance-race**](https://youtu.be/foVNezfuHLQ) but it can be used for other scripts too.

### Simple, weighted weather and time sync for FiveM with a few extra features.
Credits to **Vespura** for the original vSync.

**Current version:** 1.3.2

**Author:** lance(aksy)

***

# Features
- **Weighted Dynamic Weather**: Weather changes based on realistic? (and configurable) weights. Sunny days are more likely, but you decide the odds and the duration for each.
- **Smooth Transitions**: Changing time or weather manually won't "flicker". Time glides smoothly to its destination, and weather fades in naturally.
- **Configurable Time Scaling**: Want a real-time day? Or a fast 30-minute cycle? Set your `TimeScale` based on your preference.
- **Built-in Admin Support**: Uses FiveM's native command restriction. No setup required for `group.admin`.
- **Zero Lag**: Highly optimized loops (1.0s) ensure your server remains performant.
- **exports**: exports for other scripts (e.g lance-race) to use. (override, transition, etc)

# Translation Credits
**Portuguese**: [raphapt](https://github.com/raphapt)\
**Turkish**: [thegambid](https://github.com/thegambid)\
**Bresilian Portuguese**: [Richards0nd](https://github.com/Richards0nd)
**German**: [Xtrea2022](https://github.com/Xtrea2022)
- I made minor editing to all locales to support 'ox_lib' notifications

# Commands
`/weather <type>` Change the weather. Dynamic shifts will continue based on your config.
`/freezeweather` Enable/disable dynamic weather changes.
`/time <h> <m>` Set the time.
`/freezetime` Freeze/unfreeze time.
`/morning` Set the time to morning.
`/noon` Set the time to noon.
`/evening` Set the time to evening.
`/night` Set the time to night.
`/blackout` Enable/disable blackout mode.

# Configuration
Open `config.lua` to tweak weights, durations, time scale, and more. 

- `Config.TimeScale`: How fast time moves (e.g., 30.0 for a half-hour day).
- `Config.WeatherUsesGameTime`: Choose if weather durations follow real minutes or game minutes.
- `Config.WeatherSettings`: Set probabilities and lengths for every weather type.


***

# Developers / Exports
You can use these in your other scripts to control or override the sync:

```lua
-- Stop the script from syncing (useful for cutscenes or specific areas we use this for our own racing script :D) 
exports.aksync:setSyncOverride(true)

-- Smoothly transition to 18:00 and RAIN over 10 seconds
exports.aksync:transitionSync('RAIN', 18, 0, 10000)

-- Smoothly transition back to server sync over 5 seconds
exports.aksync:transitionBack(5000)
```

***

### Permissions
AkSync uses native command restrictions. To let a group other than admin use commands, add this to your `server.cfg`:
```cfg
add_ace group.mod command.weather allow
add_ace group.mod command.time allow
```