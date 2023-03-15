local wezterm = require 'wezterm';
local act = wezterm.action

return {
    font_size = 14.0,
    color_scheme = "Tomorrow Night Eighties",
    color_schemes = {
        ["Tomorrow Night Eighties"] = {
            foreground = "#1cd468",
            background = "#192129"
        }
    },
    harfbuzz_features = {'zero'},
    keys = {
        {key = 'p', mods = 'CMD', action = act.ShowLauncher},
        {key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByPage(-1)},
        {key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByPage(1)}, {
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
    },
    hyperlink_rules = {
        -- Linkify things that look like URLs and the host has a TLD name.
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b', format = '$0'},

        -- linkify email addresses
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]], format = 'mailto:$0'},

        -- file:// URI
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {regex = [[\bfile://\S*\b]], format = '$0'},

        -- Linkify things that look like URLs with numeric addresses as hosts.
        -- E.g. http://127.0.0.1:8000 for a local development server,
        -- or http://192.168.1.1 for the web interface of many routers.
        {regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]], format = '$0'}
    }
}
