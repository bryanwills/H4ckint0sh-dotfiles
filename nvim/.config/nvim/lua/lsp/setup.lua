-- Setup installer & lsp configs
local mason_ok, mason = pcall(require, "mason")
local mason_lsp_ok, mason_lsp = pcall(require, "mason-lspconfig")
local mason_tool_installer_ok, mason_tool_installer = pcall(require, "mason-tool-installer")

if not mason_ok or not mason_lsp_ok or not mason_tool_installer_ok then
	return
end

mason.setup({
	ui = {
		-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
		border = "rounded",
	},
})

mason_lsp.setup({
	-- A list of servers to automatically install if they're not already installed
	ensure_installed = {
		"bashls",
		"cssls",
		"eslint",
		"graphql",
		"html",
		"jsonls",
		"lua_ls",
		"ember",
		"prismals",
		"tailwindcss",
		"astro",
		"vtsls",
	},
	automatic_installation = true,
})

mason_tool_installer.setup({
	ensure_installed = {
		"prettier", -- prettier formatter
		"djlint", -- handlebars formatter
		"eslint", -- javascript formatter
	},
})

local lspconfig = require("lspconfig")

local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		silent = true,
		border = "rounded",
	}),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
	["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.diagnostic.on_publish_diagnostics,
		{ virtual_text = false }
	),
}

---@diagnostic disable-next-line: unused-local
local function on_attach(client, bufnr)
	-- disable as we use vtsls instead
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

require("mason-lspconfig").setup_handlers({
	-- The first entry (without a key) will be the default handler
	-- and will be called for each installed server that doesn't have
	-- a dedicated handler.
	function(server_name)
		require("lspconfig")[server_name].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			handlers = handlers,
		})
	end,

	["vtsls"] = function()
		require("lspconfig.configs").vtsls = require("vtsls").lspconfig

		lspconfig.vtsls.setup({
			capabilities = capabilities,
			handlers = require("lsp.servers.vtsls").handlers,
			on_attach = require("lsp.servers.vtsls").on_attach,
			settings = require("lsp.servers.vtsls").settings,
		})
	end,

	["tsserver"] = function()
		-- Skip since we use typescript.tools
	end,

	["tailwindcss"] = function()
		lspconfig.tailwindcss.setup({
			capabilities = require("lsp.servers.tailwindcss").capabilities,
			filetypes = require("lsp.servers.tailwindcss").filetypes,
			handlers = handlers,
			init_options = require("lsp.servers.tailwindcss").init_options,
			on_attach = require("lsp.servers.tailwindcss").on_attach,
			settings = require("lsp.servers.tailwindcss").settings,
		})
	end,

	["cssls"] = function()
		lspconfig.cssls.setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = require("lsp.servers.cssls").on_attach,
			settings = require("lsp.servers.cssls").settings,
		})
	end,

	["eslint"] = function()
		lspconfig.eslint.setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = require("lsp.servers.eslint").on_attach,
			settings = require("lsp.servers.eslint").settings,
		})
	end,

	["jsonls"] = function()
		lspconfig.jsonls.setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = on_attach,
			settings = require("lsp.servers.jsonls").settings,
		})
	end,

	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = on_attach,
			settings = require("lsp.servers.lua_ls").settings,
		})
	end,

	["vuels"] = function()
		lspconfig.vuels.setup({

			filetypes = require("lsp.servers.vuels").filetypes,
			handlers = handlers,
			init_options = require("lsp.servers.vuels").init_options,
			on_attach = require("lsp.servers.vuels").on_attach,
			settings = require("lsp.servers.vuels").settings,
		})
	end,
	["astro"] = function()
		lspconfig.astro.setup({})
	end,
	-- ["glint"] = function()
	-- 	lspconfig.glint.setup({
	-- 		cmd = { "glint-language-server" },
	-- 		filetypes = { "html.handlebars", "handlebars" },
	-- 		root_dir = vim.uv.cwd,
	-- 	})
	-- end,
	["ember"] = function()
		lspconfig.ember.setup({
			cmd = { "ember-language-server", "--stdio" },
			filetypes = { "handlebars" },
			root_dir = vim.uv.cwd,
		})
	end,
	["emmet-language-server"] = function()
		lspconfig.emmet_language_server.setup({})
	end,
})
