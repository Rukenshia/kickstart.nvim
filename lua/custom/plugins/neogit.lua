return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim', -- optional
  },
  config = true,
  keys = {
    { '<leader>gg', '<cmd>Neogit<CR>', desc = 'Neo[g]it' },
    { '<leader>gc', '<cmd>Neogit commit<CR>', desc = 'Neogit [c]ommit' },
  },
}
