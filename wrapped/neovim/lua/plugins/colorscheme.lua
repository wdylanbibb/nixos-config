nixInfo.lze.load({
  {
    "trigger_colorscheme",
    event = "VimEnter",
    load = function (_name)
      vim.schedule(function ()
        vim.cmd.colorscheme(nixInfo("onedark_dark", "settings", "colorscheme"))
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
  }
})
