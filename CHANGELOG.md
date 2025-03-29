# Changelog

## Keybinding Reorganization (2025-03-28)

The keybindings in this Neovim configuration have been reorganized to be more intuitive, consistent, and easier to memorize, while still maintaining speed for frequently used commands.

### Global Changes

- Reorganized leader key prefixes into more logical groups
- Added `<leader>f` group for file operations
- Moved debug commands to uppercase `<leader>D` to separate from document commands
- Shortened common search commands for faster access
- Made keybindings more consistent across plugins

### Specific Changes

#### File Navigation

- `<leader>sf` → `<leader>f` - Find files (shorter access)
- `<leader>s.` → `<leader>.` - Recent files (kept short for frequent use)
- `<leader>f.` → `<leader>fs` - Select scratch buffer (more consistent naming)
- Kept `\` for revealing current file in explorer (speed-optimized)

#### Search

- `<leader>sh` → `<leader>h` - Search help docs (shorter)
- `<leader>sw` → `<leader>*` - Search current word (faster access with mnemonic symbol)
- `<leader>sg` → `<leader>g` - Live grep (shorter)
- `<leader>sr` → `<leader>r` - Resume search (shorter)

#### Debugger

- Changed all debug commands from `<leader>d` to `<leader>D` to separate from document operations:
  - `<leader>db` → `<leader>Db` - Toggle breakpoint
  - `<leader>dc` → `<leader>Dc` - Continue
  - `<leader>do` → `<leader>Do` - Step over
  - `<leader>di` → `<leader>Di` - Step into
  - `<leader>dO` → `<leader>DO` - Step out
  - `<leader>dq` → `<leader>Dq` - Terminate
  - `<leader>du` → `<leader>Du` - Toggle UI

#### Document

- Now consistently uses `<leader>d` prefix (was mixed with debug before)
- `<leader>o` → `<leader>do` - Toggle outline

#### Git

- `<leader>gg` → `<leader>g` - Open Neogit (faster access)
- Kept `<leader>gb` for git blame and `<leader>go` for opening in browser

#### Diagnostics (Trouble)

- `<leader>xX` → `<leader>xb` - Buffer diagnostics (more consistent)
- `<leader>xL` → `<leader>xl` - Location list (lowercase for consistency)
- `<leader>xQ` → `<leader>xq` - Quickfix list (lowercase for consistency)

#### UI Toggles

- `<leader>th` → `<leader>vh` - Toggle inlay hints (moved to visual group)

### What's Preserved

- `<leader><leader>` for buffers (kept for speed)
- `<leader>S` for Spectre search/replace (kept short for frequent use)
- `<C-x>` for buffer deletion (kept for efficiency)
- All window navigation keys with `<C-hjkl>` and resizing with `<A-hjkl>`
