nixInfo.lze.load({
	{
		"cmp-cmdline",
		auto_enable = true,
		on_plugin = { "blink.cmp" },
		load = nixInfo.lze.loaders.with_after,
	},
	{
		"blink.compat",
		auto_enable = true,
		dep_of = { "cmp-cmdline" },
	},
	{
		"colorful-menu.nvim",
		auto_enable = true,
		on_plugin = { "blink.cmp" },
	},
	{
		"luasnip",
		dep_of = { "blink.cmp", "friendly-snippets" },
		after = function(plugin)
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			luasnip.config.setup({})
		end,
	},
	{
		"blink.cmp",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("blink.cmp").setup({
				keymap = {
					preset = "default",
				},
				cmdline = {
					enabled = true,
					completion = {
						menu = {
							auto_show = true,
						},
					},
					sources = function()
						local type = vim.fn.getcmdtype()
						-- Search forward and backward
						if type == "/" or type == "?" then
							return { "buffer" }
						end
						-- Commands
						if type == ":" or type == "@" then
							return { "cmdline", "cmp_cmdline" }
						end
						return {}
					end,
				},
				fuzzy = {
					sorts = {
						"exact",
						"score",
						"sort_text",
					},
				},
				signature = {
					enabled = true,
					window = {
						show_documentation = true,
					},
				},
				completion = {
					accept = {
						auto_brackets = {
							enabled = true,
						},
					},
					menu = {
						border = "rounded",
						draw = {
							treesitter = { "lsp" },
							components = {
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
							},
						},
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
					},
					documentation = {
						auto_show = true,
						window = { border = "rounded" },
					},
				},
        snippets = {
          preset = "luasnip",
          active = function (filter)
            local snippet = require("luasnip")
            local blink = require("blink.cmp")
            if snippet.in_snippet() and not blink.is_visible() then
              return true
            else
              if not snippet.in_snippet() and vim.fn.mode() == "n" then
                snippet.unlink_current()
              end
              return false
            end
          end
        },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = {
						path = { score_offset = 50, },
						lsp = { score_offset = 40, },
            snippets = { score_offset = 40 },
						cmp_cmdline = {
							name = "cmp_cmdline",
							module = "blink.compat.source",
							score_offset = -100,
							opts = { cmp_name = "cmdline", },
						},
					},
				},
			})
		end,
	},
})
