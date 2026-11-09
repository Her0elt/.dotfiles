--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
  if not vim.version.cmp then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", tostring(vim.version())))
    return
  end

  if vim.version.cmp(vim.version(), { 0, 9, 4 }) >= 0 then
    vim.health.ok(string.format("Neovim version is: '%s'", tostring(vim.version())))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", tostring(vim.version())))
  end
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

local check_dotnet = function()
  vim.health.start '.NET toolchain'

  if vim.fn.executable 'dotnet' == 1 then
    local ver = vim.fn.system('dotnet --version'):gsub('%s+$', '')
    vim.health.ok('dotnet SDK: ' .. ver)
  else
    vim.health.error 'dotnet not on PATH'
  end

  local jb = vim.fn.expand '~/.dotnet/tools/jb'
  if vim.fn.executable(jb) == 1 then
    vim.health.ok('JetBrains CLI: ' .. jb)
  else
    vim.health.warn('jb not found at ' .. jb .. ' (install: dotnet tool install -g JetBrains.ReSharper.GlobalTools)')
  end

  local mason = vim.fn.stdpath 'data' .. '/mason/packages'
  for _, pkg in ipairs { 'netcoredbg', 'roslyn' } do
    if vim.fn.isdirectory(mason .. '/' .. pkg) == 1 then
      vim.health.ok('Mason package: ' .. pkg)
    else
      vim.health.warn('Mason package missing: ' .. pkg)
    end
  end
end

local check_kotlin = function()
  vim.health.start 'Kotlin toolchain'

  for _, exe in ipairs { 'gradle', 'java' } do
    if vim.fn.executable(exe) == 1 then
      vim.health.ok('Found executable: ' .. exe)
    else
      vim.health.warn(exe .. ' not on PATH (gradle wrappers still work via ./gradlew)')
    end
  end

  local mason = vim.fn.stdpath 'data' .. '/mason/packages'
  for _, pkg in ipairs { 'kotlin-lsp', 'kotlin-debug-adapter', 'ktlint' } do
    if vim.fn.isdirectory(mason .. '/' .. pkg) == 1 then
      vim.health.ok('Mason package: ' .. pkg)
    else
      vim.health.warn('Mason package missing: ' .. pkg .. ' (install via :Mason)')
    end
  end

  local server = vim.fn.stdpath 'data' .. '/mason/bin/intellij-server'
  if vim.fn.executable(server) == 1 then
    -- Surface the installed EAP build version. JetBrains ships kotlin-lsp as pre-alpha builds
    -- with a HARD EXPIRY (~1-2 months): once expired, intellij-server prints "This build has
    -- expired" to stderr and exits immediately, so the LSP never attaches. Fix by refreshing the
    -- registry and reinstalling: `:MasonUpdate` then `:MasonInstall kotlin-lsp`, then restart nvim.
    local dirs = vim.fn.glob(mason .. '/kotlin-lsp/kotlin-server-*', false, true)
    local version = dirs[1] and vim.fn.fnamemodify(dirs[1], ':t') or '(unknown build)'
    vim.health.ok('kotlin-lsp binary: ' .. server .. ' [' .. version .. ']')
    vim.health.info 'kotlin-lsp is a pre-alpha EAP build that EXPIRES. If it stops attaching, run :MasonUpdate then :MasonInstall kotlin-lsp and restart nvim.'
  else
    vim.health.warn('kotlin-lsp binary not found at ' .. server)
  end

  if #vim.api.nvim_get_runtime_file('parser/kotlin.so', false) > 0 then
    vim.health.ok 'Treesitter kotlin parser installed'
  else
    vim.health.warn 'Treesitter kotlin parser missing (:TSInstall kotlin)'
  end
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_dotnet()
    check_kotlin()
  end,
}
