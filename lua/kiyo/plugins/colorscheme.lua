return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false, -- Load immediately
  priority = 500, -- Ensure it loads before other plugins
  opts = {
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = { -- :h background
      light = "latte",
      dark = "mocha",
    },
    transparent_background = true, -- disables setting the background color.
    integrations = {
      aerial = true,
      cmp = true,
      blink_cmp = true,
      flash = true,
      fzf = true,
      grug_far = true,
      gitsigns = true,
      headlines = true,
      illuminate = true,
      indent_blankline = { enabled = true },
      leap = true,
      lsp_trouble = true,
      mason = true,
      markdown = true,
      mini = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
        virtual_text = {
          errors = "italic",
          hints = "italic",
          warnings = "italic",
          information = "italic",
        },
      },
      navic = { enabled = true, custom_bg = "lualine" },
      neotest = true,
      neotree = true,
      noice = true,
      notify = true,
      semantic_tokens = true,
      snacks = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts) -- pass the opts to the plugin
    vim.cmd.colorscheme("catppuccin-nvim") -- apply the colorscheme
  end,
}
