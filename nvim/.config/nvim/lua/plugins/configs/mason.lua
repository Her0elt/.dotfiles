local options = {
  ensure_installed = {
    "lua-language-server",
    "stylua",
    "shellcheck",
    "shfmt",
    "flake8",
    "black",
    "isort",
    "astro-language-server",
    "clangd",
    "codelldb",
    "cpptools",
    "css-lsp",
    "cssmodules-language-server",
    "eslint-lsp",
    "java-debug-adapter",
    "java-test",
    "jdtls",
    "js-debug-adapter",
    "json-lsp",
    "lua-language-server",
    "prettierd",
    "prisma-language-server",
    "pyright",
    "rust-analyzer",
    "shfmt",
    "stylua",
    "taplo",
    "typescript-language-server",
    "tailwindcss-language-server",
    "zls",
  }, -- not an option from mason.nvim

  PATH = "skip",

  ui = {
    icons = {
      package_pending = " ",
      package_installed = "󰄳 ",
      package_uninstalled = " 󰚌",
    },

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  max_concurrent_installers = 10,
}

return options
