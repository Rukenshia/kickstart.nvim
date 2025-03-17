return {
  'olimorris/persisted.nvim',
  lazy = true, -- make sure the plugin is always loaded at startup
  config = function()
    require('persisted').setup()

    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistedSavePre',
      callback = function()
        -- close DAP UI if it's open
        require('dapui').close()

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          -- remove unnamed buffers
          if vim.api.nvim_buf_get_name(buf) == '' then
            vim.api.nvim_buf_delete(buf, { force = true })
            return
          end

          if vim.bo[buf].filetype == 'neo-tree' or vim.bo[buf].filetype == 'Outline' or vim.api.nvim_buf_get_name(buf):find 'neo-tree' then
            vim.api.nvim_buf_delete(buf, { force = true })
            return
          end
        end
      end,
    })
  end,
}
