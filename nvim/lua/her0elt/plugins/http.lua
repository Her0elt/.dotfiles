return {
  { -- kulala.nvim: VSCode REST Client-style HTTP runner for .http files
    'mistweaverco/kulala.nvim',
    keys = {
      { '<leader>h', '', desc = '+Rest (http)' },
      {
        '<leader>hs',
        function()
          require('kulala').run()
        end,
        ft = { 'http', 'rest' },
        desc = 'Send request',
      },
      {
        '<leader>ha',
        function()
          require('kulala').run_all()
        end,
        ft = { 'http', 'rest' },
        desc = 'Send all requests',
      },
      {
        '<leader>hb',
        function()
          require('kulala').scratchpad()
        end,
        desc = 'Open scratchpad',
      },
      {
        '<leader>hc',
        function()
          require('kulala').copy()
        end,
        ft = { 'http', 'rest' },
        desc = 'Copy as cURL',
      },
      {
        '<leader>hC',
        function()
          require('kulala').from_curl()
        end,
        desc = 'Paste from cURL',
      },
      {
        '<leader>hp',
        function()
          require('kulala').jump_prev()
        end,
        ft = { 'http', 'rest' },
        desc = 'Jump to previous request',
      },
      {
        '<leader>hn',
        function()
          require('kulala').jump_next()
        end,
        ft = { 'http', 'rest' },
        desc = 'Jump to next request',
      },
      {
        '<leader>hr',
        function()
          require('kulala').replay()
        end,
        ft = { 'http', 'rest' },
        desc = 'Replay last request',
      },
      {
        '<leader>ht',
        function()
          require('kulala').toggle_view()
        end,
        ft = { 'http', 'rest' },
        desc = 'Toggle headers/body view',
      },
      {
        '<leader>he',
        function()
          require('kulala').set_selected_env()
        end,
        desc = 'Select environment (profile)',
      },
      {
        '<leader>hq',
        function()
          require('kulala').close()
        end,
        ft = { 'http', 'rest' },
        desc = 'Close response window',
      },
    },
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = false, -- we define our own <leader>R maps above
      default_view = 'body',
      default_env = 'dev',
      split_direction = 'vertical',
    },
  },
}
