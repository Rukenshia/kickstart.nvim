return {
  'olimorris/persisted.nvim',
  lazy = true, -- make sure the plugin is always loaded at startup
  config = function()
    require('persisted').setup()

    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistedSavePre',
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].filetype == 'neo-tree' or vim.bo[buf].filetype == 'Outline' then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    })
  end,
}
