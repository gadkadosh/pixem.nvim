local M = {}

---@class pixem.Config
---@field root_font_size number Font size for calculating conversions
---@field use_rem boolean Convert px to rem. Set to false to convert px to em

---@alias pixem.Unit "px"|"em"|"rem"
---@alias pixem.Substitutions table<pixem.Unit, function>

---@type pixem.Config
local config = {
    root_font_size = 16,
    use_rem = true
}

---@param opts pixem.Config
---@return pixem.Substitutions
local function get_substitutions(opts)
    return {
        em = function(size) return size * opts.root_font_size .. "px" end,
        rem = function(size) return size * opts.root_font_size .. "px" end,
        px = function(size)
            return size / opts.root_font_size .. (opts.use_rem and "rem" or "em")
        end,
    }
end

---Find a unit to convert in a string, returns nil if mixed units are found
---@param str string
---@param substitutions pixem.Substitutions
---@return pixem.Unit|nil
local function find_unit(str, substitutions)
    local found = nil
    for unit, _ in pairs(substitutions) do
        local pattern = "(%d+%.?%d*)" .. unit
        if str:find(pattern) then
            if not found then
                found = unit
            else
                print(
                    "Pixem: mixed units detected. Place the cursor on the specific part to be converted and try again.")
                return nil
            end
        end
    end
    return found
end

---Convert px and em
---@param str string
---@param unit pixem.Unit
---@param substitutions pixem.Substitutions
---@return string
local function convert(str, unit, substitutions)
    local pattern = "(%d+%.?%d*)" .. unit
    local converted = str:gsub(pattern, substitutions[unit])
    return converted
end

---Execute pixem on the current line, fallback to current word
---@param opts? pixem.Config
---@param lstart number
---@param lend number
M.run_line = function(opts, lstart, lend)
    opts = vim.tbl_extend("keep", opts or {}, config)

    -- Direct execution of the function, rather than through user command
    if not lstart then
        lstart = vim.fn.getpos(".")[2]
    end
    if not lend then
        lend = lstart
    end

    local substitutions = get_substitutions(opts)
    local lines = table.concat(vim.api.nvim_buf_get_lines(0, lstart - 1, lend, false), "\n")
    local unit = find_unit(lines, substitutions) or find_unit(vim.fn.expand("<cexpr>"), substitutions)
    if not unit then
        return
    end
    local converted = convert(lines, unit, substitutions)
    if converted then
        local repl = {}
        for line in converted:gmatch("([^\n]+)") do
            table.insert(repl, line)
        end
        vim.api.nvim_buf_set_lines(0, lstart - 1, lend, false, repl)
    end
end

---Setup pixem
---@param opts? pixem.Config
M.setup = function(opts)
    opts = opts or {}
    config = vim.tbl_extend("force", config, opts)

    vim.api.nvim_create_user_command("Pixem", function(args)
        M.run_line(_, args.line1, args.line2)
    end, { range = true })
end

---For internal testing
M._get_substitutions = get_substitutions
M._find_unit = find_unit
M._convert = convert

return M
