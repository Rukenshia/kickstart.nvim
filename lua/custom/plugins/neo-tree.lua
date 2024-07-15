return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  opts = {
    close_if_last_window = true,
  },
  keys = {
    { '\\', ':Neotree reveal left<CR>', desc = 'Neotree reveal' },
    { '<C-n>', ':Neotree toggle<CR>', desc = 'Neotree toggle' },
  },
}
