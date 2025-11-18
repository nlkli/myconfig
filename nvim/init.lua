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

vim.g.mapleader = " "
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>P", '"+P')
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>e", ":edit .<CR>")
vim.keymap.set("n", "<leader>r", ":edit #<CR>")
vim.keymap.set("n", "<leader>t", ":tabnew | terminal<CR>")
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format entire buffer" })
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { buffer = true })
    end,
})

local themes = {
    ashki = function(opt)
        vim.pack.add({ "https://github.com/nlkli/ashki.nvim" })
        require("ashki").setup(opt)
        vim.cmd("colorscheme ashki")
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
    black_metal = function(opt)
        vim.pack.add({ "https://github.com/metalelf0/black-metal-theme-neovim" })
        require("black-metal").setup(opt)
        require("black-metal").load()
    end
}

themes.ashki( { colors = { void = "#000000" } } )

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
    "eslint",
    "pyright",
    "rust_analyzer",
    "gopls"
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
        debug = true,
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
