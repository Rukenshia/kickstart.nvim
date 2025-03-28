-- A module to track keybind usage over time
local M = {}

-- Get the user's data directory for storing logs
local data_path = vim.fn.stdpath("data")
local log_file = data_path .. "/keybind_usage.json"

-- Initialize or load the usage data
local usage_data = {}
local last_save_time = 0
local save_interval = 60 * 5 -- Save every 5 minutes

-- Configuration options with defaults
local config = {
  save_mode = "immediate", -- or "periodic"
  save_interval = 60 * 5,  -- in seconds, used when save_mode is "periodic"
}

-- Try to load existing data
local function load_data()
  local file = io.open(log_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    
    if content and content ~= "" then
      local ok, data = pcall(vim.json.decode, content)
      if ok and type(data) == "table" then
        usage_data = data
        return
      end
    end
  end
  
  -- If we couldn't load data, initialize with an empty table
  usage_data = {
    mappings = {},
    first_tracked = os.time(),
    last_tracked = os.time(),
    total_count = 0
  }
end

-- Save data to file
local function save_data()
  usage_data.last_tracked = os.time()
  
  local file = io.open(log_file, "w")
  if file then
    file:write(vim.json.encode(usage_data))
    file:close()
  end
  
  last_save_time = os.time()
end

-- Record a keybind usage
local function record_usage(mapping, mode)
  if not usage_data.mappings[mapping] then
    usage_data.mappings[mapping] = {
      count = 0,
      first_used = os.time(),
      last_used = os.time(),
      modes = {}
    }
  end
  
  -- Update mapping data
  local map_data = usage_data.mappings[mapping]
  map_data.count = map_data.count + 1
  map_data.last_used = os.time()
  
  -- Update mode data
  if not map_data.modes[mode] then
    map_data.modes[mode] = 0
  end
  map_data.modes[mode] = map_data.modes[mode] + 1
  
  -- Update total count
  usage_data.total_count = usage_data.total_count + 1
  
  -- Save according to configured mode
  if config.save_mode == "immediate" then
    save_data()
  elseif os.time() - last_save_time > config.save_interval then
    save_data()
  end
end

-- Function to generate usage report
local function generate_report()
  -- Sort mappings by usage count
  local sorted_mappings = {}
  for mapping, data in pairs(usage_data.mappings) do
    table.insert(sorted_mappings, {
      key = mapping,
      count = data.count,
      last_used = data.last_used,
      first_used = data.first_used
    })
  end
  
  table.sort(sorted_mappings, function(a, b)
    return a.count > b.count
  end)
  
  -- Create a new buffer and window for the report
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded"
  })
  
  -- Generate the report content
  local lines = {
    "# Keybind Usage Report",
    "",
    "Total keybind activations: " .. usage_data.total_count,
    "Tracking since: " .. os.date("%Y-%m-%d %H:%M:%S", usage_data.first_tracked),
    "Last updated: " .. os.date("%Y-%m-%d %H:%M:%S", usage_data.last_tracked),
    "Total unique keybinds: " .. #sorted_mappings,
    "",
    "## Top 20 Most Used Keybinds",
    "",
    "| Keybind | Count | Last Used | Percentage |",
    "|---------|-------|-----------|------------|"
  }
  
  -- Add top 20 mappings
  for i, mapping in ipairs(sorted_mappings) do
    if i > 20 then break end
    local percentage = string.format("%.2f%%", (mapping.count / usage_data.total_count) * 100)
    table.insert(lines, "| " .. mapping.key .. " | " .. mapping.count .. " | " .. 
                os.date("%Y-%m-%d", mapping.last_used) .. " | " .. percentage .. " |")
  end
  
  -- Add section for all keybinds
  table.insert(lines, "")
  table.insert(lines, "## All Keybinds (Sorted by Usage)")
  table.insert(lines, "")
  table.insert(lines, "| Keybind | Count | First Used | Last Used |")
  table.insert(lines, "|---------|-------|------------|-----------|")
  
  -- Add all mappings
  for _, mapping in ipairs(sorted_mappings) do
    table.insert(lines, "| " .. mapping.key .. " | " .. mapping.count .. " | " .. 
                os.date("%Y-%m-%d", mapping.first_used) .. " | " .. 
                os.date("%Y-%m-%d", mapping.last_used) .. " |")
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set filetype for markdown highlighting
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  
  -- Add keymapping to close the report
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", {
    noremap = true,
    silent = true
  })
  
  -- Return to make sure we save current data
  return true
