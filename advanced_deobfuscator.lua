#!/usr/bin/env lua
--[[
Advanced WeAreDevs Lua Obfuscator Deobfuscator
This script can analyze and help deobfuscate WeAreDevs obfuscated Lua code
]]

local function hexdump(str, limit)
    limit = limit or 256
    local result = {}
    for i = 1, math.min(#str, limit) do
        table.insert(result, string.format("%02X", string.byte(str, i)))
    end
    return table.concat(result, " ")
end

local function octalToChar(oct_str)
    local num = tonumber(oct_str, 8)
    if num and num >= 0 and num <= 255 then
        return string.char(num)
    end
    return nil
end

local function decodeOctalString(encoded)
    local result = {}
    local i = 1
    
    while i <= #encoded do
        if encoded:sub(i, i) == '\\' and i + 3 <= #encoded then
            local octal = encoded:sub(i+1, i+3)
            if octal:match("^%d%d%d$") then
                local char = octalToChar(octal)
                if char then
                    table.insert(result, char)
                    i = i + 4
                    goto continue
                end
            end
        end
        
        table.insert(result, encoded:sub(i, i))
        i = i + 1
        
        ::continue::
    end
    
    return table.concat(result)
end

local function analyzeObfuscatedFile(filename)
    local file = io.open(filename, "r")
    if not file then
        print(string.format("Error: Could not open file '%s'", filename))
        return false
    end
    
    local content = file:read("*a")
    file:close()
    
    print("=" .. string.rep("=", 68) .. "=")
    print("WeAreDevs Lua Obfuscator Analyzer")
    print("=" .. string.rep("=", 68) .. "=")
    print()
    
    -- Check for obfuscator signature
    if content:match("v1%.0%.0 https://wearedevs%.net/obfuscator") then
        print("[+] Confirmed: WeAreDevs Obfuscator v1.0.0")
    else
        print("[-] Warning: Could not find WeAreDevs signature")
    end
    print()
    
    -- Extract and count string table entries
    local stringTableMatch = content:match("local V={(.-)local function")
    if stringTableMatch then
        local stringCount = select(2, stringTableMatch:gsub('"[^"]*"', ''))
        print(string.format("[+] Found string table with approximately %d entries", stringCount))
        
        -- Try to extract first few strings
        local strings = {}
        for str in stringTableMatch:gmatch('"([^"]*)"') do
            table.insert(strings, str)
            if #strings >= 5 then break end
        end
        
        print()
        print("[*] Sample encoded strings (first 5):")
        for idx, str in ipairs(strings) do
            local decoded = decodeOctalString(str)
            local hexview = hexdump(decoded, 32)
            print(string.format("    [%d] Encoded: %d bytes", idx, #str))
            print(string.format("        Decoded: %s", repr(decoded)))
            if #decoded <= 40 then
                print(string.format("        Hex: %s", hexview))
            end
        end
    else
        print("[-] Could not find string table")
    end
    
    print()
    
    -- Analyze variable naming
    local singleLetterCount = select(2, content:gsub("%b[]", ""):gsub("local [a-z]", "local X"))
    print(string.format("[*] Estimated single-letter variables: %d", singleLetterCount))
    
    -- Check for obfuscation patterns
    print()
    print("[*] Obfuscation Patterns Detected:")
    
    if content:match("([%d]+)%s*%+%s*%-") then
        print("    [x] Mathematical obfuscation (a + (-b))")
    end
    
    if content:match("and%s+.+%s+or%s+") then
        print("    [x] Ternary obfuscation (x and y or z)")
    end
    
    if content:match("local l%s*=%s*function") or content:match("local function l") then
        print("    [x] String lookup function found")
    end
    
    if content:match("getfenv") then
        print("    [x] Environment access (getfenv)")
    end
    
    if content:match("setmetatable") then
        print("    [x] Metatable manipulation")
    end
    
    if content:match("function%(V,") then
        print("    [x] Complex function wrapping")
    end
    
    print()
    print("[*] File Statistics:")
    print(string.format("    - Total size: %d bytes", #content))
    print(string.format("    - Line count: %d", select(2, content:gsub("\n", ""))))
    print(string.format("    - Escaped sequences: %d", select(2, content:gsub("\\%d%d%d", ""))))
    
    print()
    return true
end

local function repr(str)
    -- Simple representation function
    if type(str) ~= "string" then
        return tostring(str)
    end
    
    local result = {}
    for i = 1, #str do
        local byte = string.byte(str, i)
        if byte >= 32 and byte <= 126 and byte ~= 34 and byte ~= 92 then
            table.insert(result, string.char(byte))
        else
            table.insert(result, string.format("\\%03o", byte))
        end
    end
    
    return '"' .. table.concat(result) .. '"'
end

-- Main entry point
if arg[1] then
    analyzeObfuscatedFile(arg[1])
else
    print("Usage: lua advanced_deobfuscator.lua <obfuscated_file>")
    print()
    print("This tool analyzes WeAreDevs obfuscated Lua scripts and:")
    print("  - Verifies obfuscator type and version")
    print("  - Extracts and decodes sample strings")
    print("  - Analyzes variable obfuscation patterns")
    print("  - Detects common obfuscation techniques")
    print("  - Provides file statistics")
end
