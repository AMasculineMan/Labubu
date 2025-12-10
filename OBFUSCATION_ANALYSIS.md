# WeAreDevs Obfuscator v1.0.0 - Technical Analysis

## Executive Summary

The provided Lua script is heavily obfuscated using the WeAreDevs Obfuscator (v1.0.0). This document provides a technical breakdown of the obfuscation techniques used and methods to deobfuscate them.

## Obfuscation Techniques Breakdown

### 1. Octal String Encoding

The most prominent obfuscation technique is encoding all string literals as octal escape sequences.

#### Original Code Pattern
```lua
local message = "Hello, World!"
local greeting = "Welcome!"
```

#### Obfuscated Pattern
```lua
local V = {
    "\110\145\154\154\157",  -- "Hello"
    "\054\040\127\157\162",  -- ", Wor"
    "\154\144\041",          -- "ld!"
    "\127\145\154\143\157"   -- "Welco"
    -- ... many more entries
}

local function l(index)
    return V[index + (-31636 + 78581)]  -- Offset by 47045
end

local message = l(0) .. l(1) .. l(2)
local greeting = l(3) .. "me!"
```

#### Decoding Algorithm
```python
def decode_octal_escape(escape_seq):
    # Input: "\110\145\154\154\157"
    # Process: Extract each \NNN sequence
    # Output: "Hello"
    
    import re
    def parse_octal(s):
        return re.sub(
            r'\\(\d{3})',
            lambda m: chr(int(m.group(1), 8)),
            s
        )
```

### 2. Single-Letter Variable Obfuscation

All meaningful variable and function names are replaced with single letters.

#### Mapping Strategy

The obfuscator uses a sequential letter assignment:

```
Variables commonly become:
  V   -> String lookup table
  l   -> Lookup/decode function
  W   -> Another table or function
  y   -> Control flow variable
  d   -> Data container
  e   -> Environment/error handling
  etc.
```

#### Example Transformation

**Original Code:**
```lua
function parseJSON(jsonString)
    local result = {}
    local index = 1
    while index <= #jsonString do
        local char = jsonString:sub(index, index)
        if char == "{" then
            result[index] = "object"
        else
            result[index] = "other"
        end
        index = index + 1
    end
    return result
end
```

**Obfuscated Code:**
```lua
function l(d,e,W,c,p,h,w,E)
    local y,t,o,v,r,a,L,s,I,K,B
    -- ... setup code ...
    while y<#d do
        local x=p(d,y,y)
        if x==W[l(-1000)] then
            a[y]=(something)
        else
            a[y]=(something else)
        end
        y=y+(stuff)
    end
    return a
end
```

### 3. Mathematical Operation Obfuscation

Simple arithmetic is replaced with more complex equivalent expressions.

#### Common Patterns

| Original | Obfuscated | Purpose |
|----------|-----------|---------|
| `x - 5` | `x + (-5)` | Hide subtraction |
| `x / 2` | `x * (1/2)` or `l(exp)` | Obscure division |
| `x % 10` | Complex table lookup | Hide modulo |
| `x == 5` | `x + (-5) == 0` | Change comparison |
| `if x then` | `x and true or false` | Hide conditionals |

#### Examples

```lua
-- Original
local count = total - processed
local doubled = value * 2

-- Obfuscated
local count = total + (-processed)
local doubled = value * (1099216 + (-1099214))  -- = 1, so value * 1? No, more complex
```

### 4. Ternary Condition Obfuscation

Conditional logic is rewritten using `and`/`or` chains instead of `if`/`else`.

#### How it works

In Lua:
- `condition and true_value` returns `true_value` if condition is truthy
- `condition and false` returns `false` if condition is truthy
- `false or fallback_value` returns `fallback_value`
- `true or fallback_value` returns `true`

#### Pattern Exploitation

```lua
-- Original
if x > 5 then
    result = "big"
else
    result = "small"
end

-- Obfuscated (WRONG - demonstrates the issue)
result = (x > 5) and "big" or "small"
-- ^ This fails if "big" is falsy!

-- Obfuscated (CORRECT)
result = (x > 5 and (function() return "big" end)() or "small")
-- OR
result = ((x > 5) and "big") or (not (x > 5) and "small") or "small"
```

### 5. Control Flow Obfuscation

The main function uses a state machine with numeric labels instead of clear program structure.

#### Pattern

```lua
local y = initial_state
while y do
    if y == number1 then
        -- code block 1
        y = next_state
    elseif y == number2 then
        -- code block 2
        y = next_state
    -- ... many more states ...
    end
end
```

