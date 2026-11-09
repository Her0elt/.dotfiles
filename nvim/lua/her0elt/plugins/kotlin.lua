local M = {}

--- Nearest `gradlew` walking upward from `start`. Returns (project_dir, gradlew_path) or nil.
local function project_root(start)
  local found = vim.fs.find('gradlew', { upward = true, path = start, type = 'file', limit = 1 })
  if #found == 0 then
    return nil, nil
  end
  return vim.fs.dirname(found[1]), found[1]
end

--- First named descendant child of `node` whose type is in `types` (depth-1 scan).
local function child_of_type(node, types)
  if not node then
    return nil
  end
  for child in node:iter_children() do
    if child:named() and vim.tbl_contains(types, child:type()) then
      return child
    end
  end
  return nil
end

--- Walk up from `node` to the first ancestor of one of `types`.
local function ancestor_of_type(node, types)
  while node and not vim.tbl_contains(types, node:type()) do
    node = node:parent()
  end
  return node
end

--- Treesitter context at the cursor: test method name, class name, package, project paths.
--- Analogous to dotnet.lua's get_cs_context(), but for the tree-sitter-kotlin grammar.
local function get_kotlin_context()
  local node = vim.treesitter.get_node()
  if not node then
    vim.notify('No treesitter node (is the kotlin parser installed?)', vim.log.levels.WARN)
    return nil
  end

  local fn = ancestor_of_type(node, { 'function_declaration' })
  if not fn then
    vim.notify('Not inside a function', vim.log.levels.WARN)
    return nil
  end
  local name_node = child_of_type(fn, { 'simple_identifier' })
  if not name_node then
    vim.notify('Could not read function name', vim.log.levels.WARN)
    return nil
  end
  -- Kotlin allows backtick-quoted names (`a test with spaces`); strip the backticks for Gradle.
  local method = vim.treesitter.get_node_text(name_node, 0):gsub('^`', ''):gsub('`$', '')

  local class = ancestor_of_type(fn, { 'class_declaration', 'object_declaration' })
  local class_name_node = class and child_of_type(class, { 'type_identifier' })
  local class_name = class_name_node and vim.treesitter.get_node_text(class_name_node, 0)
  if not class_name then
    vim.notify('Could not find the enclosing class', vim.log.levels.WARN)
    return nil
  end

  -- Package from the top-level `package_header`, e.g. "package com.foo.bar" -> "com.foo.bar".
  local pkg
  local root = vim.treesitter.get_parser(0):parse()[1]:root()
  local pkg_node = child_of_type(root, { 'package_header' })
  if pkg_node then
    pkg = vim.treesitter.get_node_text(pkg_node, 0):gsub('^package%s+', ''):gsub('[%s;]+$', '')
    if pkg == '' then
      pkg = nil
    end
  end

  local dir, gradlew = project_root(vim.fn.expand '%:p:h')
  if not gradlew then
    vim.notify('No gradlew found upward from this file', vim.log.levels.WARN)
    return nil
  end

  local fqn = pkg and (pkg .. '.' .. class_name) or class_name
  return { method = method, class = class_name, fqn = fqn, dir = dir, gradlew = gradlew }
end

--- Run `./gradlew test --tests <filter>` in a terminal split. When debug, suspend the JVM on JDWP
--- :5005 (--debug-jvm) and attach nvim-dap. The attach path is best-effort (Gradle/JVM debugging
--- is finicky and may need per-project tweaks).
local function run_gradle_test(ctx, filter, debug, dap)
  -- `cleanTest` first: otherwise Gradle reports the `test` task UP-TO-DATE and skips re-running
  -- when nothing changed since the last run (so it would only "build"). --console=plain keeps the
  -- terminal output readable.
  local args = { ctx.gradlew, 'cleanTest', 'test', '--tests', filter, '--console=plain' }
  if debug then
    table.insert(args, '--debug-jvm')
  end
  vim.cmd 'belowright 15new'
  vim.fn.termopen(args, { cwd = ctx.dir })
  if debug then
    vim.schedule(function()
      dap.run(dap.configurations.kotlin[1])
    end)
  end
end

local function pick_and_run(ctx, filter, dap)
  local runners = {
    { label = 'gradle test — run', debug = false },
    { label = 'gradle test — debug (experimental)', debug = true },
  }
  vim.ui.select(runners, {
    prompt = 'Run ' .. filter .. ':',
    format_item = function(r)
      return r.label
    end,
  }, function(choice)
    if choice then
      run_gradle_test(ctx, filter, choice.debug, dap)
    end
  end)
end

local function setup_test_runner(dap)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'kotlin',
    group = vim.api.nvim_create_augroup('her0elt-kotlin-test', { clear = true }),
    callback = function(ev)
      vim.keymap.set('n', '<leader>ttm', function()
        local ctx = get_kotlin_context()
        if not ctx then
          return
        end
        pick_and_run(ctx, ctx.fqn .. '.' .. ctx.method, dap)
      end, { buffer = ev.buf, desc = 'Run gradle test method under cursor' })

      vim.keymap.set('n', '<leader>ttc', function()
        local ctx = get_kotlin_context()
        if not ctx then
          return
        end
        pick_and_run(ctx, ctx.fqn, dap)
      end, { buffer = ev.buf, desc = 'Run all gradle tests in class' })
    end,
  })
end

function M.setup(dap)
  local mason = vim.fn.stdpath 'data' .. '/mason'
  dap.adapters.kotlin = {
    type = 'executable',
    command = mason .. '/bin/kotlin-debug-adapter',
  }
  -- Attach to a JVM started with `./gradlew test --debug-jvm` (JDWP, suspended on :5005).
  dap.configurations.kotlin = {
    {
      type = 'kotlin',
      request = 'attach',
      name = 'Attach to gradle --debug-jvm',
      hostName = '127.0.0.1',
      port = 5005,
      timeout = 2000,
      projectRoot = '${workspaceFolder}',
    },
  }

  setup_test_runner(dap)

  vim.api.nvim_create_user_command('GradleTestAll', function()
    local dir, gradlew = project_root(vim.fn.expand '%:p:h')
    if not gradlew then
      dir, gradlew = project_root(vim.fn.getcwd())
    end
    if not gradlew then
      vim.notify('No gradlew found', vim.log.levels.WARN)
      return
    end
    vim.cmd 'belowright 15new'
    vim.fn.termopen({ gradlew, 'cleanTest', 'test', '--console=plain' }, { cwd = dir })
  end, { desc = 'Run the whole gradle test suite' })
end

return M
