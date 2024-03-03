local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = {
  "tsserver",
  "astro",
  "clangd",
  "jdtls",
  "lua_ls",
  "jedi_language_server",
  "cssmodules_ls",
  "cssls",
  "prismals",
  "pyright",
  "rust_analyzer",
  "taplo",
  "tailwindcss",
  "zls",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

local null_ls = require "null-ls"

null_ls.setup {
  debug = false,
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd.with {
      filetypes = {
        "css",
        "scss",
        "less",
        "html",
        "json",
        "yaml",
        "markdown",
        "graphql",
      },
    },
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.completion.spell,
  },

  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      local format_on_save = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = format_on_save,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format {
            bufnr = bufnr,
            async = false,
            filter = function(_client)
              return _client.name == "null-ls"
            end,
          }
        end,
      })
    end
  end,
}
--
-- lspconfig.pyright.setup { blabla}