end

-- Function to show daily usage stats
local function show_daily_stats()
  -- Process data by day
  local daily_usage = {}
  local daily_keybinds = {}
  local today = os.date("%Y-%m-%d")
  local total_today = 0
  
  -- First, organize all keybind usage by day
  for mapping, info in pairs(usage_data.mappings) do
    local day = os.date("%Y-%m-%d", info.last_used)
    
    if not daily_usage[day] then
      daily_usage[day] = 0
      daily_keybinds[day] = {}
    end
    
    if not daily_keybinds[day][mapping] then
      daily_keybinds[day][mapping] = 0
    end
    
    daily_keybinds[day][mapping] = daily_keybinds[day][mapping] + info.count
    daily_usage[day] = daily_usage[day] + info.count
    
    -- If used today, add to today's count
    if day == today then
      total_today = total_today + info.count
    end
  end
  
  -- Create a sorted list of days
  local days = {}
  for day in pairs(daily_usage) do
    table.insert(days, day)
  end
  
  table.sort(days)
  
  -- Create a new buffer and window for the report
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded"
  })
  
  -- Generate the report content
  local lines = {
    "# Daily Keybind Usage",
    "",
    "Total keybind activations: " .. usage_data.total_count,
    "Today's total: " .. total_today,
    "",
    "## Usage by Day",
    "",
    "| Date | Total Count |",
    "|------|-------------|"
  }
  
  -- Add days with their total counts
  for i = #days, 1, -1 do
    local day = days[i]
    table.insert(lines, "| " .. day .. " | " .. daily_usage[day] .. " |")
    
    -- Only show last 30 days
    if #days - i >= 29 then
      break
    end
  end
  
  -- Add detailed section for today's keybinds
  if daily_keybinds[today] and next(daily_keybinds[today]) then
    table.insert(lines, "")
    table.insert(lines, "## Today's Keybind Usage")
    table.insert(lines, "")
    table.insert(lines, "| Keybind | Count |")
    table.insert(lines, "|---------|-------|")
    
    -- Sort today's keybinds by usage
    local today_keybinds = {}
    for mapping, count in pairs(daily_keybinds[today]) do
      table.insert(today_keybinds, { key = mapping, count = count })
    end
    
    table.sort(today_keybinds, function(a, b)
      return a.count > b.count
    end)
    
    -- Add all today's keybinds
    for _, data in ipairs(today_keybinds) do
      table.insert(lines, "| " .. data.key .. " | " .. data.count .. " |")
    end
  end
  
  -- For most recent day (excluding today if there are other days)
  local most_recent_day = nil
  for i = #days, 1, -1 do
    if days[i] ~= today then
      most_recent_day = days[i]
      break
    end
  end
  
  if most_recent_day and daily_keybinds[most_recent_day] and next(daily_keybinds[most_recent_day]) then
    table.insert(lines, "")
    table.insert(lines, "## Previous Day Keybind Usage (" .. most_recent_day .. ")")
    table.insert(lines, "")
    table.insert(lines, "| Keybind | Count |")
    table.insert(lines, "|---------|-------|")
    
    -- Sort previous day's keybinds by usage
    local prev_keybinds = {}
    for mapping, count in pairs(daily_keybinds[most_recent_day]) do
      table.insert(prev_keybinds, { key = mapping, count = count })
    end
    
    table.sort(prev_keybinds, function(a, b)
      return a.count > b.count
    end)
    
    -- Add all previous day's keybinds
    for _, data in ipairs(prev_keybinds) do
      table.insert(lines, "| " .. data.key .. " | " .. data.count .. " |")
    end
  end
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set filetype for markdown highlighting
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  
  -- Add keymapping to close the report
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", {
    noremap = true,
    silent = true
  })
end

-- Function to export data
local function export_data(format)
  format = format or "csv"
  local export_file = vim.fn.expand("~/keybind_usage_" .. os.date("%Y%m%d") .. "." .. format)
  
  if format == "csv" then
    -- Export to CSV
    local output_file = io.open(export_file, "w")
    if not output_file then
      vim.notify("Failed to create export file.", vim.log.levels.ERROR)
      return
    end
    
    -- Write header
    output_file:write("Keybind,Count,First Used,Last Used\n")
    
    -- Write data
    for mapping, info in pairs(usage_data.mappings) do
      -- Escape quotes in the mapping
      local escaped_mapping = mapping:gsub('"', '""')
      output_file:write(string.format('"%s",%d,%s,%s\n', 
        escaped_mapping, 
        info.count, 
        os.date("%Y-%m-%d", info.first_used), 
        os.date("%Y-%m-%d", info.last_used)))
    end
    
    output_file:close()
  elseif format == "json" then
    -- Export to JSON (just copy the file)
    vim.fn.system(string.format("cp %s %s", log_file, export_file))
  else
    vim.notify("Unsupported export format: " .. format, vim.log.levels.ERROR)
    return
  end
  
  vim.notify("Exported keybinding data to " .. export_file, vim.log.levels.INFO)
