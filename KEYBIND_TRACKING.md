# Keybind Usage Tracking

This system tracks how you use your keybindings over time, allowing you to:

1. See which keybinds you use most often
2. Identify keybinds you never use
3. Analyze your usage patterns over time
4. Optimize your keybinds based on actual usage data

## Available Commands

### View Usage Report

```
:KeybindReport
```

This command opens a markdown report showing:
- Total keybind activations
- When tracking started
- Number of unique keybinds used
- Top 20 most used keybinds with usage count, last used date, and percentage of total usage
- Complete list of all keybinds sorted by usage frequency

Use this for a comprehensive overview of your keybind usage patterns.

### View Daily Stats

```
:KeybindDaily
```

Shows a detailed breakdown of your keybind usage by day:
- Total activations
- Today's total
- Daily counts for the last 30 days
- Detailed list of today's used keybinds with counts
- Detailed list of previous day's used keybinds with counts

This helps you track your keybind usage trends over time and see which specific keybinds you're using each day.

### Export Data

```
:KeybindExport [format]
```

Exports your keybind usage data to a file in your home directory. Available formats:
- `csv` (default) - Exports a CSV file suitable for spreadsheet analysis
- `json` - Exports the raw JSON data

Example:
```
:KeybindExport csv
```

### Reset Tracking Data

```
:KeybindReset
```

Resets all keybind tracking data. This will prompt for confirmation before deleting your data.

## How It Works

The tracker:
1. Automatically intercepts all leader keybinds (<leader>xyz)
2. Records each activation with timestamp
3. Saves data to `~/.local/share/nvim/keybind_usage.json` (or equivalent in your OS)
4. Data is saved either immediately after each keybind is used or periodically (configurable)

## Implementation Details

- Only maps with a `<leader>` prefix are tracked
- Existing keybinds are processed on startup
- New keybinds defined with `vim.keymap.set()` are automatically tracked
- The system has minimal performance impact

## Configuration

The tracker can be configured in your `init.lua` file:

```lua
require('custom.keybind_tracker').setup({
  save_mode = "immediate", -- Save after every keybind use (default)
  -- save_mode = "periodic", -- Alternative: save periodically
  save_interval = 300, -- Save every 5 minutes (only used with periodic save mode)
})
```

**Save Modes:**
- `immediate`: Saves data after each keybind use. Ensures no data loss but may impact performance with very frequent keybind usage.
- `periodic`: Saves data at regular intervals defined by `save_interval`. Better performance but risks losing some data on crashes.

## Data Analysis

For more advanced analysis, you can:
1. Export the data using `:KeybindExport`
2. Use external tools like Excel, Python pandas, or R for visualization and analysis
3. Create custom reports based on your specific needs

## Tips for Optimizing Keybinds

Based on your tracking data, consider:
1. Moving frequently used commands to easier-to-reach keys
2. Using more intuitive keys for common operations
3. Removing or reassigning keybinds you never use
4. Grouping related commands under similar prefixes

This data-driven approach helps create a more efficient and personalized editing experience.