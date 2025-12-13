local wezterm = require 'wezterm'

-- Font installation on Windows:
-- Install-PSResource -Name NerdFonts
-- Import-Module -Name NerdFonts
-- Install-NerdFont -Name 'FiraCode'
-- Install-NerdFont -Name 'JetBrainsMono'

local config = wezterm.config_builder()
local fonts = {
  {
    family_name = 'FiraCode Nerd Font',
    faces = { Thin = 'Light', Normal = 450, Bold = 'DemiBold' },
    line_height = 1.0,
    size = {
      ['MA-605'] = 12,
      legolas = 14,
      default = 10
    }
  },
  {
    family_name = 'JetBrainsMono Nerd Font',
    faces = { Thin = 'Light', Normal = 'Medium', Bold = 'ExtraBold' },
    line_height = 1.0,
    size = {
      ['MA-605'] = 12,
      legolas = 14,
      default = 10
    }
  }
}
local font = fonts[2]
config.font = wezterm.font(font.family_name, { weight = font.faces.Normal, italic = false })
config.font_rules = {
  -- Match bold text and use a specific bold font
  {
    intensity = 'Half',
    italic = true,
    font = wezterm.font({
      family = font.family_name,
      weight = font.faces.Half,
      style = 'Italic',
    }),
  },
  {
    intensity = 'Half',
    italic = false,
    font = wezterm.font({
      family = font.family_name,
      weight = font.faces.Half,
      style = 'Normal',
    }),
  },
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font({
      family = font.family_name,
      weight = font.faces.Normal,
      style = 'Italic',
    }),
  },
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font({
      family = font.family_name,
      weight = font.faces.Normal,
      style = 'Normal',
    }),
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font({
      family = font.family_name,
      weight = font.faces.Bold,
      style = 'Italic',
    }),
  },
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font({
      family = font.family_name,
      weight = font.faces.Bold,
      style = 'Normal',
    }),
  },
}

config.color_scheme = 'Tango (terminal.sexy)'
-- config.color_scheme = 'Tokyo Night Moon'
config.bold_brightens_ansi_colors = "BrightAndBold"
config.line_height = font.line_height
config.use_fancy_tab_bar = true
config.tab_max_width = 30
config.tab_bar_at_bottom = false
config.adjust_window_size_when_changing_font_size = false
-- config.max_fps = 120
config.font_size = font.size[wezterm.hostname()] or font.size['default']
if wezterm.hostname() == 'MA-605' then
  config.enable_scroll_bar = true
  config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
  config.initial_cols = 160
  config.initial_rows = 40
elseif wezterm.hostname() == 'legolas' then
  config.enable_scroll_bar = false
  config.window_decorations = "TITLE"
  config.initial_cols = 160
  config.initial_rows = 40
  config.hide_tab_bar_if_only_one_tab = true
  config.term = 'wezterm'
else
  config.enable_scroll_bar = true
  config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
  config.initial_cols = 160
  config.initial_rows = 60
end

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
  if gpu.backend == 'Vulkan' and gpu.device_type == 'DiscreteGpu' then
    config.webgpu_preferred_adapter = gpu
    config.front_end = 'WebGpu'
    break
  end
end

config.enable_scroll_bar = true
config.scrollback_lines = 50000
config.use_dead_keys = false
config.disable_default_key_bindings = true
config.unicode_version = 14
config.debug_key_events = false
config.win32_system_backdrop = 'Tabbed'
config.allow_win32_input_mode = false
config.window_background_opacity = 0.8
config.text_background_opacity = 1.0
config.window_padding = {
  left = 0,
  right = 10,
  top = 0,
  bottom = 0,
}
config.enable_kitty_graphics = true

local launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  local pwsh_with_vs2 = {
    'cmd.exe',
    '/c',
    'vs_init.bat'
  }
  local pwsh_with_vs = {
    'pwsh.exe',
    '-NoExit', '-Command',
    -- '&{Import-Module "h:/Program Files/Microsoft Visual Studio/2022/Preview/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell c86811b0 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"}'
    '&{Import-Module "C:/Program Files/Microsoft Visual Studio/18/Insiders/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell f2e467b8 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"}'
  }
  config.default_cwd = 'h:/projects/'
  if wezterm.hostname() == 'MA-605' then
    pwsh_with_vs = {
      'pwsh.exe',
      '-NoExit', '-Command',
      '&{Import-Module "c:/Program Files (x86)/Microsoft Visual Studio/2022/Enterprise/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell 7cdab58d -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"}'
    }
    config.default_cwd = 'd:/projects/'
  end

  config.default_prog = pwsh_with_vs2
  table.insert(launch_menu, {
    label = 'pwsh',
    args = { 'pwsh.exe', '-NoLogo' },
  })
  table.insert(launch_menu, {
    label = 'pwsh with VS',
    args = pwsh_with_vs,
    cwd = config.default_cwd,
  })
  table.insert(launch_menu, {
    label = 'pwsh with VS simple',
    args = pwsh_with_vs2,
    cwd = config.default_cwd,
    domain = 'DefaultDomain'
  })
end

config.ssh_backend = "Ssh2"
config.launch_menu = launch_menu

