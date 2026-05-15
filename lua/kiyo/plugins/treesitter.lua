return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSModuleInfo", "TSBufEnable", "TSBufDisable" },
    dependencies = { "davidmh/mdx.nvim" },
    build = ":TSUpdate",
    -- Remove branch and main to let Lazy handle it normally
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
        "tsx",
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

      -- Robust setup handling both old and new Treesitter APIs
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if ok then
        -- Old API
        ts.setup({
          ensure_installed = parsers_to_ensure,
          auto_install = true,
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          indent = { enable = true },
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
      else
        -- New API (v1.0.0+)
        local ok2, ts2 = pcall(require, "nvim-treesitter")
        if ok2 and ts2.setup then
          ts2.setup({
            ensure_installed = parsers_to_ensure,
            auto_install = true,
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            indent = { enable = true },
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
        end
      end

      -- Register filetypes to their respective treesitter parsers
      vim.treesitter.language.register("bash", "kitty")
      vim.treesitter.language.register("tsx", "javascriptreact")
      vim.treesitter.language.register("tsx", "typescriptreact")

      -- Force start Treesitter for the current buffer and future ones
      -- This is necessary if the automatic highlight.enable fails to trigger
      vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
            or vim.bo[buf].filetype

          -- Try to start Treesitter highlighting
          pcall(vim.treesitter.start, buf, lang)
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
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
        },
        per_filetype = {
          ["html"] = { enable_close = true },
          ["javascriptreact"] = { enable_close = true },
          ["typescriptreact"] = { enable_close = true },
        },
      })
    end,
  },

  -- Rainbow Delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
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
