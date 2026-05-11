return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Load on these events or when these commands are run
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSModuleInfo", "TSBufEnable", "TSBufDisable" },
    dependencies = { "davidmh/mdx.nvim" },
    build = ":TSUpdate",
    branch = "main",
    -- 'main' is used by lazy.nvim to find the setup function
    main = "nvim-treesitter",
    init = function()
      -- Register custom predicates and directives for Nix injections (hmts replacement)
      require("kiyo.utils.nix_treesitter").setup()
    end,
    config = function()
      -- Define parsers to install
      local parsers_to_ensure = {
        "json",
        "javascript",
        "typescript",
        "tsx", -- handles typescriptreact and often better for javascriptreact
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

      -- Setup nvim-treesitter
      -- We use require("nvim-treesitter") directly as .configs is removed in v1.0.0+
      require("nvim-treesitter").setup({
        ensure_installed = parsers_to_ensure,
        -- Directory to install parsers and queries to
        install_dir = vim.fn.stdpath("data") .. "/site",
        -- For newer versions
        parser_install_dir = vim.fn.stdpath("data") .. "/site",

        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
        },

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

      -- Register filetypes to their respective treesitter parsers
      -- Using 'tsx' for both react filetypes is often more reliable for HTML tag highlighting
      vim.treesitter.language.register("bash", "kitty")
      vim.treesitter.language.register("tsx", "javascriptreact")
      vim.treesitter.language.register("tsx", "typescriptreact")
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
          ["javascriptreact"] = {
            enable_close = true,
          },
          ["typescriptreact"] = {
            enable_close = true,
          },
        },
      })
    end,
  },

  -- Rainbow Delimiters: Colorize brackets and delimiters using Treesitter
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- We set the global variable, but also call the setup if available for robustness
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          javascript = "rainbow-delimiters",
          typescript = "rainbow-delimiters",
          tsx = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