local act = wezterm.action
config.leader = { key = 'b', mods = 'ALT', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'F12',      mods = 'ALT',        action = act.ShowDebugOverlay, },
  { key = "p",        mods = "ALT",        action = act.ActivateCommandPalette },
  { key = "t",        mods = "ALT|CTRL",   action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
  { key = "w",        mods = "ALT",        action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES|DOMAINS" }), },
  { key = 'l',        mods = 'ALT',        action = act.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' }, },
  { key = "d",        mods = 'ALT|SHIFT',  action = act.SpawnTab("DefaultDomain") },
  { key = "d",        mods = 'ALT',        action = act.SpawnTab("CurrentPaneDomain") },
  { key = "t",        mods = 'ALT|SHIFT',  action = act.SpawnWindow },
  { key = "c",        mods = "ALT",        action = act.CloseCurrentPane({ confirm = false }) },
  { key = "q",        mods = 'ALT',        action = act.CloseCurrentTab({ confirm = false }) },
  { key = "s",        mods = "ALT",        action = act.SplitVertical({ domain = "CurrentPaneDomain" }), },
  { key = "v",        mods = "ALT",        action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }), },
  { key = "|",        mods = "ALT|SHIFT",  action = act.TogglePaneZoomState },
  { key = "k",        mods = "ALT",        action = act.ActivatePaneDirection("Up") },
  { key = "j",        mods = "ALT",        action = act.ActivatePaneDirection("Down") },
  { key = "h",        mods = "ALT",        action = act.ActivatePaneDirection("Left") },
  { key = "h",        mods = "ALT|SHIFT",  action = act.ActivateTabRelative(-1) },
  { key = "l",        mods = "ALT|SHIFT",  action = act.ActivateTabRelative(1) },
  { key = "l",        mods = "ALT",        action = act.ActivatePaneDirection("Right") },
  { key = "Tab",      mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "Tab",      mods = "CTRL",       action = act.ActivateTabRelative(1) },
  { key = "f",        mods = "ALT",        action = act.Search({ CaseInSensitiveString = "" }) },
  { key = "x",        mods = "ALT",        action = act.ActivateCopyMode },
  { key = " ",        mods = "CTRL|SHIFT", action = act.QuickSelect },
  { key = "c",        mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v",        mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "Insert",   mods = "SHIFT",      action = act.PasteFrom("Clipboard") },
  { key = 'F9',       mods = 'ALT',        action = wezterm.action.ShowTabNavigator },
  { key = 'PageUp',   mods = 'SHIFT',      action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT',      action = act.ScrollByPage(1) },
  {
    key = "p",
    mods = "LEADER",
    action = act.PaneSelect({
      alphabet = "1234567890",
      mode = "SwapWithActiveKeepFocus"
    }),
  },
  {
    key = "f",
    mods = "LEADER",
    action = act.ActivateKeyTable({
      name = "resize_font",
      one_shot = false,
      timemout_miliseconds = 1000,
    }),
  },
  { key = 'b', mods = 'LEADER|CTRL', action = act.SendKey { key = 'b', mods = 'CTRL' }, },
}

local copy_mode = wezterm.gui.default_key_tables().copy_mode
if wezterm.gui then
  table.insert(copy_mode, { key = 'k', mods = 'CTRL', action = act.CopyMode 'MoveBackwardSemanticZone' })
  table.insert(copy_mode, { key = 'j', mods = 'CTRL', action = act.CopyMode 'MoveForwardSemanticZone' })
  table.insert(copy_mode, { key = 'z', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'SemanticZone' }, })
  table.insert(copy_mode, { key = 'k', mods = 'ALT', action = act.CopyMode { MoveBackwardZoneOfType = 'Output' } })
  table.insert(copy_mode, { key = 'j', mods = 'ALT', action = act.CopyMode { MoveForwardZoneOfType = 'Output' } })
end
local key_tables = {
  resize_font = {
    { key = "k",      action = act.IncreaseFontSize },
    { key = "j",      action = act.DecreaseFontSize },
    { key = "r",      action = act.ResetFontSize },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
  },
  resize_pane = {
    { key = "k",      action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "j",      action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "h",      action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "l",      action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
  },
  copy_mode = copy_mode,
}

config.disable_default_mouse_bindings = false
local mouse_bindings = {
  { event = { Up = { streak = 1, button = "Left" } },              mods = "NONE", action = act.CompleteSelection("ClipboardAndPrimarySelection"), },
  { event = { Up = { streak = 1, button = "Left" } },              mods = "CTRL", action = act.OpenLinkAtMouseCursor, },
  { event = { Down = { streak = 3, button = 'Left' } },            mods = 'NONE', action = act.SelectTextAtMouseCursor 'SemanticZone', },
  { event = { Down = { streak = 1, button = { WheelUp = 1 } } },   mods = 'CTRL', action = act.IncreaseFontSize, },
  { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = 'CTRL', action = act.DecreaseFontSize, },
}

config.key_tables = key_tables
config.mouse_bindings = mouse_bindings

local nf = wezterm.nerdfonts
wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
  wezterm.log_info("new-tab", window, pane, button, default_action)
  if default_action and button == "Left" then
    window:perform_action(default_action, pane)
  end

  if default_action and button == "Right" then
    window:perform_action(
      wezterm.action.ShowLauncherArgs({
        title = nf.fa_rocket .. "  Select/Search:",
        flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
      }),
      pane
    )
  end
  return false
end)

return config
