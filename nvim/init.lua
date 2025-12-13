vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.encoding = "UTF-8"
vim.opt.autoread = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 4
vim.opt.mouse = "a"
vim.opt.wildmenu = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.belloff = "all"
vim.opt.winborder = "rounded"
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1
vim.opt.guicursor = "n-v-i-c:block-Cursor"

vim.g.mapleader = " "
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v", "x" }, "<leader>P", '"+P')
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>E", ":edit .<CR>")
vim.keymap.set("n", "<leader>e", ":edit %:h<CR>")
vim.keymap.set("n", "<leader>r", ":edit #<CR>")
vim.keymap.set("n", "<leader>o", ":copen<CR>")
vim.keymap.set("n", "<leader>t", ":tabnew | terminal<CR>")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format)
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { buffer = true })

if vim.fn.executable("rg") then
    vim.api.nvim_create_user_command("Rg", function(opts)
        if opts.args == "" then return end
        local results = vim.fn.systemlist("rg --vimgrep " .. opts.args)
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_err_writeln("Rg error: " .. table.concat(results, "\n"))
            return
        end
        if #results == 0 then return end
        vim.fn.setqflist({}, " ", {
            items = vim.fn.getqflist({ lines = results, efm = "%f:%l:%c:%m" }).items,
            title = "Rg: " .. opts.args,
        })
        vim.cmd("copen")
    end, { nargs = "*", complete = "file" })
    vim.keymap.set("n", "<leader>g", ":Rg ", { noremap = true, silent = false })
end
if vim.fn.executable("fd") then
    vim.api.nvim_create_user_command("Fd", function(opts)
        if opts.args == "" then return end
        local results = vim.fn.systemlist("fd " .. opts.args)
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_err_writeln("Fg error: " .. table.concat(results, "\n"))
            return
        end
        if #results == 0 then return end
        local formatted = {}
        for _, line in ipairs(results) do
            formatted[#formatted + 1] = line .. ":1"
        end
        vim.fn.setqflist({}, " ", {
            items = vim.fn.getqflist({ lines = formatted, efm = "%f:%l" }).items,
            title = "Fd: " .. opts.args,
        })
        vim.cmd("copen")
    end, { nargs = "*", complete = "file" })
    vim.keymap.set("n", "<leader>f", ":Fd ", { noremap = true, silent = false })
end

local themes = {
    ashki = function(opt)
        vim.pack.add({ "https://github.com/nlkli/ashki.nvim" })
        require("ashki").setup(opt)
        vim.cmd("colorscheme ashki")
    end,
    gruber = function(opt)
        vim.pack.add({ "https://github.com/blazkowolf/gruber-darker.nvim" })
        require("gruber-darker").setup(opt)
        vim.cmd("colorscheme gruber-darker")
    end,
    vague = function(opt)
        vim.pack.add({ "https://github.com/vague-theme/vague.nvim" })
        require("vague").setup(opt)
        vim.cmd("colorscheme vague")
    end,
    gruvbox = function(opt)
        vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })
        require("gruvbox").setup(opt)
        vim.cmd("colorscheme gruvbox")
    end,
    kanagawa_paper = function(opt)
        vim.pack.add({ "https://github.com/thesimonho/kanagawa-paper.nvim" })
        require("kanagawa-paper").setup(opt)
        vim.cmd("colorscheme kanagawa-paper")
    end,
}

themes.gruber()
-- themes.ashki({ soft = 0 })
-- themes.vague()
-- themes.kanagawa_paper()

local treesitter_ensure_installed = {
    "c",
    "go",
    "lua",
    "vim",
    "json",
    "make",
    "bash",
    "rust",
    "query",
    "vimdoc",
    "python",
    "markdown",
    "javascript",
    "markdown_inline",
}

local lspservers_ensure_installed = {
    "lua_ls",
    "html",
    "vtsls",
    "pyright",
    "rust_analyzer",
    "gopls",
    "jsonls",
    "clangd",
}

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
            vim.cmd("TSUpdate")
        end
    end
})

if #treesitter_ensure_installed > 0 then
    vim.pack.add({
        { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" }
    })
    require("nvim-treesitter.configs").setup({
        ensure_installed = treesitter_ensure_installed,
        highlight = {
            enable = true,
            disable = function(_, buf)
                local max_filesize = 255 * 1024
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        autotag = { enable = true },
        auto_install = false,
    })
end

if #lspservers_ensure_installed > 0 then
    vim.pack.add({
        "https://github.com/neovim/nvim-lspconfig",
        "https://github.com/mason-org/mason.nvim",
        "https://github.com/mason-org/mason-lspconfig.nvim",
        "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
        "https://github.com/rafamadriz/friendly-snippets",
        "https://github.com/saghen/blink.cmp",
    })

    require("mason").setup()
    require("mason-tool-installer").setup({
        ensure_installed = lspservers_ensure_installed,
    })
    require("mason-lspconfig").setup({
        ensure_installed = lspservers_ensure_installed,
        automatic_enable = true,
    })

    vim.diagnostic.config({
        virtual_text = true,
        virtual_lines = false,
        update_in_insert = false,
    })

    require("blink.cmp").setup({
        keymap = {
            preset = "default",
            ["<C-space>"] = {},
            ["<C-s>"] = { "show", "show_documentation", "hide_documentation" },
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        signature = { enabled = true },
        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
            menu = {
                auto_show = true,
                draw = {
                    treesitter = { "lsp" },
                    columns = {
                        { "kind_icon", "label", "label_description", gap = 1 },
                        { "kind" }
                    },
                },
            },
        },
        fuzzy = { implementation = "lua" },
    })
end

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
