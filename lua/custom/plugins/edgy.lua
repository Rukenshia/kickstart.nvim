-- return {
--   'folke/edgy.nvim',
--   event = 'VeryLazy',
--   opts = {
--     animate = { cps = 240 },
--     bottom = {
--       'Trouble',
--       { ft = 'qf', title = 'QuickFix' },
--       {
--         ft = 'help',
--         size = { height = 20 }, -- only show help buffers
--         filter = function(buf)
--           return vim.bo[buf].buftype == 'help'
--         end,
--       },
--       { ft = 'spectre_panel', size = { height = 0.4 } },
--     },
--     left = {
--       -- Neo-tree filesystem always takes half the screen height
--       {
--         title = 'Neo-Tree',
--         ft = 'neo-tree',
--         filter = function(buf)
--           return vim.b[buf].neo_tree_source == 'filesystem'
--         end,
--         size = { height = 0.2 },
--       },
--       {
--         title = 'Neo-Tree Buffers',
--         ft = 'neo-tree',
--         filter = function(buf)
--           return vim.b[buf].neo_tree_source == 'buffers'
--         end,
--         pinned = true,
--         open = 'Neotree position=top buffers',
--         size = { height = 0.3 },
--       },
--       {
--         title = 'Neo-Tree Git',
--         ft = 'neo-tree',
--         filter = function(buf)
--           return vim.b[buf].neo_tree_source == 'git_status'
--         end,
--         open = 'Neotree position=right git_status',
--       }, -- any other neo-tree windows
--       'neo-tree',
--     },
--     right = { { ft = 'Outline', pinned = true, open = 'SymbolsOutline' } },
--     options = { left = { size = 50 }, right = { size = 50 }, exit_when_last = true },
--   },
--   keys = {
--     -- "|": focus the Neo-Tree Buffers window
--     { '|', ':lua require("edgy").open("left", "Neo-Tree Buffers")<CR>', desc = 'Neo-Tree Buffers' },
--   },
--   config = function(plugin, opts)
--     require('edgy').setup(opts)
--     -- require('edgy').open('left')
--     -- require('edgy').goto_main()
--   end,
-- }
return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  init = function()
    vim.opt.laststatus = 3
    vim.opt.splitkeep = 'screen'
  end,
  opts = {
    bottom = {
      -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
      {
        ft = 'toggleterm',
        size = { height = 0.4 },
        -- exclude floating windows
        filter = function(buf, win)
          return vim.api.nvim_win_get_config(win).relative == ''
        end,
      },
      {
        ft = 'lazyterm',
        title = 'LazyTerm',
        size = { height = 0.4 },
        filter = function(buf)
          return not vim.b[buf].lazyterm_cmd
        end,
      },
      'Trouble',
      { ft = 'qf', title = 'QuickFix' },
      {
        ft = 'help',
        size = { height = 20 },
        -- only show help buffers
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
        title = 'Neo-Tree Git',
        ft = 'neo-tree',
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'git_status'
        end,
        pinned = true,
        collapsed = true, -- show window as closed/collapsed on start
        open = 'Neotree position=right git_status',
      },
      {
        title = 'Neo-Tree Buffers',
        ft = 'neo-tree',
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'buffers'
        end,
        pinned = true,
        collapsed = false, -- show window as closed/collapsed on start
        open = 'Neotree position=top buffers',
      },
      {
        title = function()
          local buf_name = vim.api.nvim_buf_get_name(0) or '[No Name]'
          return vim.fn.fnamemodify(buf_name, ':t')
        end,
        ft = 'Outline',
        pinned = true,
        open = 'SymbolsOutlineOpen',
      },
      -- any other neo-tree windows
      'neo-tree',
    },
  },
}
