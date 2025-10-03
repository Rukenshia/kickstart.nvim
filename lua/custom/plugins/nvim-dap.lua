return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('dapui').setup {}
      require('nvim-dap-virtual-text').setup {
        commented = true, -- Show virtual text alongside comment
      }

      vim.fn.sign_define('DapBreakpoint', {
        text = '',
        texthl = 'DiagnosticSignError',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapBreakpointRejected', {
        text = '', -- or "❌"
        texthl = 'DiagnosticSignError',
        linehl = '',
        numhl = '',
      })

      vim.fn.sign_define('DapStopped', {
        text = '', -- or "→"
        texthl = 'DiagnosticSignWarn',
        linehl = 'Visual',
        numhl = 'DiagnosticSignWarn',
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end

      local function opts(description)
        return { desc = 'Debug: ' .. description, noremap = true, silent = true }
      end

      -- Toggle breakpoint
      vim.keymap.set('n', '<leader>Db', function()
        dap.toggle_breakpoint()
      end, opts 'Toggle breakpoint')

      -- Continue / Start
      vim.keymap.set('n', '<leader>Dc', function()
        dap.continue()
      end, opts 'Continue')

      -- Step Over
      vim.keymap.set('n', '<leader>Do', function()
        dap.step_over()
      end, opts 'Step Over')

      -- Step Into
      vim.keymap.set('n', '<leader>Di', function()
        dap.step_into()
      end, opts 'Step Into')

      -- Step Out
      vim.keymap.set('n', '<leader>DO', function()
        dap.step_out()
      end, opts 'Step Out')

      -- Keymap to terminate debugging
      vim.keymap.set('n', '<leader>Dq', function()
        require('dap').terminate()
      end, opts 'Terminate')

      -- Toggle DAP UI
      vim.keymap.set('n', '<leader>Du', function()
        dapui.toggle()
      end, opts 'Toggle DAP UI')
    end,
  },
}
