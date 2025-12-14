local wezterm = require('wezterm')
local M = {}

M.selected_font_index = 1
M.fonts = {
  {
    family_name = 'FiraCode Nerd Font',
    faces = { Thin = 'Light', Normal = 450, Bold = 'DemiBold' },
    line_height = 1.1,
    size = {
      ['MA-605'] = 12,
      legolas = 14,
      default = 10
    }
  },
  {
    family_name = 'JetBrainsMono Nerd Font',
    faces = { Thin = 'Light', Normal = 'Medium', Bold = 'ExtraBold' },
    line_height = 1.1,
    size = {
      ['MA-605'] = 12,
      legolas = 14,
      default = 10
    }
  }
}

function M.get_font(font)
  return wezterm.font(
    font.family_name,
    {
      weight = font.faces.Normal,
      italic = false,
    }
  )
end

function M.get_font_rules(font)
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

function M.setup_font(config, font_index)
  M.selected_font_index = font_index or M.selected_font_index
  local selected_font = M.fonts[M.selected_font_index]
  config.font = M.get_font(selected_font)
  config.font_rules = M.get_font_rules(selected_font)
  config.line_height = selected_font.line_height
  config.font_size = selected_font.size[wezterm.hostname()] or selected_font.size['default']
end

return M
