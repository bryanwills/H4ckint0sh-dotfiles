return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = {
			enabled = true,
			notify = true,
			size = 100 * 1024, -- 100 KB
		},
		picker = {
			-- My ~/github/dotfiles-latest/neovim/lazyvim/lua/config/keymaps.lua
			-- file was always showing at the top, I needed a way to decrease its
			-- score, in frecency you could use :FrecencyDelete to delete a file
			-- from the database, here you can decrease it's score
			transform = function(item)
				if not item.file then
					return item
				end
				-- Demote the "lazyvim" keymaps file:
				if item.file:match("lazyvim/lua/config/keymaps%.lua") then
					item.score_add = (item.score_add or 0) - 30
				end
				-- Boost the "neobean" keymaps file:
				-- if item.file:match("neobean/lua/config/keymaps%.lua") then
				--   item.score_add = (item.score_add or 0) + 100
				-- end
				return item
			end,
			-- In case you want to make sure that the score manipulation above works
			-- or if you want to check the score of each file
			debug = {
				scores = true, -- show scores in the list
			},
			-- I like the "ivy" layout, so I set it as the default globaly, you can
			-- still override it in different keymaps
			layout = {
				preset = "ivy",
				-- When reaching the bottom of the results in the picker, I don't want
				-- it to cycle and go back to the top
				cycle = false,
			},
			layouts = {
				-- I wanted to modify the ivy layout height and preview pane width,
				-- this is the only way I was able to do it
				-- NOTE: I don't think this is the right way as I'm declaring all the
				-- other values below, if you know a better way, let me know
				--
				-- Then call this layout in the keymaps above
				-- got example from here
				-- https://github.com/folke/snacks.nvim/discussions/468
				ivy = {
					layout = {
						box = "vertical",
						backdrop = false,
						row = -1,
						width = 0,
						height = 0.5,
						border = "top",
						title = " {title} {live} {flags}",
						title_pos = "left",
						{ win = "input", height = 1, border = "bottom" },
						{
							box = "horizontal",
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", width = 0.5, border = "left" },
						},
					},
				},
				-- I wanted to modify the layout width
				--
				vertical = {
					layout = {
						backdrop = false,
						width = 0.8,
						min_width = 80,
						height = 0.8,
						min_height = 30,
						box = "vertical",
						border = "rounded",
						title = "{title} {live} {flags}",
						title_pos = "center",
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
						{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
					},
				},
			},
			matcher = {
				frecency = true,
			},
			actions = {
				flash = function(picker)
					require("flash").jump({
						pattern = "^",
						label = { after = { 0, 0 } },
						search = {
							mode = "search",
							exclude = {
								function(win)
									return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
								end,
							},
						},
						action = function(match)
							local idx = picker.list:row2idx(match.pos[1])
							picker.list:_move(idx, true, true)
						end,
					})
				end,
			},
			win = {
				input = {
					keys = {
						-- to close the picker on ESC instead of going to normal mode,
						-- add the following keymap to your config
						["<Esc>"] = { "close", mode = { "n", "i" } },
						-- I'm used to scrolling like this in LazyGit
						["J"] = { "preview_scroll_down", mode = { "i", "n" } },
						["K"] = { "preview_scroll_up", mode = { "i", "n" } },
						-- ["H"] = { "preview_scroll_left", mode = { "i", "n" } },
						-- ["L"] = { "preview_scroll_right", mode = { "i", "n" } },
						["<a-s>"] = { "flash", mode = { "n", "i" } },
						["s"] = { "flash" },
					},
				},
			},
		},
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		quickfile = { enabled = true },
		statuscolumn = { enabled = false },
		words = { enabled = true },
		styles = {
			notification = {
				wo = {
					winblend = 0,
				},
			},
		},
		indent = {
			char = "│",
			scope = { hl = "Normal" },
			chunk = {
				enabled = true,
				hl = "Normal",
			},
		},
		scope = {},
		lazygit = {
			theme = {
				activeBorderColor = { fg = "MatchParen", bold = true },
			},
		},
		scroll = {
			enabled = false,
			animate = {
				duration = { step = 15, total = 150 },
				easing = "linear",
			},
		},
		dashboard = {
			width = 50,
			row = nil, -- dashboard position. nil for center
			col = nil, -- dashboard position. nil for center
			pane_gap = 4, -- empty columns between vertical panes
			autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
			-- These settings are used by some built-in sections
			preset = {
				pick = nil,
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = "󰺯 ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{
						icon = " ",
						key = "s",
						desc = "Restore Session",
						action = "<cmd>SessionLoad<cr>",
					},
					{
						icon = "󰒲 ",
						key = "l",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = "⏻ ", key = "q", desc = "Quit", action = ":qa" },
				},
				-- Used by the `header` section
				header = [[
██████████████████████████████████████████████████
█████ ████████████████████████████████████████
████   ███  ████████████████  █ ███████████
███     █     █     ██  ████ █ ███
██  █       ██ ██    █        ██
██  ███   █   ██ ██ █   █  █ █  ██
███████ ██    █    ███ █  █████ ██
██████████████████████████████████████████████████]],
			},
			-- item field formatters
			formats = {
				icon = function(item)
					if item.file and item.icon == "file" or item.icon == "directory" then
						return M.icon(item.file, item.icon)
					end
					return { item.icon, width = 2, hl = "icon" }
				end,
				footer = { "%s", align = "center" },
				header = { "%s", align = "center", width = 60 },
				file = function(item, ctx)
					local fname = vim.fn.fnamemodify(item.file, ":~")
					fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
					if #fname > ctx.width then
						local dir = vim.fn.fnamemodify(fname, ":h")
						local file = vim.fn.fnamemodify(fname, ":t")
						if dir and file then
							file = file:sub(-(ctx.width - #dir - 2))
							fname = dir .. "/…" .. file
						end
					end
					local dir, file = fname:match("^(.*)/(.+)$")
					return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
				end,
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "startup" },
			},
		},
	},
	-- stylua: ignore
    keys = {
		{ '<leader>N', function() Snacks.notifier.hide() end },
		{ "<c-t>", function() Snacks.terminal.toggle() end },
		{ "<leader>x", function() Snacks.bufdelete() end },
		{ "<leader>br", function() Snacks.gitbrowse() end },
		{"<leader>fr", function() Snacks.rename.rename_file() end},
		{ "<leader>X", function() Snacks.bufdelete.all() end, desc = "Delete all buffer" },
		{ "<leader>gb", function() Snacks.gitbrowse() end, desc = "Git Browse" },
		{ "<leader>fh", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
		{ "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
		{ "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
		{ "<leader>z",  function() Snacks.zen() end, desc = "ZEN" },
		{ "<leader>,", function() Snacks.picker.buffers(
			{
            -- I always want my buffers picker to start in normal mode
            on_show = function()
              vim.cmd.stopinsert()
            end,
            finder = "buffers",
            format = "buffer",
            hidden = false,
            unloaded = true,
            current = true,
            sort_lastused = true,
            win = {
              input = {
                keys = {
                  ["d"] = "bufdelete",
                },
              },
              list = { keys = { ["d"] = "bufdelete" } },
            },
            -- In case you want to override the layout for this keymap
            -- layout = "ivy",
          }
		) end, desc = "Buffers" },
		{ "<leader>t", function() Snacks.picker.grep({ layout = { preset = "ivy" } , hidden = true }) end, desc = "Grep" },
		{ "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
		{ "<leader>f", function() Snacks.picker.files({
            finder = "files",
            format = "file",
			hidden = true,
            show_empty = true,
            supports_live = true,
            -- In case you want to override the layout for this keymap
            -- layout = "vscode",
          }) end, desc = "Find Files" },
		-- find
		{ "<leader>b", function() Snacks.picker.buffers({
            -- I always want my buffers picker to start in normal mode
            on_show = function()
              vim.cmd.stopinsert()
            end,
            finder = "buffers",
            format = "buffer",
            hidden = false,
            unloaded = true,
            current = true,
            sort_lastused = true,
            win = {
              input = {
                keys = {
                  ["d"] = "bufdelete",
                },
              },
              list = { keys = { ["d"] = "bufdelete" } },
            },
            -- In case you want to override the layout for this keymap
            -- layout = "ivy",
          }) end, desc = "Buffers" },
		{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
		{ "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
		{ "<leader>fh", function() Snacks.picker.recent({layout = { preset = "select" } }) end, desc = "Recent" },
		-- git
		{ "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Log" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		-- Grep
		{ "<leader>sb", function() Snacks.picker.lines({ layout = { preset = "ivy" } }) end, desc = "Buffer Lines" },
		{ "<leader>sB", function() Snacks.picker.grep_buffers({ layout = { preset = "ivy" } }) end, desc = "Grep Open Buffers" },
		{ "<leader>sg", function() Snacks.picker.grep({ layout = { preset = "ivy" } }) end, desc = "Grep" },
		{ "<leader>sw", function() Snacks.picker.grep_word({layout = { preset = "ivy" } }) end, desc = "Visual selection or word", mode = { "n", "x" } },
		-- search
		{ '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
		{ "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
		{ "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
		{ "<leader>sC", function() Snacks.picker.commands({ layout = { preset = "vscode" } }) end, desc = "Commands" },
		{ "<leader>d", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
		{ "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
		{ "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
		{ "<leader>j", function() Snacks.picker.jumps() end, desc = "Jumps" },
		{ "<leader>k", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
		{ "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
		{ "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
		{ "<leader>m", function() Snacks.picker.marks() end, desc = "Marks" },
		{ "<leader>`", function() Snacks.picker.resume() end, desc = "Resume" },
		{ "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
		{ "<leader>u", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
		{ "<leader>qp", function() Snacks.picker.projects() end, desc = "Projects" },
		-- LSP
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
		{ "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
		{ "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
		{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
		{ "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.inlay_hints():map("<leader>uh")
			end,
		})
	end,
}
