-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --

vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.wrap = true
vim.o.breakindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = false
vim.o.winborder = 'rounded'

-- ========================================================================== --
-- ==                             KEYBINDINGS                              == --
-- ========================================================================== --

-- Space as leader key
vim.g.mapleader = vim.keycode('<Space>')

-- Shortcuts
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>h', '^', { desc = 'Go to first character' })
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>l', 'g_', { desc = 'Go to last character' })

-- Basic clipboard interaction
vim.keymap.set({ 'n', 'x' }, 'gy', '"+y', { desc = 'Copy to clipboard' })
vim.keymap.set({ 'n', 'x' }, 'gp', '"+p', { desc = 'Paste from clipboard' })

-- Delete text
vim.keymap.set({ 'n', 'x' }, 'x', '"_x', { desc = 'Delete character' })
vim.keymap.set({ 'n', 'x' }, 'X', '"_d', { desc = 'Delete operator' })

-- ========================================================================== --
-- ==                               COMMANDS                               == --
-- ========================================================================== --

vim.api.nvim_create_user_command('ReloadConfig', 'source $MYVIMRC', {})

local group = vim.api.nvim_create_augroup('user_cmds', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight on yank',
    group = group,
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
    end,
})

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

local mini = {}

mini.branch = 'main'
mini.packpath = vim.fn.stdpath('data') .. '/site'

function mini.require_deps()
    local mini_path = mini.packpath .. '/pack/deps/start/mini.nvim'

    if not vim.uv.fs_stat(mini_path) then
        print('Installing mini.nvim....')
        vim.fn.system({
            'git',
            'clone',
            '--filter=blob:none',
            'https://github.com/nvim-mini/mini.nvim',
            string.format('--branch=%s', mini.branch),
            mini_path
        })

        vim.cmd('packadd mini.nvim | helptags ALL')
    end

    local ok, deps = pcall(require, 'mini.deps')
    if not ok then
        return {}
    end

    return deps
end

local MiniDeps = mini.require_deps()
if not MiniDeps.setup then
    return
end

-- See :help MiniDeps.config
MiniDeps.setup({
    path = {
        package = mini.packpath,
    },
})

MiniDeps.add('folke/tokyonight.nvim')
MiniDeps.add('folke/snacks.nvim')
MiniDeps.add('neovim/nvim-lspconfig')

-- See :help MiniDeps.add
MiniDeps.add({
    source = 'nvim-mini/mini.nvim',
    checkout = mini.branch,
})
MiniDeps.add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = {
        post_checkout = function()
            vim.cmd.TSUpdate()
        end,
    },
})
MiniDeps.add({
    source = 'saghen/blink.cmp',
    depends = { 'rafamadriz/friendly-snippets' },
    checkout = 'v1.7.0',
})


-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

-- See :help tokyonight.nvim-tokyo-night-configuration
require('tokyonight').setup({
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
    },
})

vim.o.termguicolors = true
vim.cmd.colorscheme('tokyonight')


-- See :help MiniStatusline.config
vim.o.showmode = false
require('mini.statusline').setup({ use_icons = true })

-- See :help MiniNotify.config
require('mini.notify').setup({
    lsp_progress = {
        enable = false,
    },
})

-- See :help MiniDiff.config
vim.o.signcolumn = 'yes'
require('mini.diff').setup({
    view = {
        style = 'sign',
        signs = {
            add = '▎',
            change = '▎',
            delete = '➤',
        },
    },
})

local mini_clue = require('mini.clue')

mini_clue.setup({
    window = {
        delay = 600,
        config = {
            width = 50,
        },
    },
    triggers = {
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
        { mode = 'n', keys = '<C-w>' },
        { mode = 'i', keys = '<C-x>' },
        { mode = 'n', keys = '<leader>' },
        { mode = 'x', keys = '<leader>' },
    },
    clues = {
        mini_clue.gen_clues.g(),
        mini_clue.gen_clues.z(),
        mini_clue.gen_clues.windows(),
        mini_clue.gen_clues.builtin_completion(),
        { mode = 'n', keys = '<leader>f', desc = '+Fuzzy finders' },
        { mode = 'n', keys = '<leader>b', desc = '+Buffer' },
    }
})

require('mini.pairs').setup({})


-- NOTE: the list of supported parsers is in the documentation
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local parsers = { 'lua', 'vim', 'vimdoc' }

local ts = vim.treesitter
local ts_installed = require('nvim-treesitter').get_installed()

local ts_filetypes = vim.iter(parsers)
    :map(ts.language.get_filetypes)
    :flatten()
    :fold({}, function(tbl, v)
        tbl[v] = vim.tbl_contains(ts_installed, v)
        return tbl
    end)

local ts_enable = function(buffer, lang)
    local ok, hl = pcall(ts.query.get, lang, 'highlights')
    if ok and hl then
        ts.start(buffer, lang)
    end
end

vim.api.nvim_create_autocmd('FileType', {
    desc = 'enable treesitter',
    callback = function(event)
        local ft = event.match
        local available = ts_filetypes[ft]
        if available == nil then
            return
        end

        local lang = ts.language.get_lang(ft)
        local buffer = event.buf

        if available then
            ts_enable(buffer, lang)
            return
        end

        require('nvim-treesitter').install(lang):await(function()
            ts_filetypes[ft] = true
            ts_enable(buffer, lang)
        end)
    end,
})

-- docs: https://github.com/folke/snacks.nvim/blob/main/README.md
local Snacks = require('snacks')

Snacks.setup({
    explorer = {
        enabled = true,
        replace_netrw = true,
    },
    picker = {
        enabled = true,
        ui_select = true,
        prompt = '❯ ',
        formatters = {
            file = { truncate = 78 },
        },
    },
})

-- docs: https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md
vim.keymap.set('n', '<leader>e', function()
    Snacks.explorer()
end, { desc = 'Toggle file explorer' })

-- docs: https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md
vim.keymap.set({ 'n', 't' }, '<C-g>', function()
    Snacks.terminal.toggle()
end, { desc = 'Toggle terminal window' })

-- Close while preserving window layout
-- docs: https://github.com/folke/snacks.nvim/blob/main/docs/bufdelete.md
vim.keymap.set('n', '<leader>bc', function()
    Snacks.bufdelete()
end, { desc = 'Close buffer' })

-- Fuzzy finders
-- docs: https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
vim.keymap.set('n', '<leader><space>', function() Snacks.picker('buffers') end, { desc = 'Search open files' })
vim.keymap.set('n', '<leader>ff', function() Snacks.picker('files') end, { desc = 'Search all files' })
vim.keymap.set('n', '<leader>fh', function() Snacks.picker('recent') end, { desc = 'Search file history' })
vim.keymap.set('n', '<leader>fg', function() Snacks.picker('grep') end, { desc = 'Search in project' })
vim.keymap.set('n', '<leader>fd', function() Snacks.picker('diagnostics') end, { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>fs', function() Snacks.picker('lines') end, { desc = 'Buffer local search' })
vim.keymap.set('n', '<leader>u', function() Snacks.picker('undo') end, { desc = 'Undo history' })
vim.keymap.set('n', '<leader>/', function() Snacks.picker('pickers') end, { desc = 'Search picker' })
vim.keymap.set('n', '<leader>?', function() Snacks.picker('keymaps') end, { desc = 'Search keymaps' })

-- Autocompletion
-- docs: https://cmp.saghen.dev/configuration/general.html
require('blink.cmp').setup({})

-- LSP setup
vim.lsp.enable({ 'gopls', 'rust_analyzer' })
