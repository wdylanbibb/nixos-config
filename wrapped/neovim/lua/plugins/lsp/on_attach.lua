return function(client, bufnr)
	local function should_attach()
		-- Skip non-file buffers
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
		if buftype ~= "" then
			return false
		end

		-- Skip unlisted buffers
		if not vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then
			return false
		end

		local excluded_filetypes = {
			"neo-tree",
			"toggleterm",
			"help",
			"man",
			"gitcommit",
			"gitrebase",
			"fugitive",
			"TelescopePrompt",
		}
		local ft = vim.bo[bufnr].filetype
		if vim.tbl_contains(excluded_filetypes, ft) then
			return false
		end

		-- Skip diff views (by checking all windows displaying this buffer)
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == bufnr then
				if vim.api.nvim_get_option_value("diff", { win = win }) then
					return false
				end
			end
		end

		return true
	end

	if not should_attach() then
		client.stop()
		return
	end

	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("gr", function()
		Snacks.picker.lsp_references()
	end, "[G]oto [R]eferences")
	nmap("gI", function()
		Snacks.picker.lsp_implementations()
	end, "[G]oto [I]mplementation")
	nmap("<leader>ds", function()
		Snacks.picker.lsp_symbols()
	end, "[D]ocument [S]ymbols")
	nmap("<leader>ws", function()
		Snacks.picker.lsp_workspace_symbols()
	end, "[W]orkspace [S]ymbols")
	nmap("]]", function()
		Snacks.words.jump(vim.v.count1)
	end, "Next Reference")
	nmap("[[", function()
		Snacks.words.jump(-vim.v.count1)
	end, "Prev Reference")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("gK", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })

	vim.lsp.inlay_hint.enable(true)
end
