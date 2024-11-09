return {
  'MeanderingProgrammer/markdown.nvim',
  name = 'render-markdown',
  lazy = true,
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = { 'markdown', 'Avante' },

  config = function()
    -- define highlight groups
    vim.api.nvim_command [[
      hi MarkdownHeading1 guifg=#c5e0e5 guibg=#2a545e
      hi MarkdownHeading2 guifg=#74a595 guibg=#1c3d32
      hi MarkdownHeading3 guifg=#5b6a8e guibg=#1c263d
      hi MarkdownHeadingSymbol1 guifg=#ff0000
    ]]
    require('render-markdown').setup {
      file_types = { 'markdown', 'Avante' },
      headings = { 'h.', 'h2.', 'h3.', 'h4.', 'h5.', 'h6.' },
      highlights = {
        heading = {
          backgrounds = {
            'MarkdownHeading1',
            'MarkdownHeading2',
            'MarkdownHeading3',
          },

          foregrounds = {
            'MarkdownHeadingSymbol1',
            'markdownH2',
            'markdownH3',
            'markdownH4',
            'markdownH5',
          },
        },
      },
    }
  end,
}
