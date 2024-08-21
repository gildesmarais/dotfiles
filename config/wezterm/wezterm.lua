local wezterm = require 'wezterm';
local act = wezterm.action

-- Replace the old wezterm.on('update-status', ... function with this:

local function segments_for_right_status(window)
  return {
    wezterm.strftime('%a %b %-d %H:%M'),
    wezterm.hostname(),
  }
end

wezterm.on('update-status', function(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  -- Note the use of wezterm.color.parse here, this returns
  -- a Color object, which comes with functionality for lightening
  -- or darkening the colour (amongst other things).
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Each powerline segment is going to be coloured progressively
  -- darker/lighter depending on whether we're on a dark/light colour
  -- scheme. Let's establish the "from" and "to" bounds of our gradient.
  local gradient_to, gradient_from = bg
  if appearance.is_dark() then
    gradient_from = gradient_to:lighten(0.2)
  else
    gradient_from = gradient_to:darken(0.2)
  end

  -- Yes, WezTerm supports creating gradients, because why not?! Although
  -- they'd usually be used for setting high fidelity gradients on your terminal's
  -- background, we'll use them here to give us a sample of the powerline segment
  -- colours we need.
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)

return {
    font_size = 14.0,
    color_scheme = "Tomorrow Night Eighties",
    color_schemes = {
        ["Tomorrow Night Eighties"] = {
            foreground = "#1cd468",
            background = "#192129"
        }
    },
    window_decorations = 'RESIZE',
    harfbuzz_features = {'zero'},
    keys = {
        {key = 'p', mods = 'CMD|SHIFT', action = act.ShowLauncher},
        {key = 'p', mods = 'CMD', action = act.ScrollByPage(-1)},
        {key = 'd', mods = 'CMD', action = act.ScrollByPage(1)},
        {key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByPage(-1)},
        {key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByPage(1)},
        {key = '/', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },
        {
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
        },
        {
          key = ',',
          mods = 'SUPER',
          action = wezterm.action.SpawnCommandInNewTab {
            cwd = wezterm.home_dir,
            args = { 'vim', wezterm.config_file },
          },
        },
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
    },
    quick_select_patterns = {
      -- match text surrounded by backticks
      '`(.*)`'
    }
}
