local themes = vim.fn.getcompletion('','color')
local starting_theme = vim.g.colors_name or "default"
local test_on_the_fly = true

local M = {}

local state_filename = '/theme_data'
local theme_selector_group = vim.api.nvim_create_augroup("ThemeSelectorGroup", {clear = true})

local function save_theme(theme_name)
    local file = io.open(vim.fn.stdpath('config') .. state_filename,'w+')
    if file then
        file:write(theme_name)
        file:close()
    end
end

local function unset_theme()
    os.remove(vim.fn.stdpath('config') .. state_filename)
end

local function load_theme()
    local file = io.open(vim.fn.stdpath('config') .. state_filename,'r')
    if file then
        local theme = file:read('l')
        file:close()
        return theme
    end
    return nil
end

function M.create_floating_window()
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 50
    local height = math.min(#themes + 1, 30) -- find list of themes
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

    vim.api.nvim_buf_set_lines(buf,0,1,false,{"Unset global colorscheme"})

    vim.api.nvim_buf_set_lines(buf, 1, -1, false, themes)
    return buf, win
end

local current_line = 0

function M.set_keymaps(buf, win)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>','', {
        callback = function()
            if current_line == 1 then
                unset_theme()
            else
                print(current_line)
                local theme = themes[current_line-1] or "default"
                save_theme(theme)
                starting_theme = theme
            end
            vim.api.nvim_win_close(win, true)
        end,
        noremap = true, silent = true
    })

    vim.api.nvim_buf_set_keymap(buf, 'n', 'q','', {
        callback = function()
            vim.cmd.colorscheme(starting_theme)
            vim.api.nvim_win_close(win, true)
        end,
        noremap = true, silent = true
    })
end

local function on_cursor_moved(_, win)
    local new_line = vim.api.nvim_win_get_cursor(win)[1]
    if new_line ~= current_line then
        current_line = new_line
        if test_on_the_fly and current_line ~= 1 then
            local theme = themes[current_line - 1]
            vim.cmd.colorscheme(theme)
            --print("Selected theme " .. theme)
        end
    end
end

function M.start_tracking(buf,win)
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = theme_selector_group,
        buffer = buf,
        callback = function()
            on_cursor_moved(buf,win)
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = theme_selector_group,
        buffer = buf,
        callback = function()
            vim.cmd.colorscheme(starting_theme)
        end,
    })
end

local function find_index(l, value)
    for k,v in ipairs(l) do
        if v == value then
            return k
        end
    end
    return nil
end

function M.init_window()
    local buf, win = M.create_floating_window()
    starting_theme = vim.g.colors_name or "default"
    local index_of_starting = find_index(themes,starting_theme) or 1
    vim.api.nvim_win_set_cursor(win, {index_of_starting + 1, 0})
    M.start_tracking(buf,win)
    M.set_keymaps(buf,win)
end

function M.setup(totf)
    test_on_the_fly = totf
    local theme = load_theme()
    if theme then
        vim.cmd.colorscheme(theme)
    end
end

return M
