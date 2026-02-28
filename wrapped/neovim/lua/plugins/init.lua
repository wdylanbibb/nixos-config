-- [[ General Plugins ]]
nixInfo.lze.load({
  {
    "noice.nvim",
    event = "VimEnter",
    after = function (plugin)
      require("noice").setup({
        lsp = {
          override = {
            [ "vim.lsp.util.convert_input_to_markdown_lines" ] = true,
            [ "vim.lsp.util.stylize_markdown" ] = true,
            [ "cmp.entry.get_documentation" ] = true
          }
        },
        presets = {
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true
        }
      })
    end
  },
  {
    "nvim-notify",
    after = function (plugin)
      require("notify").setup({})
      vim.notify = require("notify")
    end
  },
  {
    "better-escape.nvim",
    lazy = false,
    auto_enable = true,
    after = function (plugin)
      require("better_escape").setup({
        mappings = {
          i = { j = { j = false } },
          c = { j = { j = false } },
          v = { j = { k = false } },
          t = { j = { k = false } },
        }
      })
    end
  },
  {
    "mini.nvim",
    lazy = false,
    auto_enable = true,
    after = function (plugin)
      -- Better Around/Inside text objects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup({
        mappings = {
          add = "gsa",
          delete = "gsd",
          find = "gsf",
          find_left = "gsF",
          highlights = "gsh",
          replace = "gsr",
          update_n_lines = "gsn"
        }
      })
      require("mini.icons").setup()
      require("mini.pairs").setup({
        modes = { insert = true, command = true, terminal = false },
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        skip_ts = { "string" },
        skip_unbalanced = true,
        markdown = true
      })
    end
  },
  {
    "nvim-treesitter",
    lazy = false,
    auto_enable = true,
    after = function (plugin)
      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        -- check if parser exists and load it
        if not vim.treesitter.language.add(language) then
          return false
        end
        -- enables syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- enables treesitter based folds
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        -- ensure folds are open to begin with
        vim.o.foldlevel = 99

        -- enables treesitter based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        return true
      end

      local installable_parsers = require("nvim-treesitter").get_available()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function (args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          if not treesitter_try_attach(buf, language) then
            if vim.tbl_contains(installable_parsers, language) then
              -- not already installed, so try to install them via nvim-treesitter if possible
              require("nvim-treesitter").install(language):await(function ()
                treesitter_try_attach(buf, language)
              end)
            end
          end
        end
      })
    end
  },
  {
    "nvim-treesitter-textobjects",
    auto_enable = true,
    lazy = false,
    before = function (plugin)
      -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main?tab=readme-ov-file#using-a-package-manager
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true

      -- Or, disable per filetype (add as you like)
      -- vim.g.no_python_maps = true
      -- vim.g.no_ruby_maps = true
      -- vim.g.no_rust_maps = true
      -- vim.g.no_go_maps = true
    end,
    after = function (plugin)
      require("nvim-treesitter-textobjects").setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true or false
          include_surrounding_whitespace = false,
        }
      }

      -- keymaps
      -- You can use the capture groups defined in `textobjects.scm`
      vim.keymap.set({ "x", "o" }, "am", function ()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "im", function ()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function ()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function ()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
      end)
      -- You can also use captures from other query groups like `locals.scm`
      vim.keymap.set({ "x", "o" }, "as", function ()
        require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
      end)

      -- NOTE: for more textobjects options, see the following link.
      -- This template is using the new `main` branch of the repo.
      -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    end
  },
  {
    "conform.nvim",
    auto_enable = true,
    keys = {
      { "<leader>FF", desc = "[F]ormat [F]ile" }
    },
    after = function (plugin)
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = nixInfo(nil, "settings", "cats", "lua") and { "stylua" } or nil,
        }
      })

      vim.keymap.set({ "n", "v" }, "<leader>FF", function ()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[F]ormat [F]ile" })
    end
  },
  {
    "nvim-lint",
    auto_enable = true,
    event = "FileType",
    after = function (plugin)
      require("lint").linters_by_ft = { }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function ()
          require("lint").try_lint()
        end
      })
    end
  },
  {
    "nvim-surround",
    auto_enable = true,
    cmd = { "StartupTime" },
    before = function (plugin)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, "progpath")
    end
  },
  {
    "fidget.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function (plugin)
      require("fidget").setup({})
    end
  },
  {
    "lualine.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function (plugin)
      require("lualine").setup({
        options = {
          icons_enabled = false,
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_c = {
            { "filename", path = 1, status = true },
            { require("recorder").recordingStatus },
          },
          lualine_x = {
            { require("recorder").displaySlots },
            { "encoding" },
            { "fileformat" },
            { "filetype" }
          },
        },
        inactive_sections = {
          lualine_b = {
            { "filename", path = 3, status = true },
          },
          lualine_x = { "filetype" },
        },
        tabline = {
          lualine_a = { "buffers" },
          lualine_z = { "tabs" },
        }
      })
    end
  },
  {
    "gitsigns.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function (plugin)
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" }
        },
        on_attach = function (bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or { }
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ "n", "v" }, "]c", function ()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function ()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to next hunk" })

          map({ "n", "v" }, "[c", function ()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function ()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to previous hunk" })

          -- Actions
          -- visual mode
          map("v", "<leader>hs", function ()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Stage git hunk" })
          map("v", "<leader>hr", function ()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Reset git hunk" })
          -- normal mode
          map("n", "<leader>gs", gs.stage_hunk, { desc = "Git stage hunk" })
          map("n", "<leader>gr", gs.reset_hunk, { desc = "Git reset hunk" })
          map("n", "<leader>gS", gs.stage_buffer, { desc = "Git stage buffer" })
          map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git undo stage hunk" })
          map("n", "<leader>gR", gs.reset_buffer, { desc = "Git reset buffer" })
          map("n", "<leader>gp", gs.preview_hunk, { desc = "Git preview hunk" })
          map("n", "<leader>gb", function ()
            gs.blame_line({ full = false })
          end, { desc = "Git blame line" })
          map("n", "<leader>gd", gs.diffthis, { desc = "Git diff against index" })
          map("n", "<leader>gD", function ()
            gs.diffthis("~")
          end, { desc = "Git diff against last commit" })

          -- Toggles
          map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle git blame line" })
          map("n", "<leader>gtd", gs.toggle_deleted, { desc = "Toggle git show deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
        end
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end
  },
  {
    "which-key.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function (plugin)
      require("which-key").setup({})
      require("which-key").add({
        { "<leader><leader>", group = "Buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>m", group = "[m]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
      })
    end
  },
  {
    "dropbar.nvim",
    event = "DeferredUIEnter",
    after = function (plugin)
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end
  },
  {
    "nvim-recorder",
    event = "VimEnter",
    dep_of = { "lualine.nvim" },
    after = function (plugin)
      require("recorder").setup({
        useNerdfontIcons = false,
        lessNotifications = true,
      })
    end
  },
  {
    "nvim-colorizer.lua",
    event = "VimEnter",
    after = function (plugin)
      require("colorizer").setup()
    end
  }
})

require("plugins.colorscheme")
require("plugins.snacks")
require("plugins.lsp")
require("plugins.completion")
