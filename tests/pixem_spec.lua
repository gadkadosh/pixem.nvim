describe("pixem", function()
    local convert = require("pixem")._convert

    local opts = {
        root_font_size = 16,
        use_rem = true
    }

    it("px -> rem", function()
        local converted = convert("16px", opts)
        assert.equals(converted, "1rem")
    end)

    it("px -> em", function()
        local converted = convert("16px", vim.tbl_extend("force", opts, { use_rem = false }))
        assert.equals(converted, "1em")
    end)

    it("em -> px", function()
        local converted = convert("1em", opts)
        assert.equals(converted, "16px")
    end)

    it("converts in the middle of a string", function()
        local converted = convert("some string 16px string continues", opts)
        assert.equals(converted, "some string 1rem string continues")
    end)

    it("takes root_font_size into account px -> rem", function()
        local converted = convert("16px", vim.tbl_extend("force", opts, { root_font_size = 10 }))
        assert.equals(converted, "1.6rem")
    end)

    it("takes root_font_size into account rem -> px", function()
        local converted = convert("1rem", vim.tbl_extend("force", opts, { root_font_size = 10 }))
        assert.equals(converted, "10px")
    end)

    it("multiple occurences rem -> px", function()
        local converted = convert("1rem 2rem 3rem 4rem", opts)
        assert.equals(converted, "16px 32px 48px 64px")
    end)

    it("multiple occurences px -> rem", function()
        local converted = convert("16px 32px 48px 64px", opts)
        assert.equals(converted, "1rem 2rem 3rem 4rem")
    end)

    it("returns nil for mixed units", function()
        local converted = convert("16px 2rem 3em", opts)
        assert.equals(converted, nil)
    end)
end)