end

-- Function to reset tracking data
local function reset_data()
  -- Create a blank json file
  local file = io.open(log_file, "w")
  if file then
    local new_data = {
      mappings = {},
      first_tracked = os.time(),
      last_tracked = os.time(),
      total_count = 0
    }
    file:write(vim.json.encode(new_data))
    file:close()
    
    -- Also update our local copy
    usage_data = new_data
    
    vim.notify("Keybind tracking data has been reset.", vim.log.levels.INFO)
  else
    vim.notify("Failed to reset keybind tracking data.", vim.log.levels.ERROR)
  end
end

-- Function to setup tracking
function M.setup(opts)
  -- Merge configuration
  if opts then
    for k, v in pairs(opts) do
      config[k] = v
    end
  end
  
  -- Initialize by loading existing data
  load_data()
  
  -- Command to show the report
  vim.api.nvim_create_user_command("KeybindReport", function()
    -- Save current data before showing report
    save_data()
    generate_report()
  end, {})
  
  -- Command to show daily stats
  vim.api.nvim_create_user_command("KeybindDaily", function()
    -- Save current data before showing report
    save_data()
    show_daily_stats()
  end, {})
  
  -- Command to export data
  vim.api.nvim_create_user_command("KeybindExport", function(opts)
    -- Save current data before exporting
    save_data()
    export_data(opts.args)
  end, {
    nargs = "?",
    complete = function()
      return {"csv", "json"}
    end
  })
  
  -- Command to reset tracking data
  vim.api.nvim_create_user_command("KeybindReset", function()
    -- Ask for confirmation
    vim.ui.select({"Yes", "No"}, {
      prompt = "Are you sure you want to reset all keybind tracking data?"
    }, function(choice)
      if choice == "Yes" then
        reset_data()
      end
    end)
  end, {})
  
  -- On VimLeave, save the data
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      save_data()
    end
  })
  
  -- Override keymap.set to track new mappings
  local orig_keymap_set = vim.keymap.set
  vim.keymap.set = function(mode, lhs, rhs, opts)
    if type(lhs) == "string" and lhs:match("^<leader>") then
      -- After setting the original mapping, we'll create an additional one 
      -- that records usage first
      local result = orig_keymap_set(mode, lhs, function(...)
        record_usage(lhs, mode)
        -- If rhs is a function, call it; otherwise, let the mapping proceed normally
        if type(rhs) == "function" then
          return rhs(...)
        end
      end, opts)
      
      return result
    else
      -- For non-leader mappings, just set normally
      return orig_keymap_set(mode, lhs, rhs, opts)
    end
  end
  
  -- Process existing keybinds
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Delayed execution to ensure all plugins have loaded their mappings
      vim.defer_fn(function()
        -- Get all keymaps
        local modes = {'n', 'i', 'v', 's', 't', 'c'}
        for _, mode in ipairs(modes) do
          local keymaps = vim.api.nvim_get_keymap(mode)
          for _, keymap in ipairs(keymaps) do
            if keymap.lhs and keymap.lhs:match("^<leader>") then
              -- For each leader mapping, create our tracking wrapper
              -- We'll keep the original mapping but add tracking before it's executed
              local lhs = keymap.lhs
              local rhs = keymap.rhs
              local opts = {
                silent = keymap.silent == 1,
                noremap = keymap.noremap == 1,
                expr = keymap.expr == 1,
                nowait = keymap.nowait == 1
              }
              
              -- Clear the original mapping and replace with our tracked version
              vim.keymap.del(mode, lhs)
              vim.keymap.set(mode, lhs, function()
                record_usage(lhs, mode)
                -- Execute the original command
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes(rhs or lhs, true, false, true),
                  't', true
                )
              end, opts)
            end
          end
        end
      end, 100) -- 100ms delay to ensure all plugins have loaded
    end
  })
end

return M