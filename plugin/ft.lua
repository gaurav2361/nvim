-- if a file is a .env or .envrc file, set the filetype to sh
vim.filetype.add({
  extension = {
    mdx = "mdx",
    env = "dotenv",
    base = "yaml",
    rasi = "rasi",
    rofi = "rasi",
    wofi = "rasi",
    tf = "terraform",
  },
  filename = {
    [".env"] = "sh",
    [".envrc"] = "sh",
    ["*.env"] = "sh",
    ["*.env.*"] = "sh",
    ["*.envrc"] = "sh",
    ["env"] = "dotenv",
    [".base"] = "yaml",
    ["vifmrc"] = "vim",
  },
  pattern = {
    ["[jt]sconfig.*.json"] = "jsonc",
    -- ["%.env%.[%w_.-]+"] = "dotenv",
    [".*/waybar/config"] = "jsonc",
    [".*/mako/config"] = "dosini",
    [".*/kitty/.+%.conf"] = "kitty",
    [".*/hypr/.+%.conf"] = "hyprlang",
    ["%.env%.[%w_.-]+"] = "sh",
    [".*/git/config"] = "gitconfig",
  },
})
