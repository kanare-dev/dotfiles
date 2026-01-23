-- Neovim 0.11+ native LSP configuration (no nvim-lspconfig dependency)

local function set_lsp_config(name, config)
  if type(vim.lsp.config) == "table" then
    vim.lsp.config[name] = vim.tbl_deep_extend("force", vim.lsp.config[name] or {}, config)
    return true
  end
  if type(vim.lsp.config) == "function" then
    vim.lsp.config(name, config)
    return true
  end
  return false
end

local function enable(name)
  if type(vim.lsp.enable) == "function" then
    vim.lsp.enable(name)
  end
end

-- marksman (Markdown)
if vim.fn.executable("marksman") == 1 then
  set_lsp_config("marksman", {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "markdown.mdx" },
    root_markers = { ".marksman.toml", ".git" },
    single_file_support = true,
  })
  enable("marksman")
end

-- lua-language-server (editing Neovim config)
if vim.fn.executable("lua-language-server") == 1 then
  set_lsp_config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    single_file_support = true,
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  })
  enable("lua_ls")
end