This makes it very hard to follow the actual execution flow without executing the code.

### 6. Function Wrapping and Closures

The entire program is wrapped in multiple layers of functions and closures.

#### Structure

```lua
return (function(...)
    -- Layer 1: Main wrapper
    local V = {...}  -- String table
    
    return (function(e, W, c, p, h, w, E, y, t, o, v)
        -- Layer 2: Variable setup
        
        return (function(l)
            -- Layer 3: Actual logic
            
            local result = (function()
                -- Layer 4+: More wrapping
                -- ...actual code...
            end)()
            
            return result
        end)()
    end)({...}, ...)
end)(...)
```

## Practical Deobfuscation Steps

### Step 1: Verify Obfuscator Type

Look for:
```lua
--[[ v1.0.0 https://wearedevs.net/obfuscator ]]
```

### Step 2: Extract String Table

Find the pattern:
```lua
local V={
    "\...",
    "\...",
    ...
}
```

### Step 3: Build String Decoder

Create a function to convert octal sequences:

```python
import re

def decode_strings(table_text):
    strings = []
    for match in re.finditer(r'"([^"]*)"', table_text):
        encoded = match.group(1)
        decoded = encoded.encode('utf-8').decode('unicode_escape')
        strings.append(decoded)
    return strings
```

### Step 4: Identify Lookup Function

Find pattern:
```lua
local function l(l)
    return V[l + (SOME_OFFSET)]
end
```

Extract the offset and calculate: `offset = CONST1 + (-CONST2)`

### Step 5: Replace String Lookups

Replace all `l(n)` calls with actual decoded strings:
```
l(0) -> decoded_strings[0]
l(1) -> decoded_strings[1]
etc.
```

### Step 6: Simplify Arithmetic

Replace patterns:
```
x + (-y) -> x - y
x + (big_expr) -> x + simplified
etc.
```

### Step 7: Unwrap Functions

Remove unnecessary function wrappers and extract core logic.

### Step 8: Rename Variables

Based on usage patterns, rename:
```
a -> firstArg or firstInput
b -> secondArg or buffer
c -> callback or counter
etc.
```

### Step 9: Reconstruct Logic

Convert ternary chains back to if/else statements.

## Example Deobfuscation

### Input (Obfuscated)

```lua
--[[ v1.0.0 https://wearedevs.net/obfuscator ]]
return(function(...)local V={"\110\145\154\154\157"}
local function l(l)return V[l+(-1)]end
local y=function()return l(0)end
return y()end)(...)
```

### Output (Deobfuscated)

```lua
-- Decoded strings:
-- l(0) -> "Hello"

local function getMessage()
    return "Hello"
end

return getMessage()
```

## Defense Against Deobfuscation

The obfuscator uses:

1. **Semantic Obfuscation**: Makes structure hard to understand
2. **String Encoding**: Prevents string literal searches
3. **Control Flow Obfuscation**: Hides program logic
4. **Closure Nesting**: Makes scope analysis difficult
5. **Dynamic Behavior**: Uses runtime lookups that vary

## Tools & Resources

### Manual Analysis
- Text editor with regex support
- Python/Perl for string processing
- Lua interpreter for testing

### Automated Deobfuscation
- `wearedevs_deobfuscator.py` - String extraction
- `advanced_deobfuscator.lua` - Lua-based analyzer
- Custom scripts for specific patterns

### Understanding Lua
- Lua 5.1 Reference Manual
- MetaLua (for AST manipulation)
- Luadec (Lua decompiler)

## Limitations & Considerations

1. **Incomplete Deobfuscation**: Automated tools may miss complex patterns
2. **Control Flow**: State machine logic remains hard to read
3. **Semantic Meaning**: Variable names won't match original intent
4. **Dynamic Evaluation**: Code with `loadstring` or similar cannot be fully deobfuscated statically
5. **Time Complexity**: Full manual deobfuscation is very time-consuming

## Conclusion

The WeAreDevs obfuscator is effective at obscuring Lua code through:
- String encoding
- Variable renaming
- Arithmetic obfuscation
- Control flow hiding
- Function wrapping

Deobfuscation is possible but requires:
- Systematic approach
- Understanding of obfuscation techniques
- Careful variable tracking
- Patience for complex sections

The obfuscated code in the ticket is a complete example of all these techniques combined, making it quite challenging to manually deobfuscate without automated assistance.
