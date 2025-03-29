#!/usr/bin/env luajit

-- Script to print keybinding statistics for the dashboard terminal section
-- Support for running independently of Neovim

-- Determine if we're running inside or outside Neovim
local is_nvim = (function() 
  local success = pcall(function() return vim ~= nil and vim.fn ~= nil end)
  return success and vim ~= nil
end)()

-- ANSI color codes for terminal output
local colors = {
  reset = "\27[0m",
  bold = "\27[1m",
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  blue = "\27[34m",
  magenta = "\27[35m",
  cyan = "\27[36m",
  white = "\27[37m",
  bright_red = "\27[91m",
  bright_green = "\27[92m",
  bright_yellow = "\27[93m",
  bright_blue = "\27[94m",
  bright_magenta = "\27[95m",
  bright_cyan = "\27[96m",
  bright_white = "\27[97m",
}

-- Helper function to colorize text when running outside Neovim
local function colorize(text, color)
  if not is_nvim then
    return colors[color] .. text .. colors.reset
  else
    return text
  end
end

-- Get the user's data directory for storing logs
local data_path
local json_decode
local json_encode

if is_nvim then
  -- Running inside Neovim
  data_path = vim.fn.stdpath('data')
  json_decode = vim.json.decode
  json_encode = vim.json.encode
else
  -- Running as standalone script
  -- Find the data directory based on OS
  local os_name = package.config:sub(1,1) == '\\' and 'Windows' or io.popen('uname -s'):read('*l')
  
  if os_name == 'Darwin' then
    -- macOS
    data_path = os.getenv('HOME') .. '/.local/share/nvim'
  elseif os_name == 'Linux' then
    -- Linux
    data_path = os.getenv('HOME') .. '/.local/share/nvim'
  elseif os_name == 'Windows' then
    -- Windows
    data_path = os.getenv('LOCALAPPDATA') .. '/nvim-data'
  else
    -- Default fallback
    data_path = os.getenv('HOME') .. '/.local/share/nvim'
  end
  
  -- Use cjson from LuaJIT for JSON decoding
  local function decode_json(str)
    -- Try to use cjson
    local ok, cjson = pcall(require, "cjson")
    if ok and cjson and cjson.decode then
      local success, parsed = pcall(cjson.decode, str)
      if success and parsed then
        return parsed
      end
    end
    
    -- If we somehow don't have cjson, dump the raw data and return empty
    print(colorize("Warning: cjson library not available for JSON parsing", "red"))
    
    -- Return empty structure
    return { 
      mappings = {}, 
      total_count = 0,
      first_tracked = os.time(),
      last_tracked = os.time()
    }
  end
  
  json_decode = decode_json
  json_encode = function(obj) 
    -- We don't need to encode for this script
    return "{}" 
  end
end

local json_file = data_path .. '/keybind_usage.json'
local csv_file = data_path .. '/keybind_usage.csv'
local log_file = is_nvim and json_file or csv_file -- Prefer CSV when not in Neovim

