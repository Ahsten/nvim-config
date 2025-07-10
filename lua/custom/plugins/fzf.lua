return {
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = {},
    keys = {
      { '<leader>sh', '<cmd>FzfLua helptags<cr>', desc = '[S]earch [H]elp' },
      { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = '[S]earch [K]eymaps' },
      { '<leader>sf', '<cmd>FzfLua files<cr>', desc = '[S]earch [F]iles' },
      { '<leader>sw', '<cmd>FzfLua grep_cword<cr>', desc = '[S]earch Current [W]ord' },
      { '<leader>sg', '<cmd>FzfLua grep<cr>', desc = '[S]earch [G]rep' },
      { '<leader>sr', '<cmd>FzfLua resume<cr>', desc = '[S]earch [R]esume' },
      { '<leader>s.', '<cmd>FzfLua oldfiles<cr>', desc = '[S]earch Recent Files' },
      { '<leader><leader>', '<cmd>FzfLua buffers<cr>', desc = '[ ] Find existing buffers' },
    },
  },
}
