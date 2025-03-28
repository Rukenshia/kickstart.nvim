#!/usr/bin/env lua

-- Script to print keybinding statistics for the dashboard terminal section
local data_path = vim.fn.stdpath 'data'
local log_file = data_path .. '/keybind_usage.json'

local function load_data()
  local file = io.open(log_file, 'r')
  if not file then
    return {
      mappings = {
        ['<leader>f'] = { count = 50, first_used = os.time(), last_used = os.time(), modes = { n = 50 } },
        ['<leader>g'] = { count = 35, first_used = os.time(), last_used = os.time(), modes = { n = 35 } },
        ['<leader>v'] = { count = 20, first_used = os.time(), last_used = os.time(), modes = { n = 20 } },
        ['<leader>c'] = { count = 15, first_used = os.time(), last_used = os.time(), modes = { n = 15 } },
        ['<leader>d'] = { count = 10, first_used = os.time(), last_used = os.time(), modes = { n = 10 } },
      },
      first_tracked = os.time() - 86400 * 7, -- 7 days ago
      last_tracked = os.time(),
      total_count = 130,
    }
  end

  local content = file:read '*all'
  file:close()

  if content and content ~= '' then
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == 'table' then
      return data
    end
  end

  -- Return example data
  return {
    mappings = {
      ['<leader>f'] = { count = 50, first_used = os.time(), last_used = os.time(), modes = { n = 50 } },
      ['<leader>g'] = { count = 35, first_used = os.time(), last_used = os.time(), modes = { n = 35 } },
      ['<leader>v'] = { count = 20, first_used = os.time(), last_used = os.time(), modes = { n = 20 } },
      ['<leader>c'] = { count = 15, first_used = os.time(), last_used = os.time(), modes = { n = 15 } },
      ['<leader>d'] = { count = 10, first_used = os.time(), last_used = os.time(), modes = { n = 10 } },
    },
    first_tracked = os.time() - 86400 * 7, -- 7 days ago
    last_tracked = os.time(),
    total_count = 130,
  }
end

local function bar_chart(value, max_value, width)
  width = width or 20
  local bar_length = math.floor((value / math.max(max_value, 1)) * width)
  
  -- Use simple characters that provide good visual distinction and spacing
  local filled_char = '▇'    -- upper seven-eighths block (leaves small gap at bottom)
  local empty_char = ' '     -- simple space (maximum contrast)
  
  -- Other block options you might want to try:
  -- '▁' - bottom one-eighth block (extremely short)
  -- '▃' - lower three-eighths block
  -- '▄' - lower half block
  -- '▅' - upper five-eighths block
  -- '▆' - upper three-quarters block
  -- '▇' - upper seven-eighths block
  -- '█' - full block
  
  -- Build the bar with clear separation between characters
  local bar = ''
  for i = 1, width do
    if i <= bar_length then
      bar = bar .. filled_char
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
    print 'No keybinding statistics available'
    return
  end

  -- Use maximum width for the dashboard
  local width = 58 -- Maximum dashboard section width

  -- Create separator that fits the section
  local separator = string.rep('─', width)

  -- Print totals
  print(string.format('Total activations: %d | Unique keybinds: %d', data.total_count, vim.tbl_count(data.mappings)))
  print ''

  -- Print top keybinds header
  print '\n'
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
    local padded_key = data.key .. string.rep(' ', max_key_length - #data.key + 2)
    local padded_count = string.rep(' ', max_count_str_len - #data.count_str) .. data.count_str
    local padded_percent = string.rep(' ', max_percent_str_len - #data.percent_str) .. data.percent_str

    -- Add padding to push stats+bar to the end
    local push_padding = string.rep(' ', push_space)

    -- Format: index. key [padding] count (percent) bar
    print(string.format('%d. %s%s%s (%s) %s', data.index, padded_key, push_padding, padded_count, padded_percent, data.bar))
  end
end

display_stats()
