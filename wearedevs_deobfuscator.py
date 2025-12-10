#!/usr/bin/env python3
"""
WeAreDevs Lua Obfuscator v1.0.0 Deobfuscator
Deobfuscates Lua scripts obfuscated by the WeAreDevs obfuscator
"""

import re
import sys
from typing import List, Dict, Tuple

class WeAreDevsDeobfuscator:
    """Deobfuscates WeAreDevs obfuscated Lua code"""
    
    def __init__(self):
        self.string_table = []
        self.decoded_strings = {}
        
    def extract_string_table(self, code: str) -> List[str]:
        """Extract the encoded string table from the beginning of the script"""
        # Look for the pattern: local V={...}
        match = re.search(r'local V=\{(.*?)\n\s*local function', code, re.DOTALL)
        if not match:
            return []
        
        table_content = match.group(1)
        
        # Extract all quoted strings (the octal encoded strings)
        strings = re.findall(r'"([^"]*)"', table_content)
        
        return strings
    
    def decode_octal_string(self, encoded: str) -> str:
        """Convert octal escape sequences to actual characters"""
        result = []
        i = 0
        while i < len(encoded):
            if encoded[i] == '\\' and i + 3 < len(encoded):
                # Try to parse octal
                octal_str = encoded[i+1:i+4]
                if octal_str.isdigit():
                    try:
                        char_code = int(octal_str, 8)
                        result.append(chr(char_code))
                        i += 4
                        continue
                    except (ValueError, OverflowError):
                        pass
            result.append(encoded[i])
            i += 1
        
        return ''.join(result)
    
    def decode_all_strings(self) -> Dict[int, str]:
        """Decode all strings in the string table"""
        decoded = {}
        for idx, encoded_str in enumerate(self.string_table):
            decoded[idx] = self.decode_octal_string(encoded_str)
        return decoded
    
    def analyze_obfuscation_patterns(self, code: str) -> Dict[str, any]:
        """Analyze the obfuscation patterns used"""
        patterns = {
            'string_table_entries': len(self.string_table),
            'uses_single_letter_vars': bool(re.search(r'\b[a-z]\b', code)),
            'uses_mathematical_obfuscation': bool(re.search(r'\(\d+\+\(-\d+\)\)', code)),
            'uses_ternary_obfuscation': bool(re.search(r'\band\s+.+?\s+or\s+', code)),
            'function_depth': len(re.findall(r'function\s*\(', code)),
            'table_lookups': len(re.findall(r'\[.+?\]', code)),
        }
        return patterns
    
    def deobfuscate(self, code: str) -> str:
        """Main deobfuscation method"""
        print("[*] Starting deobfuscation of WeAreDevs obfuscated code...")
        
        # Step 1: Extract string table
        self.string_table = self.extract_string_table(code)
        print(f"[+] Extracted {len(self.string_table)} strings from the string table")
        
        # Step 2: Decode strings
        self.decoded_strings = self.decode_all_strings()
        print(f"[+] Decoded {len(self.decoded_strings)} strings")
        
        # Step 3: Analyze obfuscation
        patterns = self.analyze_obfuscation_patterns(code)
        print("\n[*] Obfuscation Patterns Detected:")
        for pattern, value in patterns.items():
            print(f"    - {pattern}: {value}")
        
        # Step 4: Output some decoded strings as sample
        print("\n[*] Sample Decoded Strings:")
        for idx in range(min(10, len(self.decoded_strings))):
            decoded = self.decoded_strings[idx]
            if decoded and len(decoded) < 100:
                print(f"    [{idx}] {repr(decoded)}")
        
        # Step 5: Generate deobfuscation report
        report = self._generate_report()
        return report
    
    def _generate_report(self) -> str:
        """Generate a deobfuscation report"""
        report = []
        report.append("=" * 70)
        report.append("WeAreDevs Lua Obfuscator v1.0.0 - Deobfuscation Report")
        report.append("=" * 70)
        report.append("")
        
        report.append("OBFUSCATION TECHNIQUES USED:")
        report.append("-" * 70)
        report.append("1. String Encoding")
        report.append("   - All strings stored as octal escape sequences")
        report.append(f"   - Total encoded strings: {len(self.string_table)}")
        report.append("")
        
        report.append("2. Variable Obfuscation")
        report.append("   - Single-letter variable names: a, b, c, d, e, f, etc.")
        report.append("   - Purpose: Obscure meaning of variables")
        report.append("")
        
        report.append("3. Control Flow Obfuscation")
        report.append("   - Mathematical operations: n+(-m) instead of n-m")
        report.append("   - Ternary conditions: condition and X or Y")
        report.append("")
        
        report.append("4. Function Wrapping")
        report.append("   - Multiple levels of nested functions")
        report.append("   - Closures capturing variables from outer scopes")
        report.append("")
        
        report.append("DECODED STRINGS (First 20):")
        report.append("-" * 70)
        for idx in range(min(20, len(self.decoded_strings))):
            decoded = self.decoded_strings[idx]
            if decoded:
                # Truncate long strings
                display = decoded if len(decoded) < 60 else decoded[:57] + "..."
                report.append(f"[{idx:3d}] {repr(display)}")
        
        report.append("")
        report.append("=" * 70)
        
        return "\n".join(report)


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python3 wearedevs_deobfuscator.py <obfuscated_file>")
        sys.exit(1)
    
    obfuscated_file = sys.argv[1]
    
    try:
        with open(obfuscated_file, 'r', encoding='utf-8') as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File '{obfuscated_file}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)
    
    # Create deobfuscator and run
    deobfuscator = WeAreDevsDeobfuscator()
    result = deobfuscator.deobfuscate(code)
    
    print("\n" + result)
    
    # Optionally save the report
    output_file = obfuscated_file.replace('.lua', '_deobfuscated.txt')
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(result)
        print(f"\n[+] Report saved to: {output_file}")
    except Exception as e:
        print(f"[-] Could not save report: {e}")


if __name__ == '__main__':
    main()
