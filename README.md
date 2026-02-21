# Neovim 0.11 LSP + Blink-cmp Setup Guide

This guide provides a complete configuration for setting up Neovim 0.11 with blink-cmp and LSP using lazy.nvim.

## Key Features of Neovim 0.11

- **Built-in `vim.lsp.config`**: No need for nvim-lspconfig on 0.11+
- **Built-in `vim.lsp.enable()`**: Simplified LSP server activation
- **Better default keymaps**: Many LSP keybindings work out of the box
- **Simplified blink-cmp integration**: Automatic capability detection

## Setup Overview

1. **blink-cmp**: Modern completion engine with LSP, snippets, path, and buffer sources
2. **mason.nvim**: LSP server installer/manager
3. **LSP Configuration**: Using Neovim 0.11's built-in `vim.lsp.config` and `vim.lsp.enable()`

## File Structure

```
~/.config/nvim/
├── lua/
│   └── kiyo/
│       └── plugins/
│           ├── blink.lua        # Blink-cmp configuration
│           ├── mason.lua        # Mason LSP installer
│           └── lsp.lua          # LSP configuration
└── init.lua
```

## Installation Steps

1. Copy the configuration files to your Neovim config directory
2. Restart Neovim
3. Lazy.nvim will automatically install plugins
4. Mason will install LSP servers specified in `ensure_installed`

## Important Notes

> [!WARNING]
> On Neovim 0.11+, you **do NOT need** to manually set LSP capabilities when using `vim.lsp.config`. Blink-cmp capabilities are automatically detected.

> [!TIP]
> If you want to see inline error messages (virtual text), it's now disabled by default in Neovim 0.11. Enable it with:
>
> ```lua
> vim.diagnostic.config({ virtual_text = true })
> ```

> [!IMPORTANT]
> The `keymap.preset` in blink-cmp has several options:
>
> - `'default'`: C-y to accept (recommended, similar to built-in)
> - `'super-tab'`: Tab to accept (VSCode-like)
> - `'enter'`: Enter to accept
> - `'none'`: No default mappings

## Default LSP Keybindings (Neovim 0.11)

These work automatically when LSP is attached:

- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Go to references
- `K` - Hover documentation
- `<C-k>` - Signature help (in insert mode)
- `<space>rn` - Rename
- `<space>ca` - Code action
- `<space>f` - Format

## Configured Language Servers

The example includes:

- **TypeScript/JavaScript**: `ts_ls`
- **HTML**: `html`
- **CSS**: `cssls`
- **Lua**: `lua_ls`
- **Python**: `pyright`
- **Go**: `gopls`
- **Rust**: `rust_analyzer`

Add or remove servers in `mason.lua` and `lsp.lua` as needed.
