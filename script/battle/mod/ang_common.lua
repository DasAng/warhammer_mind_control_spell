---------------------------------------------------------------------------------------------------------------------------
--- @function Checks whether a string ends with the specified string
--- @str the string to test
--- @ending the pattern to match
--------------------------------------------------------------------------------------------------------------------------- 
function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end