--[[The MIT License (MIT)

Copyright (c) 2014 Jesse Coyle; alias: "Zilarrezko"

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files Calculator, to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]


--[[Change Log:
  -Factorial
]]

local function calculate(formula, first)

  local value, temp, success, message

  local function factorial(n)
    if n > 0 then
      return n * factorial(n-1)
    else
      return 1
    end
  end

  if formula:find("%a.") then
    if formula:match("%a.") ~= "sq" then
      value = nil
      success = false
      message = "Cannot calculate for variables... yet"
      return value, success, message
    end
  end

  if first or first == nil then
    formula = formula:gsub("%s", "")
  end

  while formula:match("%b()") do
    if formula:match("sq%b()") then
      temp = calculate((formula:match("sq%b()")):sub(4, -2), false)

      if tonumber(temp) < 0 then
        value = nil
        success = false
        message = "Non-Real Answer"
        return value, success, message
      end

      formula = formula:gsub("sq%b()", math.sqrt(tonumber(temp)), 1)
    else
      temp = calculate((formula:match("%b()")):sub(2, -2), false)

      formula = formula:gsub("%b()", temp, 1)
    end
  end

  if formula:find("%!") then
    for word in formula:gmatch("!") do
      local x = formula:match("(%d+%.*%d*)!")



      formula = formula:gsub("%d+%.*%d*!", factorial(tonumber(x)), 1)
    end
  end

  if formula:find("%^") then
    local pow = math.pow
    for word in formula:gmatch("^") do
      local x, y = formula:match("([-]?%d+%.*%d*)^([-]?%d+%.*%d*)")

      formula = formula:gsub("[-]?%d+%.*%d*^[-]?%d+%.*%d*", pow(x, y), 1)
    end
  end

  if formula:find("%*") then
    for word in formula:gmatch("*") do
      local x, y = formula:match("([-]?%d+%.*%d*)*([-]?%d+%.*%d*)")

      formula = formula:gsub("[-]?%d+%.*%d**[-]?%d+%.*%d*", x * y, 1)
    end
  end

  if formula:find("%%") then
    for word in formula:gmatch("%%") do
      local x, y = formula:match("([-]?%d+%.*%d*)%%([-]?%d+%.*%d*)")

      formula = formula:gsub("[-]?%d+%.*%d*%%[-]?%d+%.*%d*", x % y, 1)
    end
  end

  if formula:find("%/") then
    for word in formula:gmatch("/") do
      local x, y = formula:match("([-]?%d+%.*%d*)/([-]?%d+%.*%d*)")
      if x/y == math.huge then
        value = math.huge
        success = false
        message = "Divided by Zero"
        return value, success, message
      end
      formula = formula:gsub("[-]?%d+%.*%d*/[-]?%d+%.*%d*", x / y, 1)
    end
  end

  if formula:find("%-") then
    for word in formula:gmatch("-") do
      local x, y = formula:match("([-]?%d+%.*%d*)-([-]?%d+%.*%d*)")
      if x then
        formula = formula:gsub("[-]?%d+%.*%d*-[-]?%d+%.*%d*", x - y, 1)
      end
    end
  end

  if formula:find("%+") then
    for word in formula:gmatch("+") do
      local x, y = formula:match("([-]?%d+%.*%d*)+([-]?%d+%.*%d*)")

      formula = formula:gsub("[-]?%d+%.*%d*+[-]?%d+%.*%d*", x + y, 1)
    end
  end

  value = formula
  success = true

  return value, success, message
end

return calculate
