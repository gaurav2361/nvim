return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "davidmh/mdx.nvim" },
    build = ":TSUpdate",
    branch = "main",
    main = "nvim-treesitter", -- EXPLICITLY TELL LAZY WHERE SETUP() LIVES
    init = function()
      -- Register custom predicates and directives for Nix injections (hmts replacement)
      require("kiyo.utils.nix_treesitter").setup()

      -- Define parsers to install here instead of in opts
      local parsers_to_ensure = {
        "json",
        "jsonc",
        "javascript",
        "typescript",
        "tsx",
        "jsx",
        "go",
        "yaml",
        "html",
        "css",
        "python",
        "http",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "c",
        "toml",
        "cpp",
        "elm",
        "graphql",
        "sql",
        "bash",
        "php",
        "phpdoc",
        "blade",
        "lua",
        "nix",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "java",
        "kotlin",
        "editorconfig",
        "ssh_config",
        "rust",
        "ron",
        "diff",
        "terraform",
        "hcl",
        "nu",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "hyprlang",
        "regex",
      }

      -- Conditionally add parsers based on system executables
      if vim.fn.executable("hypr") == 1 and not vim.tbl_contains(parsers_to_ensure, "hyprlang") then
        table.insert(parsers_to_ensure, "hyprlang")
      end

      if vim.fn.executable("fish") == 1 then
        table.insert(parsers_to_ensure, "fish")
      end

      if vim.fn.executable("rofi") == 1 or vim.fn.executable("wofi") == 1 then
        table.insert(parsers_to_ensure, "rasi")
      end

      -- Diff against already-installed parsers so it doesn't reinstall everything on startup
      local alreadyInstalled = require("nvim-treesitter.config").get_installed()
      local parsersToInstall = vim
        .iter(parsers_to_ensure)
        :filter(function(parser)
          return not vim.tbl_contains(alreadyInstalled, parser)
        end)
        :totable()

      if #parsersToInstall > 0 then
        require("nvim-treesitter").install(parsersToInstall)
      end
    end,
    config = function()
      -- Setup nvim-treesitter (new API)
      require("nvim-treesitter").setup({
        -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
        install_dir = vim.fn.stdpath("data") .. "/site",

        -- ENHANCEMENT: Enable Indent
        indent = {
          enable = true,
        },

        -- ENHANCEMENT: Enable Incremental Selection
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })

      vim.treesitter.language.register("bash", "kitty")

      -- Safely enable features via FileType autocmd
      -- This prevents "Parser could not be created" error during initial load/install
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local ok, _ = pcall(vim.treesitter.start)
          if not ok then
            return -- Silent return ensures no crash if parser isn't ready
          end
          -- Standard treesitter integrations
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },

  -- NOTE: js,ts,jsx,tsx Auto Close Tags
  {
    "windwp/nvim-ts-autotag",
    enabled = true,
    ft = {
      "html",
      "xml",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
    },
    config = function()
      -- Independent nvim-ts-autotag setup
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true, -- Auto-close tags
          enable_rename = true, -- Auto-rename pairs
        },
        per_filetype = {
          ["html"] = {
            enable_close = true,
          },
          ["typescriptreact"] = {
            enable_close = true,
          },
        },
      })
    end,
  },
}
