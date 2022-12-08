local Remap = require("her0elt.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap
local lsp = require('lsp-zero')

lsp.preset('recommended')


lsp.ensure_installed({
    'tsserver',
    'eslint',
    'sumneko_lua',
    'rust_analyzer',
    'jedi_language_server',
    'gopls',
})


local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
		["<C-n>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-p>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-Space>"] = cmp.mapping.complete(),
})

lsp.set_preferences({
    sign_icons = { }
})


lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})


lsp.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}
    nnoremap("gd", function() vim.lsp.buf.definition() end, opts)
    nnoremap("K", function() vim.lsp.buf.hover() end, opts)
    nnoremap("<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    nnoremap("<leader>vd", function() vim.diagnostic.open_float() end, opts)
    nnoremap("[d", function() vim.diagnostic.goto_next() end, opts)
    nnoremap("]d", function() vim.diagnostic.goto_prev() end, opts)
    nnoremap("<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    nnoremap("<leader>vco", function() vim.lsp.buf.code_action({
        filter = function(code_action)
            if not code_action or not code_action.data then
                return false
            end

            local data = code_action.data.id
            return string.sub(data, #data - 1, #data) == ":0"
        end,
        apply = true
    }) end, opts)
    nnoremap("<leader>vrr", function() vim.lsp.buf.references() end, opts)
    nnoremap("<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    inoremap("<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)



lsp.setup()
