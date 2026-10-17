local stub = require("luassert.stub")
local get_substitutions = require("pixem")._get_substitutions

local opts = {
    root_font_size = 16,
    use_rem = true
}

describe("Pixem command", function()
    local buffer
    local print_stub

    before_each(function()
        buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buffer)
        require("pixem").setup(opts)
        print_stub = stub(_G, "print")
    end)

    after_each(function()
        print_stub:revert()
        vim.api.nvim_buf_delete(buffer, { force = true })
        vim.api.nvim_del_user_command("Pixem")
    end)

    -- These cases replace the manual test_file.css playground.
    for _, case in ipairs({
        { "padding: 1.4; 14", "padding: 1.4; 14" },
        { "font-size: 14px", "font-size: 0.875rem" },
        { "font-size: 14px;", "font-size: 0.875rem;" },
        { "font-size:13px;", "font-size:0.8125rem;" },
        { "font-size:208px;", "font-size:13rem;" },
        { "font-size:21px;", "font-size:1.3125rem;" },
        { "font-size: 5px;", "font-size: 0.3125rem;" },
        { "font-size:0.813em;", "font-size:13.008px;" },
        { "font-size: 0.75em;", "font-size: 12px;" },
        { "font-size: 0.75rem;", "font-size: 12px;" },
        { "font-size: 11px;", "font-size: 0.6875rem;" },
        { "font-size: 10px;", "font-size: 0.625rem;" },
        { "padding: 20em 1.41233em; 14", "padding: 320px 22.59728px; 14" },
        { "padding: 20rem 1.41233rem; 14", "padding: 320px 22.59728px; 14" },
        { "padding: 1.67px; 14", "padding: 0.104375rem; 14" },
        { "padding: 1.375em; 14", "padding: 22px; 14" },
        { "padding:     22px; 14", "padding:     1.375rem; 14" },
        { "padding:22px 22px;", "padding:1.375rem 1.375rem;" },
        { "padding:22px22px 22px 22px;", "padding:1.375rem1.375rem 1.375rem 1.375rem;" },
        { "padding:16px 16px 16px 16px;", "padding:1rem 1rem 1rem 1rem;" },
        { "padding:12px 16px 16px 16px;", "padding:0.75rem 1rem 1rem 1rem;" },
        { "padem: 4;", "padem: 4;" },
    }) do
        it("handles CSS on the current line: " .. case[1], function()
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "body {", "  " .. case[1], "}" })
            vim.api.nvim_win_set_cursor(0, { 2, 0 })

            vim.cmd("Pixem")

            assert.are.same({ "body {", "  " .. case[2], "}" },
                vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
            assert.stub(print_stub).was_not_called()
        end)
    end

    for _, case in ipairs({
        { "padding: 32px 1.41233em; 14", "32px", "padding: 2rem 1.41233em; 14" },
        { "padding: 32px 1.41233em; 14", "1.41233em", "padding: 32px 22.59728px; 14" },
        { "padding:1em 16px 16px 16px;", "16px", "padding:1em 1rem 1rem 1rem;" },
        { "padding:1em 1px 1px 1px;", "1em", "padding:16px 1px 1px 1px;" },
        { "padding: 16px 1rem 1em;", "16px", "padding: 1rem 1rem 1em;" },
        { "padding: 16px 1rem 1em;", "1rem", "padding: 16px 16px 1em;" },
        { "padding: 16px 1rem 1em;", "1em", "padding: 16px 1rem 16px;" },
    }) do
        it("selects " .. case[2] .. " under the cursor in " .. case[1], function()
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { case[1] })
            -- Place the cursor on the unit suffix, including for fractional values.
            local column = assert(case[1]:find(case[2], 1, true)) + #case[2] - 2
            vim.api.nvim_win_set_cursor(0, { 1, column })

            vim.cmd("Pixem")

            assert.are.same({ case[3] }, vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
            assert.stub(print_stub).was_not_called()
        end)
    end

    it("uses the cursor's unit throughout the requested range", function()
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
            "padding: 16px 1rem 1em;",
            "margin: 32px 0.75rem 0.813em;",
            "top: 48px;",
        })
        vim.api.nvim_win_set_cursor(0, { 1, 14 })

        vim.cmd("1,2Pixem")

        assert.are.same({
            "padding: 16px 16px 1em;",
            "margin: 32px 12px 0.813em;",
            "top: 48px;",
        }, vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
        assert.stub(print_stub).was_not_called()
    end)

    it("warns once and leaves mixed units unchanged when the cursor is not on a unit", function()
        local line = "padding: 16px 1rem 1em;"
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { line })
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        vim.cmd("Pixem")

        assert.are.same({ line }, vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
        assert.stub(print_stub).was_called(1)
        assert.stub(print_stub).was_called_with(
            "Pixem: mixed units detected. Place the cursor on the specific part to be converted and try again.")
    end)

    it("converts only the current line when called directly from Lua", function()
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "padding: 16px;", "margin: 32px;" })
        vim.api.nvim_win_set_cursor(0, { 2, 0 })

        require("pixem").run_line()

        assert.are.same({ "padding: 16px;", "margin: 2rem;" },
            vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
        assert.stub(print_stub).was_not_called()
    end)

    it("preserves blank lines and only converts the requested range", function()
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {
            "padding: 48px;",
            "",
            "padding: 16px;",
            "",
            "",
            "   ",
            "margin: 32px;",
            "",
            "",
            "margin: 64px;",
        })

        vim.cmd("2,9Pixem")

        assert.are.same({
            "padding: 48px;",
            "",
            "padding: 1rem;",
            "",
            "",
            "   ",
            "margin: 2rem;",
            "",
            "",
            "margin: 64px;",
        }, vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
        assert.stub(print_stub).was_not_called()
    end)
