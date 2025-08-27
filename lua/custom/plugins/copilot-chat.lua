return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },                   -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken",                          -- Only on MacOS or Linux
    opts = {
      prompts = {
        Commit = {
          prompt = [[
            Write commit message for the change with conventional commits convention.
            Keep the title under 50 characters and wrap message at 72 characters.
            Format as a gitcommit code block.

            If user has COMMIT_EDITMSG opened, generate replacement block for whole buffer.
            Do not mention which files specifically were changed, keep the commit high-level.
          ]],
          resources = { 'gitdiff:staged', 'buffer' },
        },
      },
    },
    keys = {
      { "<leader>cct", "<cmd>CopilotChatToggle<CR>",  mode = "n", desc = "[c]opilot [c]hat [t]oggle" },
      { "<leader>cco", "<cmd>CopilotChatOpen<CR>",    mode = "n", desc = "[c]opilot [c]hat [o]pen" },
      { "<leader>ccs", "<cmd>CopilotChatStop<CR>",    mode = "n", desc = "[c]opilot [c]hat [s]top" },
      { "<leader>ccr", "<cmd>CopilotChatReset<CR>",   mode = "n", desc = "[c]opilot [c]hat [r]eset" },
      { "<leader>ccp", "<cmd>CopilotChatPrompts<CR>", mode = "n", desc = "[c]opilot [c]hat [p]rompts" },
      { "<leader>ccm", "<cmd>CopilotChatModels<CR>",  mode = "n", desc = "[c]opilot [c]hat [m]odels" },
      { "<leader>cca", "<cmd>CopilotChatAgents<CR>",  mode = "n", desc = "[c]opilot [c]hat [a]gents" },
      { "<leader>ccc", "<cmd>CopilotChatCommit<CR>",  mode = "n", desc = "[c]opilot [c]hat [c]ommit" },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
