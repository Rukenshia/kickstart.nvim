return {
  'zbirenbaum/copilot.lua',
  enabled = true,
  lazy = false,
  keys = {
    {
      '<leader>ct',
      '<cmd>lua require("copilot.suggestion").toggle_auto_trigger()<CR><cmd>lua require("snacks").notify.info("Copilot suggestions toggled")<CR>',
      mode = 'n',
      desc = '[t]oggle completion',
    },
  },
  config = function()
    require('copilot').setup {
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<C-y>',
          refresh = 'gr',
          open = '<M-CR>',
        },
        layout = {
          position = 'bottom', -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,

        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = '<C-y>',
          accept_word = false,
          accept_line = false,
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
      copilot_node_command = os.getenv 'NODE_LTS',
      server_opts_overrides = {},
      filetypes = { markdown = true, gitcommit = true, yaml = true },
    }
  end,
}
