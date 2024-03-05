return {
  'folke/edgy.nvim',
  cond = vim.g.vscode,
  event = 'VeryLazy',
  opts = {
    animate = { cps = 240 },
    bottom = {
      'Trouble',
      { ft = 'qf', title = 'QuickFix' },
      {
        ft = 'help',
        size = { height = 20 }, -- only show help buffers
        filter = function(buf)
          return vim.bo[buf].buftype == 'help'
        end,
      },
      { ft = 'spectre_panel', size = { height = 0.4 } },
    },
    left = {
      -- Neo-tree filesystem always takes half the screen height
      {
        title = 'Neo-Tree',
        ft = 'neo-tree',
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'filesystem'
        end,
        size = { height = 0.5 },
      },
      {
        title = 'Neo-Tree Buffers',
        ft = 'neo-tree',
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'buffers'
        end,
        pinned = true,
        open = 'Neotree position=top buffers',
        size = { height = 0.3 },
      },
      {
        title = 'Neo-Tree Git',
        ft = 'neo-tree',
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'git_status'
        end,
        open = 'Neotree position=right git_status',
      }, -- any other neo-tree windows
      'neo-tree',
    },
    right = { { ft = 'Outline', pinned = true, open = 'SymbolsOutline' } },
    options = { left = { size = 50 }, exit_when_last = true },
  },
  config = function(plugin, opts)
    require('edgy').setup(opts)
    -- require('edgy').open('left')
    -- require('edgy').goto_main()
  end,
}
