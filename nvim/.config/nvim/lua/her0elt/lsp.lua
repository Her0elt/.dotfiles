vim.lsp.set_log_level("debug")

require'lspconfig'.rust_analyzer.setup{}
--require("lspconfig").ccls.setup()
--require("lspconfig").tsserver.setup(config())
--require'lspconfig'.ccls.setup{}
require'lspconfig'.clangd.setup{
 cmd = { "clangd-12", "--background-index" },
}
require'lspconfig'.pyright.setup{}