local function load_data()
  -- First check if we have data in _G
  if _G.KEYBIND_DATA and _G.KEYBIND_DATA.mappings then
    return _G.KEYBIND_DATA
  end
  
  -- In standalone mode, try to read the CSV file directly
  if not is_nvim and log_file == csv_file then
    local file = io.open(csv_file, 'r')
    if file then
      local content = file:read('*all')
      file:close()
      
      if content and content ~= '' then
        local mappings = {}
        local total_count = 0
        local first_tracked = os.time() - 86400 * 7 -- Default to a week ago
        local last_tracked = os.time()
        
        -- Process the file line by line
        local lines = {}
        for line in content:gmatch('[^\r\n]+') do
          table.insert(lines, line)
        end
        
        -- First line contains metadata
        if #lines > 0 and lines[1]:match('^#') then
          -- Extract metadata from first line
          total_count = tonumber(lines[1]:match('total_count=(%d+)')) or 0
          first_tracked = tonumber(lines[1]:match('first_tracked=(%d+)')) or first_tracked
          last_tracked = tonumber(lines[1]:match('last_tracked=(%d+)')) or last_tracked
        end
        
        -- Skip header line (line 2)
        for i = 3, #lines do
          local line = lines[i]
          
          -- Parse CSV line (handle quoted fields properly)
          local fields = {}
          local current_field = ""
          local in_quotes = false
          local escaped_quote = false
          
          for j = 1, #line do
            local char = line:sub(j, j)
            
            if char == '"' then
              if not in_quotes then
                in_quotes = true
              elseif escaped_quote then
                current_field = current_field .. '"'
                escaped_quote = false
              elseif j < #line and line:sub(j+1, j+1) == '"' then
                escaped_quote = true
              else
                in_quotes = false
              end
            elseif char == ',' and not in_quotes then
              table.insert(fields, current_field)
              current_field = ""
            else
              current_field = current_field .. char
            end
          end
          
          -- Add the last field
          table.insert(fields, current_field)
          
          -- Parse the fields
          if #fields >= 4 then
            local key = fields[1]
            local count = tonumber(fields[2]) or 0
            local first_used = tonumber(fields[3]) or os.time()
            local last_used = tonumber(fields[4]) or os.time()
            
            if key and count > 0 then
              mappings[key] = {
                count = count,
                first_used = first_used,
                last_used = last_used,
                modes = { n = count } -- Simplification
              }
            end
          end
        end
        
        -- Return the parsed data
        if next(mappings) then
          return {
            mappings = mappings,
            total_count = total_count,
            first_tracked = first_tracked,
            last_tracked = last_tracked,
          }
        end
      end
    end
  end
  
  -- Check if we have input from stdin
  local stdin_content = nil
  if not is_nvim then
    local has_stdin = io.read(0) ~= nil -- Test if there's data on stdin without consuming it
    if has_stdin then
      stdin_content = io.read("*all")
    end
  end
  
  if stdin_content and stdin_content ~= "" then
    -- In Neovim, we can use the built-in JSON decoder
    local ok, data = pcall(json_decode, stdin_content)
    if ok and type(data) == 'table' and data.mappings then
      return data
    end
  end

  -- Try to load from file as fallback
  local file = io.open(log_file, 'r')
  if not file then
    print(colorize("No keybind tracking data found at: " .. log_file, "red"))
    return {
      mappings = {},
      first_tracked = os.time(),
      last_tracked = os.time(),
      total_count = 0,
    }
  end

  local content = file:read('*all')
  file:close()

  if content and content ~= '' then
    local ok, data = pcall(json_decode, content)
    if ok and type(data) == 'table' and data.mappings then
      return data
    else
      print(colorize("Warning: Failed to parse JSON keybind data, returning empty dataset", "yellow"))
    end
  end

  -- Return empty data structure if we couldn't load valid data
  return {
    mappings = {},
    first_tracked = os.time(),
    last_tracked = os.time(),
    total_count = 0,
  }
end

local function bar_chart(value, max_value, width)
  width = width or 20
  local bar_length = math.floor((value / math.max(max_value, 1)) * width)
  
  -- Use simple characters that provide good visual distinction and spacing
  local filled_char = '▇'    -- upper seven-eighths block (leaves small gap at bottom)
  local empty_char = ' '     -- simple space (maximum contrast)
  
  -- Build the bar with clear separation between characters
  local bar = ''
  
  -- Choose color based on value relative to max (only when running standalone)
  local color
  if not is_nvim then
    local ratio = value / math.max(max_value, 1)
    if ratio >= 0.8 then
      color = "bright_green"
    elseif ratio >= 0.6 then
      color = "green"
    elseif ratio >= 0.4 then
      color = "bright_yellow"
    elseif ratio >= 0.2 then
      color = "yellow"
    else
      color = "bright_red"
    end
  end
  
  for i = 1, width do
    if i <= bar_length then
      if not is_nvim then
        bar = bar .. colorize(filled_char, color)
      else
        bar = bar .. filled_char
      end
    else
      bar = bar .. empty_char
    end
  end
  
  return bar
end

