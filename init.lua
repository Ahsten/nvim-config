-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'
vim.o.cursorline = true

-- Space as leader key
vim.g.mapleader = vim.keycode('<Space>')

-- Basic clipboard interaction
vim.keymap.set({ 'n', 'x' }, 'gy', '"+y', { desc = 'Copy to clipboard' })
vim.keymap.set({ 'n', 'x' }, 'gp', '"+p', { desc = 'Paste clipboard content' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- ========================================================================== --
-- ==                               COMMANDS                               == --
-- ========================================================================== --

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight on yank',
	callback = function()
		vim.highlight.on_yank({higroup = 'Visual', timeout = 200})
	end,
})

vim.api.nvim_create_autocmd("FileType",{
	pattern = "snacks_picker_input",
	desc = "Disable mini.completion for snacks picker",
	group = vim.api.nvim_create_augroup("user_mini",{}),
	command = "lua vim.b.minicompletion_disable=true",
})

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

-- NOTE: To install a plugin you just need to add the URL to the repository.
-- But as soon as you need to add more information, like the git branch or
-- commit, use the "plugin spec" form. See :help vim.pack

vim.pack.add({
	'https://github.com/folke/tokyonight.nvim',
	'https://github.com/ellisonleao/gruvbox.nvim',
	'https://github.com/folke/which-key.nvim',
	'https://github.com/folke/snacks.nvim',
	'https://github.com/neovim/nvim-lspconfig',
	{ src = 'https://github.com/nvim-mini/mini.nvim',             version = 'main' },
})

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --
require("gruvbox").setup({
    overrides = {
			Function = { fg = "#fabd2f"},
			String = { fg = "#fe8019"},
			Preproc = { fg = "#fb4934" },
    }
})
vim.cmd.colorscheme('gruvbox')

-- See :help MiniSurround.config
require('mini.surround').setup({})

require('mini.pairs').setup({})

-- See :help MiniNotify.config
require('mini.notify').setup({
	lsp_progress = { enable = false },
})

local Snacks = require('snacks')

Snacks.setup({
	explorer = { enabled = true, replace_netrw = true },
	picker = {
		enabled = true,
	},
})

vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files({ ignored = false}) end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Find Help" })
vim.keymap.set("n", "<leader>/", function() Snacks.picker.grep({ ignored = false }) end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
vim.keymap.set("n", "<leader>r", function() Snacks.picker.resume() end, { desc = "Resume" })
vim.keymap.set("n", "<leader>e", function() Snacks.picker.explorer() end, { desc = "Explorer" })


-- See :help MiniStatusline.config
require('mini.statusline').setup({})

-- See :help MiniCompletion.config
require('mini.completion').setup({
	lsp_completion = {
		source_func = 'omnifunc',
	},
})

-- See :help which-key.nvim-which-key-setup
require('which-key').setup({
	preset = "helix",
	icons = {
		mappings = false,
		keys = {
			Space = 'Space',
			Esc = 'Esc',
			BS = 'Backspace',
			C = 'Ctrl-',
		},
	},
})

require('which-key').add({
	{ '<leader>f', group = 'Fuzzy Find' },
	{ '<leader>b', group = 'Buffer' },
})



local lsp_servers = {
	lua_ls = {
		-- https://luals.github.io/wiki/settings/ | `:h nvim_get_runtime_file`
		Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) }, },
	},
	-- clangd = {},
	-- rust_analyzer = {},
	-- gopls = {},
	-- zls = {},
	-- ts_ls = {},
	-- denols = {
	-- 	root_markers = { "deno.json", "deno.jsonc" },
	-- 	settings = {},
	-- },
}

vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig", -- default configs for lsps

	"https://github.com/mason-org/mason.nvim",                     -- package manager
	"https://github.com/mason-org/mason-lspconfig.nvim",           -- lspconfig bridge
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" -- auto installer
}, { confirm = false })

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = vim.tbl_keys(lsp_servers),
})

-- configure each lsp server on the table
-- to check what clients are attached to the current buffer, use
-- `:checkhealth vim.lsp`. to view default lsp keybindings, use `:h lsp-defaults`.
for server, config in pairs(lsp_servers) do
	vim.lsp.config(server, {
		settings = config,

		-- only create the keymaps if the server attaches successfully
		on_attach = function(_, bufnr)
			vim.keymap.set("n", "grd", vim.lsp.buf.definition,
			{ buffer = bufnr, desc = "vim.lsp.buf.definition()", })

			vim.keymap.set("n", "grf", vim.lsp.buf.format,
			{ buffer = bufnr, desc = "vim.lsp.buf.format()", })
		end,
	})
end

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
})


vim.lsp.enable({
	"lua_ls",
	-- "ts_ls",
	-- "zls",
	-- "gopls",
	-- "denols",
})
