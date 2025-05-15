local M = {}

function M.setup(opts)
  opts = opts or {}
  opts.save_mode = opts.save_mode or "immediate"
  opts.save_interval = opts.save_interval or 300

  local keybind_file = vim.fn.stdpath("data") .. "/keybind_usage.json"
  
  -- Initialize the keybind data structure
  local keybind_data = {
    mappings = {},
    total_count = 0,
    first_tracked = os.time(),
    last_tracked = os.time()
  }
  
  -- Try to load existing data
  local file = io.open(keybind_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    if content and content ~= "" then
      local ok, data = pcall(vim.json.decode, content)
      if ok and data then
        keybind_data = data
      end
    end
  end
  
  -- Function to save keybind usage data
  local function save_keybind_usage()
    local file = io.open(keybind_file, "w")
    if file then
      file:write(vim.json.encode(keybind_data))
      file:close()
    end
  end
  
  -- Save data periodically if requested
  if opts.save_mode == "periodic" then
    local timer = vim.loop.new_timer()
    timer:start(1000, opts.save_interval * 1000, vim.schedule_wrap(function()
      save_keybind_usage()
    end))
  end

  -- Track normal mode mappings
  vim.on_key(function(key)
    if vim.fn.mode() ~= "n" then
      return
    end
    
    local key_str = vim.fn.keytrans(key)
    
    -- Check if this has a valid mapping
    local mapping = vim.fn.maparg(key_str, "n")
    if type(mapping) ~= "string" or mapping == "" then
      return
    end
    
    -- Initialize mapping data if it doesn't exist
    if not keybind_data.mappings[key_str] then
      keybind_data.mappings[key_str] = {
        count = 0,
        first_used = os.time(),
        last_used = os.time(),
        modes = { n = 0 }
      }
    end
    
    -- Update stats
    keybind_data.mappings[key_str].count = keybind_data.mappings[key_str].count + 1
    keybind_data.mappings[key_str].last_used = os.time()
    keybind_data.mappings[key_str].modes.n = (keybind_data.mappings[key_str].modes.n or 0) + 1
    keybind_data.total_count = keybind_data.total_count + 1
    keybind_data.last_tracked = os.time()
    
    -- Save immediately if requested
    if opts.save_mode == "immediate" then
      save_keybind_usage()
    end
  end)
  
  -- Ensure data is saved when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      save_keybind_usage()
    end,
  })

  -- Add commands to view keybind statistics
  vim.api.nvim_create_user_command("KeybindReport", function()
    _ = require("custom.keybind_stats")
  end, {})

  vim.api.nvim_create_user_command("KeybindClear", function()
    keybind_data = {
      mappings = {},
      total_count = 0,
      first_tracked = os.time(),
      last_tracked = os.time()
    }
    save_keybind_usage()
    vim.notify("Keybind usage data cleared")
  end, {})
end

return M