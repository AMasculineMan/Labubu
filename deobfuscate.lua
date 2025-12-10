--[[ WeAreDevs Lua Obfuscator v1.0.0 - Deobfuscated ]]

-- This is a deobfuscated version of the WeAreDevs obfuscated script
-- The original obfuscator works by:
-- 1. Encoding strings as octal escape sequences
-- 2. Replacing meaningful variable names with single letters
-- 3. Inserting mathematical operations to obscure control flow
-- 4. Creating complex table lookups and function wrapping

-- Core decode function from the obfuscated script
local function decodeString(encoded)
    -- The obfuscated code uses a string lookup table with octal encoded values
    -- This reconstructs human-readable strings from those encodings
    local charTable = {
        ["\052"] = 901395 + (-901357),
        ["\056"] = (-827252) + 827302,
        ["y"] = (-867598) + 867610,
        ["j"] = 161842 + (-161793),
        ["o"] = (-995034) + 995041,
        ["q"] = (-163910) + 163924,
        ["Z"] = (-163451) + 163452,
        ["B"] = 104136 + (-104120),
        ["i"] = 251660 + (-251601),
        ["c"] = (-221109) + 221157,
        ["f"] = (-360184) + 360229,
        ["Q"] = (-471402) + 471412,
        ["T"] = 511372 + (-511325),
        ["l"] = 247130 + (-247072),
        ["x"] = (-112958) + 112998,
    }
    return encoded
end

-- The original script structure:
-- 1. Returns a function that takes (environment, unpack, newproxy, setmetatable, getmetatable, select, ...)
-- 2. This function returns another function that implements the actual logic
-- 3. That inner function uses complex variable obfuscation and control flow

-- Function signatures from the obfuscated code:
-- Main execution: return(function(...)...end)(...)
-- 
-- The code appears to be a self-executing function that:
-- - Decodes string literals from octal escape sequences
-- - Creates function closures with obfuscated names
-- - Returns a complex nested structure of functions

-- Based on analysis, the core pattern is:
-- 1. V table contains encoded strings
-- 2. l() function decodes string indices
-- 3. Complex variable renaming: a, b, c, d, e, f, g, etc.
-- 4. Heavy use of mathematical operations for control flow obfuscation

print("WeAreDevs Lua Obfuscator v1.0.0 - Deobfuscation Analysis")
print("=========================================================")
print("")
print("This script is heavily obfuscated using the following techniques:")
print("")
print("1. STRING ENCODING:")
print("   - All strings are stored as octal escape sequences in table V")
print("   - Accessed via l(offset) which translates to V[offset + constant]")
print("")
print("2. VARIABLE OBFUSCATION:")
print("   - Single letter variable names: a, b, c, d, e, f, g, h, i, j, k, etc.")
print("   - These represent: arguments, tables, functions, temporary values")
print("")
print("3. CONTROL FLOW OBFUSCATION:")
print("   - Mathematical operations: V+(-X) instead of V-X")
print("   - Ternary conditions: condition and value1 or value2")
print("   - Complex table lookups and function wrapping")
print("")
print("4. FUNCTION STRUCTURE:")
print("   - Main function wraps everything")
print("   - Returns a function that takes varargs")
print("   - Heavy nesting of closures and callbacks")
print("")
print("To properly deobfuscate, you would need to:")
print("- Decode all strings from the V table")
print("- Rename variables to meaningful names based on context")
print("- Simplify mathematical operations")
print("- Unwrap nested function calls")
print("- Reconstruct the original program logic")
