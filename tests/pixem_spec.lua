local get_substitutions = require("pixem")._get_substitutions

local opts = {
    root_font_size = 16,
    use_rem = true
}

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
