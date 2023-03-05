-- Helper function for ordered and unordered lists
function SerializeListItems (list_elements)
  -- We hold the converted (i.e. LaTeX'ed) list elements here
  local list_elements_table = {}

  -- First, we must iterate over every list item in the OrderedList,
  -- and retrieve them into a string that we can then template.
  -- We store these individual list items in list_elements_table table
  -- which we will then serialize and template again into the
  -- list environment
  for index, element in ipairs(list_elements) do
      -- We do a similar conversion to retrieve the string list items
      -- First we convert any existing 'i.e. inline' formatting into LaTeX
      local inline_doc = pandoc.Pandoc(element)
      local inline_latex = pandoc.write(inline_doc, 'latex')
      
      table.insert(list_elements_table, string.format(ListItemTemplate, inline_latex))
  end

  -- Serialize table of list-strings into one large string with \n's
  local list_elements_string = table.concat(list_elements_table, "\n")
  return list_elements_string
end

-- This recursively serializes a table. A variant of this code may be used to 
-- generate JSON from a table.
-- CC BY-SA 3.0  Luiz Menezes
--
-- https://stackoverflow.com/a/41943392
function tprint (tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 

    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "   
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    print(toprint)
end
  