local lsp = require("lspconfig")

vim.tbl_deep_extend("keep", lsp, {
  lsp_name = {
    cmd = { "programming-language-lsp" },
    filetypes = { "mon" },
    name = "monkey_lsp",
    root_dir = vim.loop.cwd(),
    autostart = true,
  },
})
function Restart_monkey_lsp()
  require("lsp-debug-tools").restart({
    cmd = { "programming-language-lsp" },
    filetypes = { "mon" },
    name = "monkey_lsp",
    autostart = true,
    root_dir = vim.loop.cwd(),
  })
end
