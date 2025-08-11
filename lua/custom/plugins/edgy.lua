return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    bottom = {
      "Trouble",
      "trouble",
      { ft = "qf", title = "QuickFix" },
      {
        ft = "help",
        size = { height = 20 },
        -- only show help buffers
        filter = function(buf)
          return vim.bo[buf].buftype == "help"
        end,
      },
    },
    right = {
      {
        --outline
        ft = "Outline",
        title = "Outline",
        size = { width = 40 },
        filter = function(buf)
          return vim.bo[buf].filetype == "Outline"
        end,
      }
    },
  }
}