local function get_top_keybinds(data, limit)
  if not data or not data.mappings then
    return {}
  end

  -- Convert to array and sort
  local keybinds = {}
  for mapping, info in pairs(data.mappings) do
    table.insert(keybinds, {
      key = mapping,
      count = info.count,
      last_used = info.last_used,
    })
  end

  table.sort(keybinds, function(a, b)
    return a.count > b.count
  end)

  -- Return top N
  local top = {}
  for i = 1, math.min(limit or 5, #keybinds) do
    top[i] = keybinds[i]
  end
  return top
end

local function display_stats()
  local data = load_data()
  if not data or not data.mappings then
    print(colorize('No keybinding statistics available', 'red'))
    return
  end
  
  -- Check if we have any data to display
  local has_keybinds = false
  for _ in pairs(data.mappings) do
    has_keybinds = true
    break
  end
  
  if not has_keybinds then
    print(colorize('No keybindings recorded yet. Start using <leader> shortcuts to collect data!', 'bright_yellow'))
    return
  end

  -- Use maximum width for the dashboard
  local width = 58 -- Maximum dashboard section width

  -- Create separator that fits the section
  local separator = string.rep('─', width)

  -- Count mappings for non-Neovim context (since we can't use vim.tbl_count)
  local mappings_count = 0
  for _ in pairs(data.mappings) do
    mappings_count = mappings_count + 1
  end
  
  local unique_count = is_nvim and vim.tbl_count(data.mappings) or mappings_count

  -- Print totals with color when in standalone mode
  local total_stats = string.format('Total activations: %s | Unique keybinds: %s', 
    colorize(tostring(data.total_count), 'bright_cyan'),
    colorize(tostring(unique_count), 'bright_cyan'))
  
  print(total_stats)
  print('')

  -- Print top keybinds header
  local top_keybinds = get_top_keybinds(data, 5)
  local max_count = top_keybinds[1] and top_keybinds[1].count or 1

  -- Find the longest keybind name for proper alignment
  local max_key_length = 0
  for _, kb in ipairs(top_keybinds) do
    max_key_length = math.max(max_key_length, #kb.key)
  end

  -- Find the longest count and percentage for proper alignment
  local max_count_str_len = 0
  local max_percent_str_len = 0
  local formatted_data = {}

  for i, kb in ipairs(top_keybinds) do
    local count_str = tostring(kb.count)
    local percent_str = string.format('%.1f%%', (kb.count / data.total_count) * 100)

    max_count_str_len = math.max(max_count_str_len, #count_str)
    max_percent_str_len = math.max(max_percent_str_len, #percent_str)

    formatted_data[i] = {
      index = i,
      key = kb.key,
      count = kb.count,
      count_str = count_str,
      percent_str = percent_str,
      bar = bar_chart(kb.count, max_count, 15),
    }
  end

  -- Calculate space needed before stats and bar
  local prefix_width = 4 -- index + dot + space
    + max_key_length
    + 2 -- padded key

  -- Calculate space needed for stats and bar
  local stats_width = max_count_str_len
    + 1 -- padded count + space
    + max_percent_str_len
    + 3 -- (percent) + space
    + 15 -- bar size

  -- Calculate extra space needed to push stats+bar to the end
  local push_space = math.max(0, width - prefix_width - stats_width)

  -- Format with proper alignment
  for _, data in ipairs(formatted_data) do
    if is_nvim then
      -- For Neovim, use the original format without color codes
      local padded_key = data.key .. string.rep(' ', max_key_length - #data.key + 2)
      local padded_count = string.rep(' ', max_count_str_len - #data.count_str) .. data.count_str
      local padded_percent = string.rep(' ', max_percent_str_len - #data.percent_str) .. data.percent_str
      local push_padding = string.rep(' ', push_space)
      
      print(string.format('%d. %s%s%s (%s) %s', data.index, padded_key, push_padding, padded_count, padded_percent, data.bar))
    else
      -- For standalone with color, build the line with proper alignment 
      -- independently of string length with color codes
      
      -- Start with the index
      local line = colorize(tostring(data.index) .. ".", "bright_white") .. " "
      
      -- Add the key with padding
      line = line .. colorize(data.key, "bright_cyan")
      line = line .. string.rep(' ', max_key_length - #data.key + 2)
      
      -- Add padding to push stats+bar to the right
      line = line .. string.rep(' ', push_space)
      
      -- Add right-aligned count
      line = line .. string.rep(' ', max_count_str_len - #data.count_str)
      line = line .. colorize(data.count_str, "bright_yellow") .. " "
      
      -- Add percentage in parentheses with careful spacing and fixed width
      line = line .. "("
      -- Always use fixed width for percentages regardless of value
      line = line .. string.rep(' ', max_percent_str_len - #data.percent_str)
      line = line .. colorize(data.percent_str, "bright_green") .. ") "
      
      -- Add the bar chart
      line = line .. data.bar
      
      print(line)
    end
  end
end

display_stats()