end)

describe("pixem.find_unit", function()
    local find_unit = require("pixem")._find_unit

    local substitutions = get_substitutions(opts)

    it("px", function()
        local unit = find_unit("16px", substitutions)
        assert.equals(unit, "px")
    end)

    it("em", function()
        local unit = find_unit("1em", substitutions)
        assert.equals(unit, "em")
    end)

    it("rem", function()
        local unit = find_unit("1rem", substitutions)
        assert.equals(unit, "rem")
    end)

    it("no unit -> nil", function()
        local unit = find_unit("no unit string", substitutions)
        assert.equals(unit, nil)
    end)
end)

describe("pixem.convert", function()
    local convert = require("pixem")._convert
    local substitutions

    before_each(function()
        substitutions = get_substitutions(opts)
    end)

    it("px -> rem", function()
        local converted = convert("16px", "px", substitutions)
        assert.equals(converted, "1rem")
    end)

    it("px -> em", function()
        substitutions = get_substitutions(vim.tbl_extend("force", opts, { use_rem = false }))
        local converted = convert("16px", "px", substitutions)
        assert.equals(converted, "1em")
    end)

    it("em -> px", function()
        local converted = convert("1em", "em", substitutions)
        assert.equals(converted, "16px")
    end)

    it("converts in the middle of a string", function()
        local converted = convert("some string 16px string continues", "px", substitutions)
        assert.equals(converted, "some string 1rem string continues")
    end)

    it("takes root_font_size into account px -> rem", function()
        substitutions = get_substitutions(vim.tbl_extend("force", opts, { root_font_size = 10 }))
        local converted = convert("16px", "px", substitutions)
        assert.equals(converted, "1.6rem")
    end)

    it("takes root_font_size into account rem -> px", function()
        substitutions = get_substitutions(vim.tbl_extend("force", opts, { root_font_size = 10 }))
        local converted = convert("1rem", "rem", substitutions)
        assert.equals(converted, "10px")
    end)

    it("multiple occurences rem -> px", function()
        local converted = convert("1rem 2rem 3rem 4rem", "rem", substitutions)
        assert.equals(converted, "16px 32px 48px 64px")
    end)

    it("multiple occurences px -> rem", function()
        local converted = convert("16px 32px 48px 64px", "px", substitutions)
        assert.equals(converted, "1rem 2rem 3rem 4rem")
    end)

    it("mixed units", function()
        local converted = convert("16px 2rem 3em", "px", substitutions)
        assert.equals(converted, "1rem 2rem 3em")
    end)

    it("Inexistant unit", function()
        local converted = convert("16px 12px 24px", "em", substitutions)
        assert.equals(converted, "16px 12px 24px")
    end)

    it("multiple lines", function()
        local str = [[
        padding: 2px 16px;
        margin: 0 10px;
        top: 50px;
            ]]
        local expected = [[
        padding: 0.125rem 1rem;
        margin: 0 0.625rem;
        top: 3.125rem;
            ]]
        local converted = convert(str, "px", substitutions)
        assert.equals(converted, expected)
    end)
end)
