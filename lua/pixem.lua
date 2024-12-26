local M = {}

---@class Config
---@field root_font_size number
---@field use_rem boolean
local config = {
    root_font_size = 16,
    use_rem = true
}

---Convert px and em
---@param str string
---@param opts Config
---@return string | nil
local function convert(str, opts)
    local substitutions = {
        em = function(size) return size * opts.root_font_size .. "px" end,
        rem = function(size) return size * opts.root_font_size .. "px" end,
        px = function(size)
            return size / opts.root_font_size .. (opts.use_rem and "rem" or "em")
        end,
    }

    local found_unit = nil
    for unit, _ in pairs(substitutions) do
        local pattern = "(%d+%.?%d*)" .. unit
        if str:find(pattern) then
            if found_unit then
                print("Pixem: mixed units detected")
                return nil
            else
                found_unit = unit
            end
        end
    end

    local pattern = "(%d+%.?%d*)" .. found_unit
    local converted = str:gsub(pattern, substitutions[found_unit])
    return converted
end

---Execute pixem on the current line
---@param opts? Config
M.run_line = function(opts)
    opts = vim.tbl_extend("keep", opts or {}, config)

    local line = vim.api.nvim_get_current_line()
    local new_line = convert(line, opts)
    if new_line then
        vim.api.nvim_set_current_line(new_line)
    end
end

---Setup pixem
---@param opts Config
M.setup = function(opts)
    opts = opts or {}
    config = vim.tbl_extend("force", config, opts)

    vim.api.nvim_create_user_command("Pixem", function()
        M.run_line()
    end, {})
end

M._convert = convert

return M
