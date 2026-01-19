return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "davidmh/mdx.nvim" },
    build = ":TSUpdate",
    branch = "main",
    opts_extend = { "ensure_installed" },
    opts = {
      -- ensure these languages parsers are installed
      ensure_installed = {
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
        "c",
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
        "gitignore",
        "hyprlang",
      },
    },
    config = function(_, opts)
      -- Setup nvim-treesitter (new API)
      require("nvim-treesitter").setup({
        -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      vim.filetype.add({
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi", tf = "terraform" },
        filename = {
          ["vifmrc"] = "vim",
        },
        pattern = {
          [".*/waybar/config"] = "jsonc",
          [".*/mako/config"] = "dosini",
          [".*/kitty/.+%.conf"] = "kitty",
          [".*/hypr/.+%.conf"] = "hyprlang",
          ["%.env%.[%w_.-]+"] = "sh",
          [".*/git/config"] = "gitconfig",
        },
      })

      vim.treesitter.language.register("bash", "kitty")

      if vim.fn.executable("hypr") == 1 then
        table.insert(opts.ensure_installed, "hyprlang")
      end

      if vim.fn.executable("fish") == 1 then
        table.insert(opts.ensure_installed, "fish")
      end

      if vim.fn.executable("rofi") == 1 or vim.fn.executable("wofi") == 1 then
        table.insert(opts.ensure_installed, "rasi")
      end

      -- Install parsers manually as 'auto_install' is removed from setup
      if opts.ensure_installed and #opts.ensure_installed > 0 then
        require("nvim-treesitter").install(opts.ensure_installed)
      end

      -- Safely enable features via FileType autocmd
      -- This prevents "Parser could not be created" error during initial load/install
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local ok, err = pcall(vim.treesitter.start)
          if not ok then
            -- Silent return ensures no crash if parser isn't ready
            return
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
          -- enable_close_on_slash = false, -- Disable auto-close on trailing `</`
        },
        per_filetype = {
          ["html"] = {
            enable_close = true, -- Disable auto-closing for HTML
          },
          ["typescriptreact"] = {
            enable_close = true, -- Explicitly enable auto-closing (optional, defaults to `true`)
          },
        },
      })
    end,
  },
  -- Enable tree-sitter highlight for inline code in .nix files
  {
    "calops/hmts.nvim",
    version = "*",
  },
}
