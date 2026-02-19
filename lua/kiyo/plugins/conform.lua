-- lua/kiyo/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true }, function(err, did_edit)
          if not err and did_edit then
            vim.notify("Code formatted", vim.log.levels.INFO, { title = "Conform" })
          end
        end)
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = function()
    local conform = require("conform")
    local util = require("conform.util")

    -- Helper function to merge tables immutably
    local function merge_table_immutable(original, override)
      return setmetatable(override, { __index = original })
    end

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

    -- Configure biome with project detection and fallback
    local biome_for_project = merge_table_immutable(require("conform.formatters.biome"), {
      require_cwd = false, -- Allow global usage with fallback config
      args = function(self, ctx)
        local args = { "check", "--write", "--stdin-file-path", "$FILENAME" }

        -- Try to find project-specific biome config
        local project_config = find_config_file({
          "biome.json",
          "biome.jsonc",
        }, ctx.dirname)

        if project_config then
          -- Use project config
          table.insert(args, "--config-path=" .. vim.fn.fnamemodify(project_config, ":h"))
        elseif file_exists(default_biome_config) then
          -- Fallback to default config
          table.insert(args, "--config-path=" .. vim.fn.fnamemodify(default_biome_config, ":h"))
        end

        return args
      end,
      cwd = util.root_file({
        "biome.json",
        "biome.jsonc",
        "package.json",
      }),
    })

    -- Configure prettier with project detection
    local prettier_for_project = merge_table_immutable(require("conform.formatters.prettier"), {
      require_cwd = true,
      cwd = util.root_file({
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
        "package.json",
      }),
    })

    -- Smart formatter selection for JS/TS files
    local function js_like_formatters()
      local bufnr = vim.api.nvim_get_current_buf()
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local dirname = vim.fn.fnamemodify(bufname, ":h")

      -- Check if project has biome config
      local has_biome = find_config_file({ "biome.json", "biome.jsonc" }, dirname) ~= nil

      -- Check if project has prettier config
      local has_prettier = find_config_file({
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
      }, dirname) ~= nil

      -- Check for deno
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      for _, client in pairs(clients) do
        if client.name == "denols" then
          return { "deno_fmt" }
        end
      end

      -- Priority: biome (project or default) > prettier (project) > prettier (global)
      if has_biome then
        return { "biome_for_project" }
      elseif has_prettier then
        return { "prettier_for_project" }
      else
        -- Fallback to biome with default config
        return { "biome_for_project" }
      end
    end

    return {
      formatters = {
        biome_for_project = biome_for_project,
        prettier_for_project = prettier_for_project,
      },
      formatters_by_ft = {
        -- JavaScript/TypeScript - smart detection
        javascript = js_like_formatters,
        typescript = js_like_formatters,
        javascriptreact = js_like_formatters,
        typescriptreact = js_like_formatters,

        -- JSON - prefer biome, fallback to prettier
        json = function()
          local dirname = vim.fn.expand("%:p:h")
          local has_biome = find_config_file({ "biome.json", "biome.jsonc" }, dirname) ~= nil
          if has_biome then
            return { "biome_for_project" }
          end
          return { "prettier_for_project", "biome_for_project", stop_after_first = true }
        end,
        jsonc = function()
          local dirname = vim.fn.expand("%:p:h")
          local has_biome = find_config_file({ "biome.json", "biome.jsonc" }, dirname) ~= nil
          if has_biome then
            return { "biome_for_project" }
          end
          return { "prettier_for_project", "biome_for_project", stop_after_first = true }
        end,

        -- Other web formats - prettier preferred
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "biome" },
        css = { "biome" },
        scss = { "prettier" },

        -- Go
        go = { "goimports", "gofmt" },

        -- Lua
        lua = { "stylua" },
        toml = { "taplo" },

        -- Nix
        nix = { "nixfmt" },

        -- Python
        python = { "isort", "black" },

        -- PHP/Laravel
        php = { "pint" },
        blade = { "blade-formatter" },

        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },

        -- Rust
        rust = { "rustfmt" },

        -- Terraform
        hcl = { "packer_fmt" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          timeout_ms = 2000,
          lsp_format = "fallback",
        }
      end,
    }
  end,
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    -- Commands to disable/enable formatting
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = "Disable autoformat-on-save",
      bang = true,
    })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = "Re-enable autoformat-on-save",
    })
  end,
}
