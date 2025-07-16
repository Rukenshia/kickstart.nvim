return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    -- "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "fredrikaverpil/neotest-golang", version = "*" },
    { "nvim-neotest/neotest-python",   version = "*" },
    { "nvim-neotest/neotest-jest",     version = "*" },
  },
  config = function()
    local neotest_golang_opts = {} -- Specify custom configuration
    require("neotest").setup({
      adapters = {
        require("neotest-golang")(neotest_golang_opts), -- Registration
        require("neotest-python")({
          dap = { justMyCode = false },                 -- Enable debugging with DAP
        }),
        require("neotest-jest")({
          jestCommand = "npm test --",
          env = { CI = true },     -- Set environment variables
          cwd = function(path)
            return vim.fn.getcwd() -- Use current working directory
          end,
        }),
      },
    })
  end,
  keys = {
    {
      "<leader>tn",
      function()
        require("neotest").run.run()
      end,
      desc = "Run Neotest",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle Neotest Summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open({ enter = true })
      end,
      desc = "Open Neotest Output",
    },
    {
      "<leader>tw",
      function()
        require("neotest").watch.watch()
      end,
      desc = "Watch Neotest",
    }
  },

}
