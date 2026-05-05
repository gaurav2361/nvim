return {
  "mrcjkb/rustaceanvim",
  version = "^5", -- Recommended
  lazy = false, -- This plugin is already lazy
  init = function()
    -- We define a function for vim.g.rustaceanvim to ensure it's evaluated lazily
    -- and only when a Rust file is actually opened.
    vim.g.rustaceanvim = function()
      local codelldb_path = nil
      local liblldb_path = nil

      -- Use a direct filesystem check to avoid flaky Mason API calls during startup
      local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
      
      if vim.fn.isdirectory(extension_path) == 1 then
        codelldb_path = extension_path .. "adapter/codelldb"
        liblldb_path = extension_path .. "lsp/lib/liblldb"
        local this_os = vim.loop.os_uname().sysname

        -- Path detection for different OS
        if this_os:find("Windows") then
          codelldb_path = extension_path .. "adapter\\codelldb.exe"
          liblldb_path = extension_path .. "lsp\\lib\\liblldb.dll"
        else
          -- On macOS/Linux it is .dylib or .so
          liblldb_path = liblldb_path .. (this_os == "Darwin" and ".dylib" or ".so")
        end
      end

      -- Only define the adapter if we successfully found the paths
      local adapter = nil
      if codelldb_path and liblldb_path and vim.fn.filereadable(codelldb_path) == 1 then
        local ok_cfg, cfg = pcall(require, "rustaceanvim.config")
        if ok_cfg and cfg.get_codelldb_adapter then
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
        end
      end

      return {
        tools = {
          float_win_config = {
            border = "rounded",
          },
        },
        server = {
          on_attach = function(client, bufnr)
            -- Keymaps are handled in after/ftplugin/rust.lua
          end,
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
              },
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
              },
            },
          },
        },
        -- If adapter is nil, we set dap to nil so rustaceanvim skips its internal validation
        dap = adapter and { adapter = adapter } or nil,
      }
    end
  end,
}
