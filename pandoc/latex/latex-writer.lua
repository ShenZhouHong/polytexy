-- This custom pandoc writer is essentially an extension on top of the default
-- vanilla pandoc LaTeX writer. It defines new local filter(s) which modify the
-- behaviour of the regular pandoc LaTeX writer.
-- These filters take as input elements of the pandoc Abstract Syntax Tree (AST)
-- and return modified AST objects.

-- Get script path, so we can load additional files without problems.
-- Anthony Gore CC BY-SA 3.0
-- https://stackoverflow.com/a/23535333
function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "."
 end

-- Load template files. These are template-strings used for substitutions, NOT
-- pandoc templates!
dofile(script_path() .."/latex-strings.lua")

-- Utilities and debug table-printing library
dofile(script_path() .. "../utilities.lua")

-- Default Writer() function. Expected in pandoc 'new-style' (i.e. post 2.17.2).
function Writer (doc, opts)
    
    -- Declare list of filter functions. This is not comprehensive, missing
    -- elements will be written using the default vanilla pandoc LaTeX writer.
    local filter = {

        -- We want our blockquotes to be csquote-style \displayquotes
        BlockQuote = function (element)
            -- Load template file from ./templates.lua
            local template = BlockQuoteTemplate
            
            -- First we convert any existing 'i.e. inline' formatting into LaTeX
            local inline_doc = pandoc.Pandoc(element.content)
            local inline_latex = pandoc.write(inline_doc, 'latex')

            local converted = pandoc.RawInline('latex', string.format(template, inline_latex))
            return converted
        end,


        -- We want to manage footnotes and marginnotes ourselves
        Note = function (element)
            local inlines = pandoc.utils.blocks_to_inlines(element.content)
            local strings = pandoc.utils.stringify(inlines)

            -- print(strings)
            return element
        end,

        -- We will use the LaTeX package minted to have syntax-highlighted
        -- code blocks. We first text to see if a markdown code block 
        -- contains a programming language attribute or not. If not, it
        -- means that the code block is simply monospaced-text, so we pass
        -- it back as a LaTeX verbatim environment. Otherwise, we will use
        -- listing and minted to display and syntax-highlight the code.
        CodeBlock = function (element)
            -- element.attr always returns a userdata containing the following:
            --        .attr.identifier (str)
            --        .attr.classes (pandoc.List)
            --        .attr.attributes (key-value pairs)
            -- Note the element.attr.classes does not return a regular Lua table
            -- but a pandoc.List object, which has its own methods.
            -- In particular, the only way to retrieve an item within the
            -- pandoc.List is to :remove it (i.e. pop). This is what we will do
            -- because the language of the code block will be the first (and 
            -- only) element of the pandoc.List. NOTE: Elements are ONE-indexed!
            local code_lang = element.attr.classes:remove(1)

            -- Check to see it contains a programming language.
            if (code_lang == nil) then
                -- If it doesn't, typeset the contents as a verbatim environment
                local strings = element.text
                local template = VerbatimTemplate

                element = pandoc.RawInline('latex', string.format(template, strings))
            else
                -- If it does, typeset the contents w/ listing & minted for code
                local strings = element.text
                local template = MintedTemplate

                element = pandoc.RawInline('latex', string.format(template, code_lang, strings))
            end

            return element
        end,
    }
    
    -- Write a pandoc document using the above filter, & default LaTeX writer
    return pandoc.write(doc:walk(filter), 'latex', opts)
end