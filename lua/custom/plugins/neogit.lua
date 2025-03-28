return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim', -- optional
  },
  config = function()
    require('neogit').setup {
      graph_style = 'kitty',
    }
  end,
  keys = {
    { '<leader>G', '<cmd>Neogit<CR>', desc = 'Neo[g]it' },
  },
}
