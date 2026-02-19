-- lua/kiyo/plugins/nvim-lint.lua
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Helper function to check if a file exists
    local function file_exists(path)
      local stat = vim.loop.fs_stat(path)
      return stat and stat.type == "file"
    end

    -- Helper function to find config files in project
    local function find_config_file(filenames, start_path)
      start_path = start_path or vim.fn.getcwd()
      for _, filename in ipairs(filenames) do
        local found = vim.fs.find(filename, {
          upward = true,
          path = start_path,
          limit = 1,
        })
        if #found > 0 then
          return found[1]
        end
      end
      return nil
    end

    -- Get default biome config path
    local default_biome_config = vim.fn.stdpath("config") .. "/rules/biome.jsonc"

    -- Configure biome linter with project detection
    lint.linters.biome = {
      cmd = "biome",
      stdin = true,
      args = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        local dirname = vim.fn.fnamemodify(bufname, ":h")

        local args = { "lint", "--stdin-file-path", bufname }

        -- Try to find project-specific biome config
        local project_config = find_config_file({ "biome.json", "biome.jsonc" }, dirname)

        if project_config then
          table.insert(args, "--config-path=" .. vim.fn.fnamemodify(project_config, ":h"))
        elseif file_exists(default_biome_config) then
          table.insert(args, "--config-path=" .. vim.fn.fnamemodify(default_biome_config, ":h"))
        end

        return args
      end,
      stream = "both",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        local ok, decoded = pcall(vim.json.decode, output)

        if not ok or not decoded or not decoded.diagnostics then
          return diagnostics
        end

        for _, diagnostic in ipairs(decoded.diagnostics) do
          if diagnostic.location then
            table.insert(diagnostics, {
              lnum = diagnostic.location.span.start.line - 1,
              col = diagnostic.location.span.start.column,
              end_lnum = diagnostic.location.span["end"].line - 1,
              end_col = diagnostic.location.span["end"].column,
              severity = diagnostic.severity == "error" and vim.diagnostic.severity.ERROR
                or vim.diagnostic.severity.WARN,
              message = diagnostic.description,
              source = "biome",
            })
          end
        end

        return diagnostics
      end,
    }

    -- Configure statix linter for Nix
    lint.linters.statix = {
      cmd = "statix",
      stdin = false,
      args = { "check", "--format=errfmt", "--stdin" },
      stream = "stderr",
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat("%f>%l:%c:%t:%n:%m", {
        source = "statix",
        severity = {
          W = vim.diagnostic.severity.WARN,
          E = vim.diagnostic.severity.ERROR,
          I = vim.diagnostic.severity.INFO,
          H = vim.diagnostic.severity.HINT,
        },
      }),
    }

    -- Configure ESLint linter
    lint.linters.eslint_d = {
      cmd = "eslint_d",
      stdin = true,
      args = {
        "--no-color",
        "--format",
        "json",
        "--stdin",
        "--stdin-filename",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
        source = "eslint_d",
      }),
    }

    -- Smart linter selection for JS/TS
    local function js_like_linters()
      local bufnr = vim.api.nvim_get_current_buf()
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local dirname = vim.fn.fnamemodify(bufname, ":h")

      -- Check if project has ESLint config
      local has_eslint = find_config_file({
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
      }, dirname) ~= nil

      -- Check if project has biome config
      local has_biome = find_config_file({ "biome.json", "biome.jsonc" }, dirname) ~= nil

      -- Priority: ESLint (if configured) > Biome (project or default)
      if has_eslint then
        return { "eslint_d" }
      elseif has_biome or file_exists(default_biome_config) then
        return { "biome" }
      end

      -- Fallback to biome with default config
      return { "biome" }
    end

    -- Configure linters by filetype
    lint.linters_by_ft = {
      -- JavaScript/TypeScript - smart detection
      javascript = js_like_linters,
      typescript = js_like_linters,
      javascriptreact = js_like_linters,
      typescriptreact = js_like_linters,

      -- JSON - use biome if available
      json = function()
        local dirname = vim.fn.expand("%:p:h")
        local has_biome = find_config_file({ "biome.json", "biome.jsonc" }, dirname) ~= nil
        if has_biome or file_exists(default_biome_config) then
          return { "biome" }
        end
        return {}
      end,
      jsonc = function()
        local dirname = vim.fn.expand("%:p:h")
        local has_biome = find_config_file({ "biome.json", "biome.jsonc" }, dirname) ~= nil
        if has_biome or file_exists(default_biome_config) then
          return { "biome" }
        end
        return {}
      end,

      -- Go
      go = { "golangcilint" },
      -- Python
      python = { "ruff" },

      -- Lua
      lua = { "selene" },
      nix = { "statix" },

      -- Shell
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      zsh = { "shellcheck" },

      -- PHP
      php = { "pint" },
      toml = { "tombi" },

      -- Terraform
      terraform = { "terraform_validate" },
      tf = { "terraform_validate" },
    }

    -- Auto-lint on file events
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local ft = vim.bo.filetype
        local linters = lint.linters_by_ft[ft]

        -- Handle function-based linter selection (your JS/TS logic)
        if type(linters) == "function" then
          linters = linters()
        end

        if linters and #linters > 0 then
          for _, linter_name in ipairs(linters) do
            local linter = lint.linters[linter_name]

            if type(linter) == "function" then
              linter = linter()
            end

            if linter then
              local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
              if cmd and vim.fn.executable(cmd) == 1 then
                lint.try_lint(linter_name)
                -- We break after the first valid linter found
                break
              end
            end
          end
        end
      end,
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })

    vim.keymap.set("n", "<leader>cL", function()
      local ft = vim.bo.filetype
      local linters = lint.linters_by_ft[ft]

      if type(linters) == "function" then
        linters = linters()
      end

      if linters then
        vim.notify("Linters for " .. ft .. ": " .. table.concat(linters, ", "), vim.log.levels.INFO)
      else
        vim.notify("No linters configured for " .. ft, vim.log.levels.WARN)
      end
    end, { desc = "Show configured linters" })
  end,
}
