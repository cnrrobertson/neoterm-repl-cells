local M = {}

-----------------------------------
-- UTILITIES --
-----------------------------------
function M.get_cell_bounds(start_row, marker)
    local buf_len = vim.api.nvim_buf_line_count(0)

    local top_row = nil
    local row_num = start_row
    while(top_row == nil)
    do
      local temp_row = vim.api.nvim_buf_get_lines(0, row_num-1, row_num, false)[1]
      if(string.find(temp_row, marker) ~= nil)
      then
          top_row = row_num+1
      else
        row_num = row_num - 1
        if(row_num <= 1)
        then
            top_row = 1
        end
      end
    end
    local bot_row = nil
    if(start_row ~= buf_len)
    then
      row_num = start_row+1
    else
      row_num = start_row
    end
    while(bot_row == nil)
    do
      local temp_row = vim.api.nvim_buf_get_lines(0, row_num-1, row_num, false)[1]
      if(string.find(temp_row, marker) ~= nil)
      then
        bot_row = row_num-1
      else
        row_num = row_num + 1
        if(row_num >= buf_len)
        then
            bot_row = buf_len
        end
      end
    end
    return top_row, bot_row
end

-----------------------------------
-- SENDING CELLS --
-----------------------------------
function M.send_cell_to_repl(marker)
    local start_row = vim.api.nvim_win_get_cursor(0)[1]
    local top_row, bot_row = M.get_cell_bounds(start_row, marker)
    vim.fn["neoterm#repl#line"](top_row, bot_row)
end

function M.send_cell_to_repl_and_jump(marker)
    local start_row = vim.api.nvim_win_get_cursor(0)[1]
    local top_row, bot_row = M.get_cell_bounds(start_row, marker)
    vim.fn["neoterm#repl#line"](top_row, bot_row)
    local buf_len = vim.api.nvim_buf_line_count(0)
    if(bot_row ~= buf_len)
    then
        vim.api.nvim_win_set_cursor(0, {bot_row+2, 1})
    end
end

-----------------------------------
-- CREATING CELLS --
-----------------------------------
function M.insert_cell_above(marker)
    local start_row = vim.api.nvim_win_get_cursor(0)[1]
    local top_row, _ = M.get_cell_bounds(start_row, marker)
    vim.api.nvim_buf_set_lines(0, top_row-1, top_row-1, false, {"", "", marker})
    vim.api.nvim_win_set_cursor(0, {top_row, 1})
end

function M.insert_cell_below(marker)
    local start_row = vim.api.nvim_win_get_cursor(0)[1]
    local _, bot_row = M.get_cell_bounds(start_row, marker)
    vim.api.nvim_buf_set_lines(0, bot_row, bot_row, false, {"", marker, "", ""})
    vim.api.nvim_win_set_cursor(0, {bot_row+3, 1})
end

-----------------------------------
-- NAVIGATING CELLS --
-----------------------------------
function M.jump_to_cell_below(marker)
    local start_row = vim.api.nvim_win_get_cursor(0)[1]
    local _, bot_row = M.get_cell_bounds(start_row, marker)
    local buf_len = vim.api.nvim_buf_line_count(0)
    if(bot_row ~= buf_len)
    then
        vim.api.nvim_win_set_cursor(0, {bot_row+2, 1})
    end
end

function M.jump_to_cell_above(marker)
    local start_row = vim.api.nvim_win_get_cursor(0)[1]
    local top_row, _ = M.get_cell_bounds(start_row, marker)
    if(top_row ~= 1)
    then
      local new_top_row, _ = M.get_cell_bounds(top_row-2, marker)
      vim.api.nvim_win_set_cursor(0, {new_top_row, 1})
    end
end

return M
