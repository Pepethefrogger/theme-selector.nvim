local themes = vim.fn.getcompletion('','color')
local starting_theme = vim.g.colors_name
local test_on_the_fly = true

local M = {}

function M.create_floating_window()
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 50
    local height = math.min(#themes, 30) -- find list of themes
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        anchor = 'NW',
        style = 'minimal',
        border = 'rounded',
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, themes)
    return buf, win
end

local current_line = 0

function M.set_keymaps(buf, win)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>','', {
        callback = function()
            vim.g.SET_COLORSCHEME_NAME = themes[current_line]
            vim.api.nvim_win_close(win, true)
        end,
        noremap = true, silent = true
    })

    vim.api.nvim_buf_set_keymap(buf, 'n', 'q','', {
        callback = function()
            vim.cmd("colorscheme " .. starting_theme)
            vim.api.nvim_win_close(win, true)
        end,
        noremap = true, silent = true
    })
end

local function on_cursor_moved(buf, win)
    local new_line = vim.api.nvim_win_get_cursor(win)[1]
    if new_line ~= current_line then
        current_line = new_line
        if test_on_the_fly then
            local theme = themes[current_line]
            vim.cmd("colorscheme " .. theme)
            --print("Selected theme " .. theme)
        end
    end
end

function M.start_tracking(buf,win)
    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        callback = function()
            on_cursor_moved(buf,win)
        end,
    })
end

function M.init_window()
    local buf, win = M.create_floating_window()
    starting_theme = vim.g.colors_name
    M.start_tracking(buf,win)
    M.set_keymaps(buf,win)
end

function M.setup(options)
    test_on_the_fly = options["test_on_the_fly"] or true
    local default_theme = options["default_theme"] or nil
    if default_theme then
        vim.g.SET_COLORSCHEME_NAME = default_theme
    end
    if vim.g.SET_COLORSCHEME_NAME then
        vim.cmd("colorscheme " .. vim.g.SET_COLORSCHEME_NAME)
    end
end

return M
