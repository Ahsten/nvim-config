-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --

-- Learn more about Neovim lua api
-- https://neovim.io/doc/user/lua-guide.html
-- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/

vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'

-- Space as leader key
vim.g.mapleader = vim.keycode('<Space>')

-- Basic clipboard interaction
vim.keymap.set({'n', 'x'}, 'gy', '"+y', {desc = 'Copy to clipboard'})
vim.keymap.set({'n', 'x'}, 'gp', '"+p', {desc = 'Paste clipboard content'})

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

-- NOTE: To install a plugin you just need to add the URL to the repository.
-- But as soon as you need to add more information, like the git branch or 
-- commit, use the "plugin spec" form. See :help vim.pack

vim.pack.add({
  'https://github.com/savq/melange-nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/VonHeikemen/ts-enable.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  {src = 'https://github.com/nvim-mini/mini.nvim', version = 'main'},
  {src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main'},
})

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

vim.cmd.colorscheme('melange')

-- See :help MiniSurround.config
require('mini.surround').setup({})

require('mini.pairs').setup({})

-- See :help MiniNotify.config
require('mini.notify').setup({
  lsp_progress = {enable = false},
})

-- See :help MiniBufremove.config
require('mini.bufremove').setup({})

-- Close buffer and preserve window layout
vim.keymap.set('n', '<leader>bc', '<cmd>lua pcall(MiniBufremove.delete)<cr>', {desc = 'Close buffer'})

require('snacks').setup({
	explorer = { enabled = true, replace_netrw = true },
	picker = { enabled = true },
	keys = {

	},
})


vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, {desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, {desc = "Find Config File"})
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, {desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function() Snacks.picker.git_files() end, {desc = "Find Git Files"})
vim.keymap.set("n", "<leader>fp", function() Snacks.picker.projects() end, {desc = "Projects" })
vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, {desc = "Recent" })
vim.keymap.set("n", "<leader>e", function() Snacks.picker.explorer() end, {desc = "Explorer"})


-- See :help MiniStatusline.config
require('mini.statusline').setup({})

-- See :help MiniCompletion.config
require('mini.completion').setup({
  lsp_completion = {
    source_func = 'omnifunc',
    auto_setup = false,
  },
})

-- See :help which-key.nvim-which-key-setup
require('which-key').setup({
  preset = 'helix',
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
  {'<leader>f', group = 'Fuzzy Find'},
  {'<leader>b', group = 'Buffer'},
})

-- Treesitter setup
-- NOTE: the list of supported parsers is in the documentation:
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local ts_parsers = {'lua', 'vim', 'vimdoc', 'c', 'query'}

-- See :help ts-enable-config
vim.g.ts_enable = {
  parsers = ts_parsers,
  auto_install = true,
  highlights = true,
}

-- Try to update all parsers after a plugin update
vim.api.nvim_create_autocmd('PackChanged', {
  pattern = 'nvim-treesitter',
  desc = 'Update treesitter parsers',
  command = 'TSUpdate'
})

-- LSP setup
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'grd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set({'n', 'x'}, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)

    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)

    if client and client:supports_method('textDocument/completion') then
      vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    end
  end,
})

