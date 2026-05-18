local M = {}

local function find_csproj(dir)
  local files = vim.fn.globpath(dir, '*.csproj', false, true)
  if #files > 0 then
    return files[1]
  end
  local parent = vim.fn.fnamemodify(dir, ':h')
  if parent == dir then
    return nil
  end
  return find_csproj(parent)
end

local function dotnet_run_attach()
  local co = coroutine.running()
  local cwd = vim.fn.getcwd()
  local csproj_files = vim.fn.globpath(cwd, '**/*.csproj', false, true)

  if #csproj_files == 0 then
    vim.notify('No .csproj files found', vim.log.levels.WARN)
    return nil
  end

  vim.ui.select(csproj_files, {
    prompt = 'Select project:',
    format_item = function(item)
      return vim.fn.fnamemodify(item, ':~:.')
    end,
  }, function(csproj)
    if not csproj then
      coroutine.resume(co, nil)
      return
    end
    vim.cmd('belowright 15split | terminal dotnet run --project "' .. csproj .. '"')
    vim.defer_fn(function()
      coroutine.resume(co, true)
    end, 2000)
  end)

  if not coroutine.yield() then
    return nil
  end
  return require('dap.utils').pick_process()
end

local function get_cs_context()
  local node = vim.treesitter.get_node()
  while node and node:type() ~= 'method_declaration' do
    node = node:parent()
  end
  if not node then
    vim.notify('Not inside a method', vim.log.levels.WARN)
    return nil
  end
  local name_node = node:field('name')[1]
  if not name_node then
    vim.notify('Could not get method name', vim.log.levels.WARN)
    return nil
  end
  local method_name = vim.treesitter.get_node_text(name_node, 0)

  local class_node = node:parent()
  while class_node and class_node:type() ~= 'class_declaration' do
    class_node = class_node:parent()
  end
  local class_name = class_node and vim.treesitter.get_node_text(class_node:field('name')[1], 0)

  local ns_node = class_node and class_node:parent()
  while ns_node and ns_node:type() ~= 'namespace_declaration' and ns_node:type() ~= 'file_scoped_namespace_declaration' do
    ns_node = ns_node and ns_node:parent()
  end
  local namespace = ns_node and vim.treesitter.get_node_text(ns_node:field('name')[1], 0)

  local csproj = find_csproj(vim.fn.expand '%:p:h')
  if not csproj then
    vim.notify('No .csproj found', vim.log.levels.WARN)
    return nil
  end
  local assembly = vim.fn.fnamemodify(csproj, ':t:r')

  return { method_name = method_name, class_name = class_name, namespace = namespace, csproj = csproj, assembly = assembly }
end

local function run_choice(dap, choice)
  local function run_args()
    if choice.tunit then
      local args = { 'dotnet', 'run', '--project', choice.csproj, '--', '--treenode-filter', choice.treenode }
      if choice.debug then table.insert(args, '--debug') end
      return args
    else
      local args = { 'dotnet', 'test', choice.csproj, '--filter', 'FullyQualifiedName~' .. choice.filter }
      if choice.debug then table.insert(args, '--') ; table.insert(args, '--debug') end
      return args
    end
  end

  if choice.debug then
    vim.cmd 'belowright 8new'
    local bufnr = vim.api.nvim_get_current_buf()
    local chan = vim.api.nvim_open_term(bufnr, {})
    local attached = false
    vim.fn.jobstart(run_args(), {
      pty = true,
      on_stdout = function(_, data)
        for _, line in ipairs(data) do
          vim.api.nvim_chan_send(chan, line .. '\r\n')
          if not attached then
            local clean = line:gsub('\27%[[%d;]*[A-Za-z]', ''):gsub('\27%[%?%d+[hl]', '')
            local pid = clean:match 'Process Id[^%d]*(%d+)'
              or clean:match 'process with Id[^%d]*(%d+)'
              or clean:match 'PID[^%d]*(%d+)'
            if pid then
              attached = true
              local pid_num = tonumber(pid)
              vim.fn.system('kill -STOP ' .. pid_num)
              local key = 'tunit_cont_' .. tostring(pid_num)
              dap.listeners.after.configurationDone[key] = function()
                dap.listeners.after.configurationDone[key] = nil
                vim.fn.system('kill -CONT ' .. pid_num)
              end
              vim.schedule(function()
                dap.run { type = 'coreclr', name = 'attach - test debug', request = 'attach', processId = pid_num }
              end)
            end
          end
        end
      end,
    })
  else
    vim.cmd 'belowright 15new'
    vim.fn.termopen(run_args())
  end
end

local function setup_test_runner(dap)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'cs',
    group = vim.api.nvim_create_augroup('her0elt-dotnet-test', { clear = true }),
    callback = function(ev)
      vim.keymap.set('n', '<leader>ttm', function()
        local ctx = get_cs_context()
        if not ctx then return end
        local treenode = string.format('/%s/%s/%s/%s', ctx.assembly, ctx.namespace or '*', ctx.class_name or '*', ctx.method_name)
        local runners = {
          { label = 'dotnet test — run',   tunit = false, debug = false, csproj = ctx.csproj, filter = ctx.method_name },
          { label = 'dotnet test — debug', tunit = false, debug = true,  csproj = ctx.csproj, filter = ctx.method_name },
          { label = 'TUnit — run',         tunit = true,  debug = false, csproj = ctx.csproj, treenode = treenode },
          { label = 'TUnit — debug',       tunit = true,  debug = true,  csproj = ctx.csproj, treenode = treenode },
        }
        vim.ui.select(runners, { prompt = 'Run method:', format_item = function(r) return r.label end }, function(choice)
          if choice then run_choice(dap, choice) end
        end)
      end, { buffer = ev.buf, desc = 'Run dotnet test method under cursor' })

      vim.keymap.set('n', '<leader>ttc', function()
        local ctx = get_cs_context()
        if not ctx then return end
        local class_filter = (ctx.namespace and (ctx.namespace .. '.') or '') .. (ctx.class_name or '*')
        local class_treenode = string.format('/%s/%s/%s/*', ctx.assembly, ctx.namespace or '*', ctx.class_name or '*')
        local runners = {
          { label = 'dotnet test — run',   tunit = false, debug = false, csproj = ctx.csproj, filter = class_filter },
          { label = 'dotnet test — debug', tunit = false, debug = true,  csproj = ctx.csproj, filter = class_filter },
          { label = 'TUnit — run',         tunit = true,  debug = false, csproj = ctx.csproj, treenode = class_treenode },
          { label = 'TUnit — debug',       tunit = true,  debug = true,  csproj = ctx.csproj, treenode = class_treenode },
        }
        vim.ui.select(runners, { prompt = 'Run class:', format_item = function(r) return r.label end }, function(choice)
          if choice then run_choice(dap, choice) end
        end)
      end, { buffer = ev.buf, desc = 'Run all dotnet tests in class' })
    end,
  })
end

function M.setup(dap)
  local debuggers_folder = vim.fn.stdpath 'data' .. '/mason'
  dap.adapters.coreclr = {
    type = 'executable',
    command = debuggers_folder .. '/packages/netcoredbg/netcoredbg',
    args = { '--interpreter=vscode' },
  }
  dap.adapters.netcoredbg = dap.adapters.coreclr
  dap.adapters.dotnet = dap.adapters.coreclr

  vim.schedule(function()
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'dotnet run --project (attach)',
        request = 'attach',
        processId = dotnet_run_attach,
      },
      {
        type = 'coreclr',
        name = 'attach - netcoredbg',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }
  end)

  setup_test_runner(dap)
end

return M
