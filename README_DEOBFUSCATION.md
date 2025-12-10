# WeAreDevs Lua Obfuscator v1.0.0 - Deobfuscation Guide

## Overview

This repository contains analysis and tools for deobfuscating Lua scripts obfuscated using the WeAreDevs Obfuscator (v1.0.0, https://wearedevs.net/obfuscator).

## Obfuscation Techniques

The WeAreDevs obfuscator uses multiple layered techniques to obscure Lua code:

### 1. String Encoding via Octal Escape Sequences

**How it works:**
- All string literals are converted to octal escape sequences
- Stored in a large lookup table (`V` table) at the beginning of the script
- Accessed via an index function: `l(offset)` returns `V[offset + (-31636 + 78581)]`

**Example:**
```lua
-- Original
local message = "Hello, World!"

-- Obfuscated
local V = {"\110\145\154\154\157\054\040\127\157\162\154\144\041", ...}
local message = V[l(0)]  -- Gets the string via lookup
```

**Why it's effective:**
- Makes it nearly impossible to grep for string literals
- Requires understanding the offset calculation logic
- Creates many false positives when analyzing binary

### 2. Single-Letter Variable Obfuscation

**How it works:**
- All meaningful variable names replaced with single letters
- Pattern: `a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z`
- Context must be inferred from usage

**Example:**
```lua
-- Original
function processData(input)
    local result = {}
    for index = 1, #input do
        result[index] = input[index] * 2
    end
    return result
end

-- Obfuscated
function l(x)
    local y = {}
    for z = 1, #x do
        y[z] = x[z] * 2
    end
    return y
end
```

### 3. Mathematical Operation Obfuscation

**How it works:**
- Simple arithmetic replaced with more complex expressions
- Subtraction written as: `n + (-m)` instead of `n - m`
- Division obfuscated via exponentiation
- Modulo operations hidden in complex expressions

**Example:**
```lua
-- Original
x = y - z

-- Obfuscated
x = y + (-z)
```

### 4. Control Flow Obfuscation via Ternary Operations

**How it works:**
- Conditions replaced with: `condition and true_value or false_value`
- This works because `and` returns first false value, `or` returns first true value
- Requires careful ordering to work correctly

**Example:**
```lua
-- Original
if x > 5 then
    result = "big"
else
    result = "small"
end

-- Obfuscated
result = (x > 5) and "big" or "small"
```

### 5. Function Wrapping and Closures

**How it works:**
- Original function wrapped in multiple anonymous functions
- Variables captured in closures
- Returns created as IIFE (Immediately Invoked Function Expressions)
- Deep nesting obscures overall structure

**Example:**
```lua
-- Original
function doSomething(x)
    return x * 2
end

-- Obfuscated (simplified)
local F = (function(...)
    return (function(V, l, y, d, ...)
        return (function()
            local a = function(x)
                local b = x
                local c = 2
                return b + (-c + c + c + c)
            end
            return a
        end)()
    end)()
end)
```

## Structure of Obfuscated Code

```lua
return(function(...)
    -- 1. Main function declaration
    -- 2. String lookup table V
    -- 3. Decoding logic and helper functions
    -- 4. Complex variable obfuscation
    -- 5. Control flow with ternary operations
    -- 6. Return statement with IIFE
end)(...)
```

## Deobfuscation Process

### Manual Steps:

1. **Decode String Table**
   ```python
   def decode_octal(s):
       return s.encode('utf-8').decode('unicode_escape')
   ```

2. **Replace String Lookups**
   - Identify all `V[l(n)]` patterns
   - Replace with actual decoded strings
   - Simplify expressions

3. **Rename Variables**
   - Track variable usage patterns
   - Infer purpose from context
   - Replace with meaningful names

4. **Simplify Arithmetic**
   - Convert `x + (-y)` to `x - y`
   - Simplify complex expressions
   - Remove redundant operations

5. **Unwrap Functions**
   - Remove unnecessary nested functions
   - Inline simple closures
   - Simplify control flow

6. **Reconstruct Logic**
   - Convert ternary obfuscation back to if/else
   - Restore original structure
   - Add comments and formatting

### Using Automated Tools:

```bash
python3 wearedevs_deobfuscator.py obfuscated_script.lua
```

This will:
- Extract and decode all strings
- Analyze obfuscation patterns
- Generate a deobfuscation report
- Save results to `obfuscated_script_deobfuscated.txt`

## Indicators of WeAreDevs Obfuscation

Look for these patterns:

1. **Header Comment**
   ```lua
   --[[ v1.0.0 https://wearedevs.net/obfuscator ]]
   ```

2. **Large String Table**
   - Many quoted strings with `\0XX` escape sequences
   - Strings starting with `local V={...}`

3. **Offset Function**
   - Function `l(x)` that does: `return V[x + large_offset]`

4. **Complex Math**
   - Expressions like: `690037 + (-690020)`
   - Unnecessary operations: `x + 0`, `x * 1`

5. **Single-Letter Variables**
   - Pervasive use of `a, b, c, d`, etc.
   - No multi-letter variable names (except built-ins)

6. **Ternary Abuse**
   - Many `and ... or ...` patterns
   - Used even for simple boolean logic

## Tools Mentioned

- **Obfuscator**: WeAreDevs Obfuscator v1.0.0
- **Source**: https://wearedevs.net/obfuscator
- **Language**: Lua

## References

- Lua 5.1+ specification
- String escape sequences in Lua
- Table lookups and indexing
- Closure behavior in Lua
- Obfuscation techniques in interpreted languages

## Disclaimer

This guide is for educational purposes only. Use only on code you own or have permission to analyze. Obfuscation is sometimes used to protect intellectual property, and deobfuscation may violate terms of service or licensing agreements.

## File Descriptions

- `deobfuscate.lua` - Analysis and documentation of obfuscation in Lua
- `wearedevs_deobfuscator.py` - Python tool for automatic deobfuscation
- `README_DEOBFUSCATION.md` - This comprehensive guide
