-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Keymaps for better default experience
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Down" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })

vim.keymap.set("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = 'Previous buffer' })
vim.keymap.set("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = 'Next buffer' })
vim.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = 'Last buffer' })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic list" })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })

-- Use SHIFT+<hl> to switch between buffers
vim.keymap.set("n", "<S-h>", "<cmd>bp<CR>", { desc = "Move focus to the previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bn<CR>", { desc = "Move focus to the next buffer" })

-- Use CTRL+<hjkl> to switch between nvim or kitty windows
-- https://github.com/MunsMan/kitty-navigator.nvim/blob/main/lua/kitty-navigator/init.lua
local mappings = { h = "left", j = "bottom", k = "top", l = "right" }

local function navigate(direction)
  local left_win = vim.fn.winnr("1" .. direction)
  if vim.fn.winnr() ~= left_win then
    vim.api.nvim_command("wincmd " .. direction)
  else
    local command = "kitten @ kitten navigate_kitty.py " .. mappings[direction]
    vim.fn.system(command)
  end
end

local function navigateLeft()
  navigate("h")
end


local function navigateRight()
  navigate("l")
end

local function navigateUp()
  navigate("k")
end

local function navigateDown()
  navigate("j")
end

vim.keymap.set("n", "<C-h>", navigateLeft, { silent = true })
vim.keymap.set("n", "<C-l>", navigateRight, { silent = true })
vim.keymap.set("n", "<C-k>", navigateUp, { silent = true })
vim.keymap.set("n", "<C-j>", navigateDown, { silent = true })
