local M = {}

local wezterm = require('wezterm') ---@as Wezterm

local default_font_index = 1

local fallback_fonts = {
  -- Symbol coverage
  { family = "Symbols Nerd Font Mono" },
  { family = "Noto Sans Symbols 2" },
  { family = "Segoe UI Symbol" },
  { family = "Symbola" },

  -- Math coverage
  { family = "STIX Two Math" },
  { family = "Cambria Math" },
  { family = "Noto Sans Math" },

  -- Miscellaneous wide coverage
  { family = "Noto Color Emoji" },
  { family = "Noto Sans CJK SC" },
  { family = "Noto Sans CJK JP" },
}

M.fonts = {
  {
    family_name = 'FiraCode Nerd Font',
    faces = { Half = 'Light', Normal = 450, Bold = 'DemiBold' },
    line_height = 1.0,
    size = {
      ['MA-605'] = 11,
      legolas = 14,
      default = 10
    },
    has_italic = false,
  },
  {
    family_name = 'JetBrainsMono Nerd Font Mono',
    faces = { Half = 'Light', Normal = 'Medium', Bold = 'ExtraBold' },
    line_height = 1.0,
    size = {
      ['MA-605'] = 11,
      legolas = 14,
      default = 10
    },
    has_italic = true,
  },
}

local function get_font(font)
  return wezterm.font_with_fallback({
    {
      family = font.family_name,
      weight = font.faces.Normal,
      style = font.has_italic and 'Italic' or 'Normal',
    },
    table.unpack(fallback_fonts),
  })
end

local function make_font_with_fallback(family, weight, style)
  return wezterm.font_with_fallback({
    { family = family, weight = weight, style = style },
    table.unpack(fallback_fonts),
  })
end

local function get_font_rules(font)
  ---@type FontRules
  local font_rules = {
    {
      intensity = 'Half',
      italic = true,
      font = make_font_with_fallback(font.family_name, font.faces.Half, 'Italic'),
    },
    {
      intensity = 'Half',
      italic = false,
      font = make_font_with_fallback(font.family_name, font.faces.Half, 'Normal'),
    },
    {
      intensity = 'Normal',
      italic = true,
      font = make_font_with_fallback(font.family_name, font.faces.Normal, 'Italic'),
    },
    {
      intensity = 'Normal',
      italic = false,
      font = make_font_with_fallback(font.family_name, font.faces.Normal, 'Normal'),
    },
    {
      intensity = 'Bold',
      italic = true,
      font = make_font_with_fallback(font.family_name, font.faces.Bold, 'Italic'),
    },
    {
      intensity = 'Bold',
      italic = false,
      font = make_font_with_fallback(font.family_name, font.faces.Bold, 'Normal'),
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
