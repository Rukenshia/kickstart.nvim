return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },                   -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken",                          -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    keys = {
      { "<leader>cct", "<cmd>CopilotChatToggle<CR>",  mode = "n", desc = "[c]opilot [c]hat [t]oggle" },
      { "<leader>cco", "<cmd>CopilotChatOpen<CR>",    mode = "n", desc = "[c]opilot [c]hat [o]pen" },
      { "<leader>ccs", "<cmd>CopilotChatStop<CR>",    mode = "n", desc = "[c]opilot [c]hat [s]top" },
      { "<leader>ccr", "<cmd>CopilotChatReset<CR>",   mode = "n", desc = "[c]opilot [c]hat [r]eset" },
      { "<leader>ccp", "<cmd>CopilotChatPrompts<CR>", mode = "n", desc = "[c]opilot [c]hat [p]rompts" },
      { "<leader>ccm", "<cmd>CopilotChatModels<CR>",  mode = "n", desc = "[c]opilot [c]hat [m]odels" },
      { "<leader>cca", "<cmd>CopilotChatAgents<CR>",  mode = "n", desc = "[c]opilot [c]hat [a]gents" },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
