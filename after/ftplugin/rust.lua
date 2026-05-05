local bufnr = vim.api.nvim_get_current_buf()

-- Hover actions (replaces standard K for better Rust support)
vim.keymap.set("n", "K", function()
  vim.cmd.RustLsp({ "hover", "actions" })
end, { silent = true, buffer = bufnr, desc = "Rust Hover Actions" })

-- Grouped Code Actions (superior to standard lsp code actions)
vim.keymap.set("n", "<leader>ca", function()
  vim.cmd.RustLsp("codeAction")
end, { silent = true, buffer = bufnr, desc = "Rust Code Action" })

-- Explain Error
vim.keymap.set("n", "<leader>ce", function()
  vim.cmd.RustLsp("explainError")
end, { silent = true, buffer = bufnr, desc = "Rust Explain Error" })

-- Render Diagnostic (useful for complex borrow checker errors)
vim.keymap.set("n", "<leader>rd", function()
  vim.cmd.RustLsp("renderDiagnostic")
end, { silent = true, buffer = bufnr, desc = "Rust Render Diagnostic" })

-- Open Cargo.toml
vim.keymap.set("n", "<leader>oc", function()
  vim.cmd.RustLsp("openCargo")
end, { silent = true, buffer = bufnr, desc = "Open Cargo.toml" })

-- Expand Macro
vim.keymap.set("n", "<leader>em", function()
  vim.cmd.RustLsp("expandMacro")
end, { silent = true, buffer = bufnr, desc = "Expand Macro Recursively" })

-- Fly Check (Run clippy manually if needed)
vim.keymap.set("n", "<leader>cf", function()
  vim.cmd.RustLsp("flyCheck")
end, { silent = true, buffer = bufnr, desc = "Rust FlyCheck" })
