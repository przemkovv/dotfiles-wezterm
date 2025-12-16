local M = {}

local wezterm = require('wezterm') ---@as Wezterm

local default_font_index = 1
M.fonts = {
  {
    family_name = 'FiraCode Nerd Font',
    faces = { Thin = 'Light', Normal = 450, Bold = 'DemiBold' },
    line_height = 1.0,
    size = {
      ['MA-605'] = 11,
      legolas = 14,
      default = 10
    }
  },
  {
    family_name = 'JetBrainsMono Nerd Font',
    faces = { Thin = 'Light', Normal = 'Medium', Bold = 'ExtraBold' },
    line_height = 1.0,
    size = {
      ['MA-605'] = 11,
      legolas = 14,
      default = 10
    }
  }
}

local function get_font(font)
  return wezterm.font(
    font.family_name,
    {
      weight = font.faces.Normal,
      italic = false,
    }
  )
end

local function get_font_rules(font)
  ---@type FontRules
  local font_rules = {
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
  return font_rules
end

---@param config Config
---@param font_index number?
function M.setup_font(config, font_index)
  local selected_font = M.fonts[font_index or default_font_index]
  config.font = get_font(selected_font)
  config.font_rules = get_font_rules(selected_font)
  config.line_height = selected_font.line_height
  config.font_size = selected_font.size[wezterm.hostname()] or selected_font.size['default']
end

return M
