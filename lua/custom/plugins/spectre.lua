return {
  'nvim-pack/nvim-spectre',
  cmd = { 'Spectre' },
  keys = {
    { 'n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', desc = 'Toggle Spectre' },
  },
}
