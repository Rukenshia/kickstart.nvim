return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    gitbrowse = { enabled = true },
    git = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    scroll = { enabled = true },
    indent = { enabled = true, animate = { duration = { step = 20, total = 200 } } },
    zen = { enabled = true },
    toggle = { enabled = true },
    dashboard = {
      enabled = true,

      sections = {
        { section = 'header' },
        { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        { section = 'startup' },
      },
    },

    dim = { enabled = true },
  },
  keys = {
    { '<leader>gb', ':lua require("snacks").git.blame_line()<CR>', silent = true, desc = 'Git [b]lame' },
    { '<leader>go', ':lua require("snacks").gitbrowse.open()<CR>', silent = true, desc = 'Git [o]pen browser' },

    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>f.',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },

    { '<leader>vd', ':lua require("snacks").dim()<CR>', silent = true, desc = 'Dim' },
    { '<leader>vr', ':lua require("snacks").dim.disable()<CR>', silent = true, desc = 'Reset dim' },
    { '<leader>vz', ':lua require("snacks").zen.zen()<CR>', silent = true, desc = 'Zen' },
  },
}
