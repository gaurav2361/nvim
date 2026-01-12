-- if a file is a .env or .envrc file, set the filetype to sh
vim.filetype.add({
  extension = {
    mdx = "mdx",
    env = "dotenv",
    base = "yaml",
  },
  filename = {
    [".env"] = "sh",
    [".envrc"] = "sh",
    ["*.env"] = "sh",
    ["*.env.*"] = "sh",
    ["*.envrc"] = "sh",
    ["env"] = "dotenv",
    [".base"] = "yaml",
  },
  pattern = {
    ["[jt]sconfig.*.json"] = "jsonc",
    ["%.env%.[%w_.-]+"] = "dotenv",
  },
})
