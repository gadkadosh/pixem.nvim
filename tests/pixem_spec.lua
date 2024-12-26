local opts = {
    root_font_size = 16,
    use_rem = true
}

describe("pixem.find_unit", function()
    local find_unit = require("pixem")._find_unit

    it("px", function()
        local unit = find_unit("16px", opts)
        assert.equals(unit, "px")
    end)

    it("em", function()
        local unit = find_unit("1em", opts)
        assert.equals(unit, "em")
    end)

    it("rem", function()
        local unit = find_unit("1rem", opts)
        assert.equals(unit, "rem")
    end)

    it("no unit -> nil", function()
        local unit = find_unit("no unit string", opts)
        assert.equals(unit, nil)
    end)
end)

describe("pixem.convert", function()
    local convert = require("pixem")._convert

    it("px -> rem", function()
        local converted = convert("16px", "px", opts)
        assert.equals(converted, "1rem")
    end)

    it("px -> em", function()
        local converted = convert("16px", "px", vim.tbl_extend("force", opts, { use_rem = false }))
        assert.equals(converted, "1em")
    end)

    it("em -> px", function()
        local converted = convert("1em", "em", opts)
        assert.equals(converted, "16px")
    end)

    it("converts in the middle of a string", function()
        local converted = convert("some string 16px string continues", "px", opts)
        assert.equals(converted, "some string 1rem string continues")
    end)

    it("takes root_font_size into account px -> rem", function()
        local converted = convert("16px", "px", vim.tbl_extend("force", opts, { root_font_size = 10 }))
        assert.equals(converted, "1.6rem")
    end)

    it("takes root_font_size into account rem -> px", function()
        local converted = convert("1rem", "rem", vim.tbl_extend("force", opts, { root_font_size = 10 }))
        assert.equals(converted, "10px")
    end)

    it("multiple occurences rem -> px", function()
        local converted = convert("1rem 2rem 3rem 4rem", "rem", opts)
        assert.equals(converted, "16px 32px 48px 64px")
    end)

    it("multiple occurences px -> rem", function()
        local converted = convert("16px 32px 48px 64px", "px", opts)
        assert.equals(converted, "1rem 2rem 3rem 4rem")
    end)

    it("mixed units", function()
        local converted = convert("16px 2rem 3em", "px", opts)
        assert.equals(converted, "1rem 2rem 3em")
    end)

    it("Inexistant unit", function()
        local converted = convert("16px 12px 24px", "em", opts)
        assert.equals(converted, "16px 12px 24px")
    end)
end)
