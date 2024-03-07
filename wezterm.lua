local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Tango (terminal.sexy)'
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 13
config.line_height = 1.0
config.initial_cols = 160
config.initial_rows = 60
config.use_fancy_tab_bar = true
config.tab_max_width = 30
config.tab_bar_at_bottom = false
config.adjust_window_size_when_changing_font_size = false
config.max_fps = 120
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
config.term = 'wezterm'
config.front_end = 'WebGpu'
config.enable_scroll_bar = true
config.scrollback_lines = 10000
config.use_dead_keys = false
config.disable_default_key_bindings = false
config.debug_key_events = false
config.window_padding = {
  left = 0,
  right = 10,
  top = 0,
  bottom = 0,
}

local launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  local pwsh_with_vs = {
    'pwsh.exe',
    '-NoExit', '-Command',
    '&{Import-Module "h:/Program Files/Microsoft Visual Studio/2022/Preview/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell c86811b0 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"}'
  }
  config.default_prog = pwsh_with_vs
  config.default_cwd = 'h:/projects/'
  table.insert(launch_menu, {
    label = 'pwsh',
    args = { 'pwsh.exe', '-NoLogo' },
  })
  table.insert(launch_menu, {
    label = 'pwsh with VS',
    args = pwsh_with_vs,
    cwd = 'h:/projects/',
    domain = 'DefaultDomain'
  })
end

config.launch_menu = launch_menu

local act = wezterm.action
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = "1",      mods = "LEADER",       action = "ActivateCopyMode" },
  { key = "p",      mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
  { key = "t",      mods = "LEADER|CTRL",  action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
  { key = "w",      mods = "LEADER|CTRL",  action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }), },
  { key = "f",      mods = "LEADER",       action = act.Search({ CaseInSensitiveString = "" }) },
  { key = 'l',      mods = 'LEADER',       action = act.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' }, },
  { key = "c",      mods = "CTRL|SHIFT",   action = act.CopyTo("Clipboard") },
  { key = "v",      mods = "CTRL|SHIFT",   action = act.PasteFrom("Clipboard") },
  { key = "Insert", mods = "SHIFT",        action = act.PasteFrom("Clipboard") },
  { key = "d",      mods = 'LEADER',       action = act.SpawnTab("DefaultDomain") },
  { key = "t",      mods = 'LEADER|SHIFT', action = act.SpawnWindow },
  { key = "q",      mods = 'LEADER',       action = act.CloseCurrentTab({ confirm = false }) },
  { key = 'F12',      mods = 'NONE',       action = act.ShowDebugOverlay, },
  { key = "s",      mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }), },
  { key = "v",      mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }), },
  { key = "|",      mods = "LEADER|SHIFT", action = act.TogglePaneZoomState },
  { key = "c",      mods = "LEADER",       action = act.CloseCurrentPane({ confirm = false }) },
  { key = "k",      mods = "LEADER|CTRL",  action = act.ActivatePaneDirection("Up") },
  { key = "j",      mods = "LEADER|CTRL",  action = act.ActivatePaneDirection("Down") },
  { key = "h",      mods = "LEADER|CTRL",  action = act.ActivatePaneDirection("Left") },
  { key = "l",      mods = "LEADER|CTRL",  action = act.ActivatePaneDirection("Right") },
  { key = "Tab",    mods = "CTRL|SHIFT",   action = act.ActivateTabRelative(-1) },
  { key = "Tab",    mods = "CTRL",         action = act.ActivateTabRelative(1) },
  { key = "p",      mods = "LEADER",       action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }), },
  { key = "f",      mods = "LEADER",       action = act.ActivateKeyTable({ name = "resize_font", one_shot = false, timemout_miliseconds = 1000, }), },
  { key = 'b',      mods = 'LEADER|CTRL',  action = act.SendKey { key = 'b', mods = 'CTRL' }, },
}

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
}
local mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
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