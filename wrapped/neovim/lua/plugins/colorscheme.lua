local function transparent_background()
  local groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

local function notify_background()
  local background = "#000000"

  for _, group in ipairs({ "NormalFloat", "Pmenu", "Normal" }) do
    local ok, highlight = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and highlight.bg then
      background = string.format("#%06x", highlight.bg)
      break
    end
  end

  vim.api.nvim_set_hl(0, "NotifyBackground", { bg = background })
end

local function color_overrides()
  transparent_background()
  notify_background()
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparent-background", { clear = true }),
  callback = color_overrides,
})

nixInfo.lze.load({
  {
    "trigger_colorscheme",
    event = "VimEnter",
    load = function (_name)
      vim.schedule(function ()
        vim.cmd.colorscheme(nixInfo("onedark_dark", "settings", "colorscheme"))
        color_overrides()
      end)
    end
  },
  {
    "onedarkpro.nvim",
    auto_enable = true,
    colorscheme = { "onedark", "onedark_dark", "onedark_vivid", "onelight" }
  },
  {
    "tokyonight.nvim",
    auto_enable = true,
    colorscheme = { "tokyonight", "tokyonight-night", "tokyonight-moon", "tokyonight-storm", "tokyonight-day" }
  },
  {
    "oxocarbon.nvim",
    auto_enable = true,
    colorscheme = { "oxocarbon" }
  }
})
