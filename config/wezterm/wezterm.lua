local wezterm = require 'wezterm';

return {
    font_size = 12.0,
    color_scheme = "Tomorrow Night Eighties",
    color_schemes = {
        ["Tomorrow Night Eighties"] = {
            foreground = "#1cd468",
            background = "#192129"
        }
    },
    harfbuzz_features = {'zero'},
    keys = {
        {key = 'p', mods = 'CMD', action = wezterm.action.ShowLauncher}, {
            key = "k",
            mods = "CMD",
            action = wezterm.action {ClearScrollback = "ScrollbackAndViewport"}
        },
        -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
        {
            key = "LeftArrow",
            mods = "OPT",
            action = wezterm.action {SendString = "\x1bb"}
        }, -- Make Option-Right equivalent to Alt-f; forward-word
        {
            key = "RightArrow",
            mods = "OPT",
            action = wezterm.action {SendString = "\x1bf"}
        }
    }
}
