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
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P')
vim.keymap.set("n", "<leader>q", ":x<CR>")
vim.keymap.set("n", "<leader>w", ":update<CR>")
vim.keymap.set("n", "<leader>e", ":edit %:h<CR>")
vim.keymap.set("n", "<leader>E", ":edit .<CR>")
vim.keymap.set("n", "<leader>r", ":edit #<CR>")
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]])
vim.keymap.set("x", "<leader>s", [[y:%s/<C-r>"//g<Left><Left>]])
vim.keymap.set("n", "<leader>u", ":source ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "<leader>o", ":copen<CR>")
vim.keymap.set("n", "<leader>c", ":cclose<CR>")
vim.keymap.set("n", "<leader>t", ":tabnew | terminal<CR>")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format)
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { buffer = true })
    end,
})

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
    nightfox = function(opt)
        vim.pack.add({ "https://github.com/EdenEast/nightfox.nvim" })
        require("nightfox").setup(opt)
        vim.cmd("colorscheme terafox")
    end,

}

-- themes.gruber()

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


-- ====THEMESYNCSTARTBLOCK====

local function themeSyncExe()
    vim.cmd("highlight clear")
    if vim.fn.has("syntax_on") then vim.cmd("syntax reset") end

    local P = {
        black   = { base = "#101010",   bright = "#7e7e7e",   dim = "#0c0c0c" },
        red     = { base = "#f5a191",     bright = "#ff8080",     dim = "#c18478" },
        green   = { base = "#90b99f",   bright = "#99ffe4",   dim = "#6f8f7b" },
        yellow  = { base = "#e6b99d",  bright = "#ffc799",  dim = "#b89476" },
        blue    = { base = "#aca1cf",    bright = "#b9aeda",    dim = "#857da3" },
        magenta = { base = "#e29eca", bright = "#ecaad6", dim = "#b97fa7" },
        cyan    = { base = "#ea83a5",    bright = "#f591b2",    dim = "#b5667f" },
        white   = { base = "#a0a0a0",   bright = "#ffffff",   dim = "#6f6f6f" },
        orange  = { base = "#e6b99d",  bright = "#ffc799",  dim = "#b89476" },
        pink    = { base = "#e29eca",    bright = "#ecaad6",    dim = "#b97fa7" },
        comment = "#6f6f6f",
        status_line = "#0c0c0c",
        bg0     = "#0c0c0c", -- Dark bg (status line and float)
        bg1     = "#101010", -- Default bg
        bg2     = "#141414", -- Lighter bg (colorcolm folds)
        bg3     = "#181818", -- Lighter bg (cursor line)
        bg4     = "#2a2a2a", -- Conceal, border fg
        fg0     = "#d0d0d0", -- Lighter fg
        fg1     = "#ffffff", -- Default fg
        fg2     = "#b0b0b0", -- Darker fg (status line)
        fg3     = "#6f6f6f", -- Darker fg (line numbers, fold colums)
        sel0    = "#1f1f1f", -- Popup bg, visual selection bg
        sel1    = "#2a2a2a", -- Popup sel bg, search bg
        diff = {
            add = "#2a322d",
            delete = "#3e2d2a",
            change = "#2f2d36",
            text = "#51333d",
        }
    }

    local spec = {}
    spec.diag = {
        error = P.red.base,
        warn  = P.yellow.base,
        info  = P.blue.base,
        hint  = P.green.base,
        ok    = P.green.base,
    }
    spec.git = {
        add      = P.green.base,
        removed  = P.red.base,
        changed  = P.yellow.base,
        conflict = P.orange.base,
        ignored  = P.comment,
    }
    local syn = {
        bracket     = P.fg2,           -- Brackets and Punctuation
        builtin0    = P.red.base,      -- Builtin variable
        builtin1    = P.cyan.bright,    -- Builtin type
        builtin2    = P.orange.bright,  -- Builtin const
        builtin3    = P.red.bright,     -- Not used
        comment     = P.comment,       -- Comment
        conditional = P.magenta.bright, -- Conditional and loop
        const       = P.orange.bright,  -- Constants, imports and booleans
        dep         = P.fg3,           -- Deprecated
        field       = P.blue.base,     -- Field
        func        = P.blue.bright,    -- Functions and Titles
        ident       = P.cyan.base,     -- Identifiers
        keyword     = P.magenta.base,  -- Keywords
        number      = P.orange.base,   -- Numbers
        operator    = P.fg2,           -- Operators
        preproc     = P.pink.bright,    -- PreProc
        regex       = P.yellow.bright,  -- Regex
        statement   = P.magenta.base,  -- Statements
        string      = P.green.base,    -- Strings
        type        = P.yellow.base,   -- Types
        variable    = "#ffffff",    -- Variables
    }
    local trans = false
    local inactive = false
    local inv = {
        match_paren = false,
        visual = false,
        search = false,
    }
    local stl = {
        comments = "NONE",
        conditionals = "NONE",
        constants = "NONE",
        functions = "NONE",
        keywords = "NONE",
        numbers = "NONE",
        operators = "NONE",
        preprocs = "NONE",
        strings = "NONE",
        types = "NONE",
        variables = "NONE",
    }

    for group, opts in pairs({
        ColorColumn  = { bg = P.bg2 },                                                                       -- used for the columns set with 'colorcolumn'
        Conceal      = { fg = P.bg4 },                                                                       -- placeholder characters substituted for concealed text (see 'conceallevel')
        Cursor       = { fg = P.bg1, bg = P.fg1 },                                                           -- character under the cursor
        lCursor      = { link = "Cursor" },                                                                  -- the character under the cursor when |language-mapping| is used (see 'guicursor')
        CursorIM     = { link = "Cursor" },                                                                  -- like Cursor, but used when in IME mode |CursorIM|
        CursorColumn = { link = "CursorLine" },                                                              -- Screen-column at the cursor, when 'cursorcolumn' is set.
        CursorLine   = { bg = P.bg3 },                                                                       -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
        Directory    = { fg = syn.func },                                                            -- directory names (and other special names in listings)
        DiffAdd      = { bg = P.diff.add },                                                               -- diff mode: Added line |diff.txt|
        DiffChange   = { bg = P.diff.change },                                                            -- diff mode: Changed line |diff.txt|
        DiffDelete   = { bg = P.diff.delete },                                                            -- diff mode: Deleted line |diff.txt|
        DiffText     = { bg = P.diff.text },                                                              -- diff mode: Changed text within a changed line |diff.txt|
        EndOfBuffer  = { fg = P.bg1 },                                                                       -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
        ErrorMsg     = { fg = spec.diag.error },                                                             -- error messages on the command line
        WinSeparator = { fg = P.bg0 },                                                                       -- the column separating vertically split windows
        VertSplit    = { link = "WinSeparator" },                                                            -- the column separating vertically split windows
        Folded       = { fg = P.fg3, bg = P.bg2 },                                                           -- line used for closed folds
        FoldColumn   = { fg = P.fg3 },                                                                       -- 'foldcolumn'
        SignColumn   = { fg = P.fg3 },                                                                       -- column where |signs| are displayed
        SignColumnSB = { link = "SignColumn" },                                                              -- column where |signs| are displayed
        Substitute   = { fg = P.bg1, bg = spec.diag.error },                                                 -- |:substitute| replacement text highlighting
        LineNr       = { fg = P.fg3 },                                                                       -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
        CursorLineNr = { fg = spec.diag.warn, style = "bold" },                                              -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
        MatchParen   = { fg = spec.diag.warn, style = inv.match_paren and "reverse,bold" or "bold" },        -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
        ModeMsg      = { fg = spec.diag.warn, style = "bold" },                                              -- 'showmode' message (e.g., "-- INSERT -- ")
        MoreMsg      = { fg = spec.diag.info, style = "bold" },                                              -- |more-prompt|
        NonText      = { fg = P.bg4 },                                                                       -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
        Normal       = { fg = P.fg1, bg = trans and "NONE" or P.bg1 },                                       -- normal text
        NormalNC     = { fg = P.fg1, bg = (inactive and P.bg0) or (trans and "NONE") or P.bg1 },             -- normal text in non-current windows
        NormalFloat  = { fg = P.fg1, bg = P.bg0 },                                                           -- Normal text in floating windows.
        FloatBorder  = { fg = P.fg3 },                                                                       -- TODO
        Pmenu        = { fg = P.fg1, bg = P.sel0 },                                                          -- Popup menu: normal item.
        PmenuSel     = { bg = P.sel1 },                                                                      -- Popup menu: selected item.
        PmenuSbar    = { link = "Pmenu" },                                                                   -- Popup menu: scrollbar.
        PmenuThumb   = { bg = P.sel1 },                                                                      -- Popup menu: Thumb of the scrollbar.
        Question     = { link = "MoreMsg" },                                                                 -- |hit-enter| prompt and yes/no questions
        QuickFixLine = { link = "CursorLine" },                                                              -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
        Search       = inv.search and { style = "reverse" } or { fg = P.fg1, bg = P.sel1 },                  -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
        IncSearch    = inv.search and { style = "reverse" } or { fg = P.bg1, bg = spec.diag.hint },          -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
        CurSearch    = { link = "IncSearch" },                                                               -- Search result under cursor (available since neovim >0.7.0 (https://github.com/neovim/neovim/commit/b16afe4d556af7c3e86b311cfffd1c68a5eed71f)).
        SpecialKey   = { link = "NonText" },                                                                 -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
        SpellBad     = { sp = spec.diag.error, style = "undercurl" },                                        -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
        SpellCap     = { sp = spec.diag.warn, style = "undercurl" },                                         -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
        SpellLocal   = { sp = spec.diag.info, style = "undercurl" },                                         -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
        SpellRare    = { sp = spec.diag.info, style = "undercurl" },                                         -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
        StatusLine   = { fg = P.fg2, bg = P.status_line },                                                           -- status line of current window
        StatusLineNC = { fg = P.fg3, bg = P.status_line },                                                           -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
        TabLine      = { fg = P.fg2, bg = P.bg2 },                                                           -- tab pages line, not active tab page label
        TabLineFill  = { bg = P.bg0 },                                                                       -- tab pages line, where there are no labels
        TabLineSel   = { fg = P.bg1, bg = P.fg3 },                                                           -- tab pages line, active tab page label
        Title        = { fg = syn.func, style = "bold" },                                            -- titles for output from ":set all", ":autocmd" etc.
        Visual       = inv.visual and { style = "reverse" } or { bg = P.sel0 },                              -- Visual mode selection
        VisualNOS    = inv.visual and { style = "reverse" } or { link = "visual" },                          -- Visual mode selection when vim is "Not Owning the Selection".
        WarningMsg   = { fg = spec.diag.warn },                                                              -- warning messages
        Whitespace   = { fg = P.bg3 },                                                                       -- "nbsp", "space", "tab" and "trail" in 'listchars'
        WildMenu     = { link = "Pmenu" },                                                                   -- current match in 'wildmenu' completion
        WinBar       = { fg = P.fg3, bg = trans and "NONE" or P.bg1, style = "bold" },                       -- Window bar of current window.
        WinBarNC     = { fg = P.fg3, bg = trans and "NONE" or inactive and P.bg0 or P.bg1, style = "bold" }, --Window bar of not-current windows.

        Comment        = { fg = syn.comment, style = stl.comments },         -- any comment
        Constant       = { fg = syn.const, style = stl.constants },          -- (preferred) any constant
        String         = { fg = syn.string, style = stl.strings },           -- a string constant: "this is a string"
        Character      = { link = "String" },                                -- a character constant: 'c', '\n'
        Number         = { fg = syn.number, style = stl.numbers },           -- a number constant: 234, 0xff
        Float          = { link = "Number" },                                -- a floating point constant: 2.3e10
        Boolean        = { link = "Number" },                                -- a boolean constant: TRUE, false
        Identifier     = { fg = syn.ident, style = stl.variables },          -- (preferred) any variable name
        Function       = { fg = syn.func, style = stl.functions },           -- function name (also: methods for classes)
        Statement      = { fg = syn.keyword, style = stl.keywords },         -- (preferred) any statement
        Conditional    = { fg = syn.conditional, style = stl.conditionals }, -- if, then, else, endif, switch, etc.
        Repeat         = { link = "Conditional" },                           -- for, do, while, etc.
        Label          = { link = "Conditional" },                           -- case, default, etc.
        Operator       = { fg = syn.operator, style = stl.operators },       -- "sizeof", "+", "*", etc.
        Keyword        = { fg = syn.keyword, style = stl.keywords },         -- any other keyword
        Exception      = { link = "Keyword" },                               -- try, catch, throw
        PreProc        = { fg = syn.preproc, style = stl.preprocs },         -- (preferred) generic Preprocessor
        Include        = { link = "PreProc" },                               -- preprocessor #include
        Define         = { link = "PreProc" },                               -- preprocessor #define
        Macro          = { link = "PreProc" },                               -- same as Define
        PreCondit      = { link = "PreProc" },                               -- preprocessor #if, #else, #endif, etc.
        Type           = { fg = syn.type, style = stl.types },               -- (preferred) int, long, char, etc.
        StorageClass   = { link = "Type" },                                  -- static, register, volatile, etc.
        Structure      = { link = "Type" },                                  -- struct, union, enum, etc.
        Typedef        = { link = "Type" },                                  -- A typedef
        Special        = { fg = syn.func },                                  -- (preferred) any special symbol
        SpecialChar    = { link = "Special" },                               -- special character in a constant
        Tag            = { link = "Special" },                               -- you can use CTRL-] on this
        Delimiter      = { link = "Special" },                               -- character that needs attention
        SpecialComment = { link = "Special" },                               -- special things inside a comment
        Debug          = { link = "Special" },                               -- debugging statements
        Underlined     = { style = "underline" },                            -- (preferred) text that stands out, HTML links
        Bold           = { style = "bold" },
        Italic         = { style = "italic" },
        Error          = { fg = spec.diag.error },            -- (preferred) any erroneous construct
        Todo           = { fg = P.bg1, bg = spec.diag.info }, -- (preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX
        qfLineNr       = { link = "lineNr" },
        qfFileName     = { link = "Directory" },
        diffAdded      = { fg = spec.git.add },         -- Added lines ("^+.*" | "^>.*")
        diffRemoved    = { fg = spec.git.removed },     -- Removed lines ("^-.*" | "^<.*")
        diffChanged    = { fg = spec.git.changed },     -- Changed lines ("^! .*")
        diffOldFile    = { fg = spec.diag.warn },       -- Old file that is being diff against
        diffNewFile    = { fg = spec.diag.hint },       -- New file that is being compared to the old file
        diffFile       = { fg = spec.diag.info },       -- The filename of the diff ("diff --git a/readme.md b/readme.md")
        diffLine       = { fg = syn.builtin2 }, -- Line information ("@@ -169,6 +169,9 @@")
        diffIndexLine  = { fg = syn.preproc },  -- Index line of diff ("index bf3763d..94f0f62 100644")

        DiagnosticError          = { fg = spec.diag.error },
        DiagnosticWarn           = { fg = spec.diag.warn },
        DiagnosticInfo           = { fg = spec.diag.info },
        DiagnosticHint           = { fg = spec.diag.hint },
        DiagnosticOk             = { fg = spec.diag.ok },
        DiagnosticSignError      = { link = "DiagnosticError" },
        DiagnosticSignWarn       = { link = "DiagnosticWarn" },
        DiagnosticSignInfo       = { link = "DiagnosticInfo" },
        DiagnosticSignHint       = { link = "DiagnosticHint" },
        DiagnosticSignOk         = { link = "DiagnosticOk" },
        DiagnosticUnderlineError = { style = "undercurl", sp = spec.diag.error },
        DiagnosticUnderlineWarn  = { style = "undercurl", sp = spec.diag.warn },
        DiagnosticUnderlineInfo  = { style = "undercurl", sp = spec.diag.info },
        DiagnosticUnderlineHint  = { style = "undercurl", sp = spec.diag.hint },
        DiagnosticUnderlineOk    = { style = "undercurl", sp = spec.diag.ok },

        ["@variable"] = { fg = syn.variable, style = stl.variables },             -- various variable names
        ["@variable.builtin"] = { fg = syn.builtin0, style = stl.variables },     -- built-in variable names (e.g. `this`)
        ["@variable.parameter"] = { fg = syn.builtin1, style = stl.variables },   -- parameters of a function
        ["@variable.member"] = { fg = syn.field },                                -- object and struct fields
        ["@constant"] = { link = "Constant" },                                    -- constant identifiers
        ["@constant.builtin"] = { fg = syn.builtin2, style = stl.keywords },      -- built-in constant values
        ["@constant.macro"] = { link = "Macro" },                                 -- constants defined by the preprocessor
        ["@module"] = { fg = syn.builtin1 },                                      -- modules or namespaces
        ["@label"] = { link = "Label" },                                          -- GOTO and other labels (e.g. `label:` in C), including heredoc labels
        ["@string"] = { link = "String" },                                        -- string literals
        ["@string.regexp"] = { fg = syn.regex, style = stl.strings },             -- regular expressions
        ["@string.escape"] = { fg = syn.regex, style = "bold" },                  -- escape sequences
        ["@string.special"] = { link = "Special" },                               -- other special strings (e.g. dates)
        ["@string.special.url"] = { fg = syn.const, style = "italic,underline" }, -- URIs (e.g. hyperlinks)
        ["@character"] = { link = "Character" },                                  -- character literals
        ["@character.special"] = { link = "SpecialChar" },                        -- special characters (e.g. wildcards)
        ["@boolean"] = { link = "Boolean" },                                      -- boolean literals
        ["@number"] = { link = "Number" },                                        -- numeric literals
        ["@number.float"] = { link = "Float" },                                   -- floating-point number literals
        ["@type"] = { link = "Type" },                                            -- type or class definitions and annotations
        ["@type.builtin"] = { fg = syn.builtin1, style = stl.types },             -- built-in types
        ["@attribute"] = { link = "Constant" },                                   -- attribute annotations (e.g. Python decorators)
        ["@property"] = { fg = syn.field },                                       -- the key in key/value pairs
        ["@function"] = { link = "Function" },                                    -- function definitions
        ["@function.builtin"] = { fg = syn.builtin0, style = stl.functions },     -- built-in functions
        ["@function.macro"] = { fg = syn.builtin0, style = stl.functions },       -- preprocessor macros
        ["@constructor"] = { fg = syn.ident },                                    -- constructor calls and definitions
        ["@operator"] = { link = "Operator" },                                    -- symbolic operators (e.g. `+` / `*`)
        ["@keyword"] = { link = "Keyword" },                                      -- keywords not fitting into specific categories
        ["@keyword.function"] = { fg = syn.keyword, style = stl.functions },      -- keywords that define a function (e.g. `func` in Go, `def` in Python)
        ["@keyword.operator"] = { fg = syn.operator, style = stl.operators },     -- operators that are English words (e.g. `and` / `or`)
        ["@keyword.import"] = { link = "Include" },                               -- keywords for including modules (e.g. `import` / `from` in Python)
        ["@keyword.storage"] = { link = "StorageClass" },                         -- modifiers that affect storage in memory or life-time
        ["@keyword.repeat"] = { link = "Repeat" },                                -- keywords related to loops (e.g. `for` / `while`)
        ["@keyword.return"] = { fg = syn.builtin0, style = stl.keywords },        -- keywords like `return` and `yield`
        ["@keyword.exception"] = { link = "Exception" },                          -- keywords related to exceptions (e.g. `throw` / `catch`)
        ["@keyword.conditional"] = { link = "Conditional" },                      -- keywords related to conditionals (e.g. `if` / `else`)
        ["@keyword.conditional.ternary"] = { link = "Conditional" },              -- ternary operator (e.g. `?` / `:`)
        ["@punctuation.delimiter"] = { fg = syn.bracket },                        -- delimiters (e.g. `;` / `.` / `,`)
        ["@punctuation.bracket"] = { fg = syn.bracket },                          -- brackets (e.g. `()` / `{}` / `[]`)
        ["@punctuation.special"] = { fg = syn.builtin1, style = stl.operators },  -- special symbols (e.g. `{}` in string interpolation)
        ["@comment"] = { link = "Comment" },                                      -- line and block comments
        ["@comment.error"] = { fg = P.bg1, bg = spec.diag.error },                -- error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED:`)
        ["@comment.warning"] = { fg = P.bg1, bg = spec.diag.warn },               -- warning-type comments (e.g. `WARNING:`, `FIX:`, `HACK:`)
        ["@comment.todo"] = { fg = P.bg1, bg = spec.diag.hint },                  -- todo-type comments (e.g. `TODO:`, `WIP:`, `FIXME:`)
        ["@comment.note"] = { fg = P.bg1, bg = spec.diag.info },                  -- note-type comments (e.g. `NOTE:`, `INFO:`, `XXX`)
        ["@markup"] = { fg = P.fg1 },                                             -- For strings considerated text in a markup language.
        ["@markup.strong"] = { fg = P.red.base, style = "bold" },                 -- bold text
        ["@markup.italic"] = { link = "Italic" },                                 -- italic text
        ["@markup.strikethrough"] = { fg = P.fg1, style = "strikethrough" },      -- struck-through text
        ["@markup.underline"] = { link = "Underline" },                           -- underlined text (only for literal underline markup!)
        ["@markup.heading"] = { link = "Title" },                                 -- headings, titles (including markers)
        ["@markup.quote"] = { fg = P.fg2 },                                       -- block quotes
        ["@markup.math"] = { fg = syn.func },                                     -- math environments (e.g. `$ ... $` in LaTeX)
        ["@markup.link"] = { fg = syn.keyword, style = "bold" },                  -- text references, footnotes, citations, etc.
        ["@markup.link.label"] = { link = "Special" },                            -- link, reference descriptions
        ["@markup.link.url"] = { fg = syn.const, style = "italic,underline" },    -- URL-style links
        ["@markup.raw"] = { fg = syn.ident, style = "italic" },                   -- literal or verbatim text (e.g. inline code)
        ["@markup.raw.block"] = { fg = P.pink.base },                             -- literal or verbatim text as a stand-alone block (use priority 90 for blocks with injections)
        ["@markup.list"] = { fg = syn.builtin1, style = stl.operators },          -- list markers
        ["@markup.list.checked"] = { fg = P.green.base },                         -- checked todo-style list markers
        ["@markup.list.unchecked"] = { fg = P.yellow.base },                      -- unchecked todo-style list markers
        ["@diff.plus"] = { link = "diffAdded" },                                  -- added text (for diff files)
        ["@diff.minus"] = { link = "diffRemoved" },                               -- deleted text (for diff files)
        ["@diff.delta"] = { link = "diffChanged" },                               -- changed text (for diff files)
        ["@tag"] = { fg = syn.keyword },                                          -- XML-style tag names (and similar)
        ["@tag.attribute"] = { fg = syn.func, style = "italic" },                 -- XML-style tag attributes
        ["@tag.delimiter"] = { fg = syn.builtin1 },                               -- XML-style tag delimiters
        ["@label.json"] = { fg = syn.func },                                      -- For labels: label: in C and :label: in Lua.
        ["@constructor.lua"] = { fg = P.fg2 },                                    -- Lua's constructor is { }
        ["@field.rust"] = { fg = P.fg2 },
        ["@variable.member.yaml"] = { fg = syn.func },                            -- For fields.

        ["@lsp.type.boolean"] = { link = "@boolean" },
        ["@lsp.type.builtinType"] = { link = "@type.builtin" },
        ["@lsp.type.comment"] = { link = "@comment" },
        ["@lsp.type.enum"] = { link = "@type" },
        ["@lsp.type.enumMember"] = { link = "@constant" },
        ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
        ["@lsp.type.formatSpecifier"] = { link = "@punctuation.special" },
        ["@lsp.type.interface"] = { fg = syn.builtin3 },
        ["@lsp.type.keyword"] = { link = "@keyword" },
        ["@lsp.type.namespace"] = { link = "@module" },
        ["@lsp.type.number"] = { link = "@number" },
        ["@lsp.type.operator"] = { link = "@operator" },
        ["@lsp.type.parameter"] = { link = "@parameter" },
        ["@lsp.type.property"] = { link = "@property" },
        ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
        ["@lsp.type.typeAlias"] = { link = "@type.definition" },
        ["@lsp.type.unresolvedReference"] = { link = "@error" },
    }) do
        if opts.style and opts.style ~= "NONE" then
            for token in opts.style:gmatch("[^,%s]+") do
                opts[token] = true
            end
        end
        opts.style = nil
        vim.api.nvim_set_hl(0, group, opts)
    end
end
themeSyncExe()

-- ====THEMESYNCENDBLOCK====
