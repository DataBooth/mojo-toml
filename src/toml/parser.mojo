"""Parser for TOML 1.0 files.

# Why: Purpose of the Parser
The parser is the second stage of TOML parsing. It takes the token stream from
the lexer and builds structured data (nested dictionaries and lists).

Example transformation:
    Tokens: [KEY("name"), EQUALS, STRING("mojo-toml"), EOF]
    Output: {"name": "mojo-toml"}

# What: Responsibilities
- Convert token stream into nested Dict structures
- Handle all TOML value types (strings, numbers, bools, arrays, tables)
- Process dotted keys (a.b.c = value) into nested dicts
- Validate TOML syntax rules (no duplicate keys, etc.)
- Build table hierarchy from [section] headers

# How: Parser Design
The parser uses a recursive descent approach:
1. Consume tokens one by one from the lexer output
2. Build values based on token types
3. Maintain current table context for nested structures
4. Return final Dict[String, Value] structure

This keeps parsing logic separate from tokenisation, making both simpler.
"""

from collections import Dict, List
from .lexer import Token, TokenKind, Lexer


struct KeyValuePair(Movable, Copyable):
    """Simple struct to hold a key-value pair."""
    var key: String
    var value: TomlValue
    
    fn __init__(out self, key: String, var value: TomlValue):
        self.key = key
        self.value = value^
    
    fn copy(self) -> Self:
        return KeyValuePair(self.key, self.value.copy())


# Type constants for TomlValue discrimination
struct TomlValueType:
    """Type discriminator constants for TomlValue."""
    comptime STRING: Int = 0
    comptime INTEGER: Int = 1
    comptime FLOAT: Int = 2
    comptime BOOLEAN: Int = 3
    comptime ARRAY: Int = 4
    comptime TABLE: Int = 5


# TOML Value variant type - can hold any TOML value
struct TomlValue(Copyable, Movable):
    """Represents any TOML value type.
    
    TOML supports: strings, integers, floats, booleans, datetimes,
    arrays, and tables (nested dicts).
    """
    
    var value_type: Int
    var string_value: String
    var int_value: Int
    var float_value: Float64
    var bool_value: Bool
    var array_value: List[TomlValue]
    var table_value: Dict[String, TomlValue]
    
    fn __init__(out self, value: String):
        """Create string value."""
        self.value_type = TomlValueType.STRING
        self.string_value = value
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, value: Int):
        """Create integer value."""
        self.value_type = TomlValueType.INTEGER
        self.string_value = ""
        self.int_value = value
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, value: Float64):
        """Create float value."""
        self.value_type = TomlValueType.FLOAT
        self.string_value = ""
        self.int_value = 0
        self.float_value = value
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, value: Bool):
        """Create boolean value."""
        self.value_type = TomlValueType.BOOLEAN
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = value
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, var value: List[TomlValue]):
        """Create array value."""
        self.value_type = TomlValueType.ARRAY
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = value^
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, var value: Dict[String, TomlValue]):
        """Create table (inline table) value."""
        self.value_type = TomlValueType.TABLE
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = value^
    
    fn is_string(self) -> Bool:
        return self.value_type == TomlValueType.STRING
    
    fn is_int(self) -> Bool:
        return self.value_type == TomlValueType.INTEGER
    
    fn is_float(self) -> Bool:
        return self.value_type == TomlValueType.FLOAT
    
    fn is_bool(self) -> Bool:
        return self.value_type == TomlValueType.BOOLEAN
    
    fn is_array(self) -> Bool:
        return self.value_type == TomlValueType.ARRAY
    
    fn is_table(self) -> Bool:
        return self.value_type == TomlValueType.TABLE
    
    fn copy(self) -> Self:
        """Create a copy of this value."""
        if self.value_type == TomlValueType.STRING:
            return TomlValue(self.string_value)
        elif self.value_type == TomlValueType.INTEGER:
            return TomlValue(self.int_value)
        elif self.value_type == TomlValueType.FLOAT:
            return TomlValue(self.float_value)
        elif self.value_type == TomlValueType.BOOLEAN:
            return TomlValue(self.bool_value)
        elif self.value_type == TomlValueType.ARRAY:
            var arr_copy = List[TomlValue]()
            for i in range(len(self.array_value)):
                arr_copy.append(self.array_value[i].copy())
            return TomlValue(arr_copy^)
        elif self.value_type == TomlValueType.TABLE:
            var table_copy = Dict[String, TomlValue]()
            for entry in self.table_value.items():
                table_copy[entry.key] = entry.value.copy()
            return TomlValue(table_copy^)
        else:
            # Should not reach here
            return TomlValue("")
    
    fn as_string(self) raises -> String:
        """Get string value (raises if not a string)."""
        if not self.is_string():
            raise Error("Value is not a string")
        return self.string_value
    
    fn as_int(self) raises -> Int:
        """Get integer value (raises if not an integer)."""
        if not self.is_int():
            raise Error("Value is not an integer")
        return self.int_value
    
    fn as_float(self) raises -> Float64:
        """Get float value (raises if not a float)."""
        if not self.is_float():
            raise Error("Value is not a float")
        return self.float_value
    
    fn as_bool(self) raises -> Bool:
        """Get boolean value (raises if not a boolean)."""
        if not self.is_bool():
            raise Error("Value is not a boolean")
        return self.bool_value
    
    fn as_array(self) raises -> List[TomlValue]:
        """Get array value (raises if not an array)."""
        if not self.is_array():
            raise Error("Value is not an array")
        # Return a copy since we can't return a reference
        var result = List[TomlValue]()
        for i in range(len(self.array_value)):
            result.append(self.array_value[i].copy())
        return result^
    
    fn as_table(self) raises -> Dict[String, TomlValue]:
        """Get table value (raises if not a table)."""
        if not self.is_table():
            raise Error("Value is not a table")
        # Return a copy of the table
        var result = Dict[String, TomlValue]()
        for entry in self.table_value.items():
            result[entry.key] = entry.value.copy()
        return result^


struct Parser:
    """Parser for TOML token streams.
    
    Converts a list of tokens from the lexer into a structured Dict.
    
    Usage:
        var lexer = Lexer(toml_content)
        var tokens = lexer.tokenize()
        var parser = Parser(tokens)
        var data = parser.parse()
    """
    
    var tokens: List[Token]
    var pos: Int
    var current_table_path: List[String]  # Track current table path for flat key storage
    
    fn __init__(out self, var tokens: List[Token]):
        """Initialise parser with token stream.
        
        Args:
            tokens: List of tokens from lexer.
        """
        self.tokens = tokens^
        self.pos = 0
        self.current_table_path = List[String]()
    
    fn current(self) raises -> Token:
        """Get current token without advancing.
        
        Returns:
            Current token (copied).
        """
        if self.pos >= len(self.tokens):
            raise Error("Unexpected end of input")
        # Must copy since we're returning from borrowed self
        return Token(self.tokens[self.pos].kind, self.tokens[self.pos].value, self.tokens[self.pos].pos)
    
    fn peek(self, offset: Int = 1) raises -> Token:
        """Look ahead at token.
        
        Args:
            offset: Number of tokens to look ahead.
            
        Returns:
            Token at pos + offset (copied).
        """
        var peek_pos = self.pos + offset
        if peek_pos >= len(self.tokens):
            raise Error("Unexpected end of input")
        # Must copy token explicitly
        return Token(self.tokens[peek_pos].kind, self.tokens[peek_pos].value, self.tokens[peek_pos].pos)
    
    fn advance(mut self) raises -> Token:
        """Consume and return current token.
        
        Returns:
            Current token (copied).
        """
        var tok = Token(self.tokens[self.pos].kind, self.tokens[self.pos].value, self.tokens[self.pos].pos)
        self.pos += 1
        return tok^
    
    fn expect(mut self, kind: TokenKind) raises:
        """Expect a specific token type and consume it.
        
        Args:
            kind: Expected token kind.
        """
        var token = self.advance()
        if token.kind != kind:
            raise Error(self.format_error("Expected specific token type but got different type", token.pos))
    
    fn skip_newlines(mut self):
        """Skip any newline tokens."""
        while self.pos < len(self.tokens):
            try:
                var token = self.current()
                if token.kind == TokenKind.NEWLINE():
                    self.pos += 1
                else:
                    break
            except:
                break
    
    fn skip_whitespace_and_newlines(mut self):
        """Skip whitespace and newline tokens (used inside arrays/tables)."""
        while self.pos < len(self.tokens):
            try:
                var token = self.current()
                if token.kind == TokenKind.NEWLINE() or token.kind == TokenKind.COMMENT():
                    self.pos += 1
                else:
                    break
            except:
                break
    
    fn parse_inline_table(mut self) raises -> TomlValue:
        """Parse a TOML inline table {name = "value", port = 8080}.
        
        Returns:
            Table value.
        """
        # Consume opening brace
        self.expect(TokenKind.LEFT_BRACE())
        
        var table = Dict[String, TomlValue]()
        
        # Check for empty table
        var token = self.current()
        if token.kind == TokenKind.RIGHT_BRACE():
            _ = self.advance()
            return TomlValue(table^)
        
        # Parse key-value pairs
        while True:
            # Parse key
            token = self.current()
            if token.kind != TokenKind.KEY() and token.kind != TokenKind.STRING():
                raise Error(self.format_error("Expected key in inline table", token.pos))
            
            var key = token.value
            _ = self.advance()
            
            # Expect equals
            self.expect(TokenKind.EQUALS())
            
            # Parse value
            var value = self.parse_value()
            table[key] = value^
            
            # Check what's next
            token = self.current()
            
            if token.kind == TokenKind.COMMA():
                _ = self.advance()
                # Check for trailing comma (not allowed in inline tables per TOML spec)
                token = self.current()
                if token.kind == TokenKind.RIGHT_BRACE():
                    raise Error(self.format_error("Trailing comma not allowed in inline tables", token.pos))
            elif token.kind == TokenKind.RIGHT_BRACE():
                _ = self.advance()
                break
            else:
                raise Error(self.format_error("Expected comma or closing brace in inline table", token.pos))
        
        return TomlValue(table^)
    
    fn parse_array(mut self) raises -> TomlValue:
        """Parse a TOML array [1, 2, 3].
        
        Returns:
            Array value.
        """
        # Consume opening bracket
        self.expect(TokenKind.LEFT_BRACKET())
        
        var elements = List[TomlValue]()
        
        # Skip whitespace and newlines after opening bracket
        self.skip_whitespace_and_newlines()
        
        # Check for empty array
        var token = self.current()
        if token.kind == TokenKind.RIGHT_BRACKET():
            _ = self.advance()
            return TomlValue(elements^)
        
        # Parse array elements
        while True:
            # Parse value
            var value = self.parse_value()
            elements.append(value^)
            
            # Skip whitespace and newlines
            self.skip_whitespace_and_newlines()
            
            # Check what's next
            token = self.current()
            
            if token.kind == TokenKind.COMMA():
                _ = self.advance()
                # Skip whitespace after comma
                self.skip_whitespace_and_newlines()
                # Check for trailing comma
                token = self.current()
                if token.kind == TokenKind.RIGHT_BRACKET():
                    _ = self.advance()
                    break
            elif token.kind == TokenKind.RIGHT_BRACKET():
                _ = self.advance()
                break
            else:
                raise Error(self.format_error("Expected comma or closing bracket in array", token.pos))
        
        return TomlValue(elements^)
    
    fn parse_value(mut self) raises -> TomlValue:
        """Parse a TOML value (string, number, bool, array, or inline table).
        
        Returns:
            Parsed value.
        """
        var token = self.current()
        
        # Inline table
        if token.kind == TokenKind.LEFT_BRACE():
            return self.parse_inline_table()
        
        # Array
        elif token.kind == TokenKind.LEFT_BRACKET():
            return self.parse_array()
        
        # String
        elif token.kind == TokenKind.STRING():
            _ = self.advance()
            return TomlValue(token.value)
        
        # Integer
        elif token.kind == TokenKind.INTEGER():
            _ = self.advance()
            # Parse string to int
            var value = atol(token.value)
            return TomlValue(value)
        
        # Float
        elif token.kind == TokenKind.FLOAT():
            _ = self.advance()
            # Handle special float values using math constants
            from math import inf, nan
            if token.value == "inf":
                return TomlValue(inf[DType.float64]())
            elif token.value == "-inf":
                return TomlValue(-inf[DType.float64]())
            elif token.value == "nan":
                return TomlValue(nan[DType.float64]())
            else:
                var value = atof(token.value)
                return TomlValue(Float64(value))
        
        # Boolean
        elif token.kind == TokenKind.BOOLEAN():
            _ = self.advance()
            var value = (token.value == "true")
            return TomlValue(value)
        
        else:
            raise Error(self.format_error("Unexpected token in value position", token.pos))
    
    fn format_error(self, message: String, pos: Position) -> String:
        """Format an error message with line and column information.
        
        Args:
            message: The error message.
            pos: Position in the source file.
            
        Returns:
            Formatted error message.
        """
        return message + " at line " + String(pos.line) + ", column " + String(pos.column)
    
    fn parse_table_header(mut self) raises -> List[String]:
        """Parse a table header [section.name] and return the path.
        
        Returns:
            List of strings representing the table path.
        """
        # Consume opening bracket
        self.expect(TokenKind.LEFT_BRACKET())
        
        var path = List[String]()
        
        # Parse first key
        var token = self.current()
        if token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
            path.append(token.value)
            _ = self.advance()
        else:
            raise Error(self.format_error("Expected key in table header", token.pos))
        
        # Parse dotted path (e.g., [a.b.c])
        while self.pos < len(self.tokens):
            token = self.current()
            if token.kind == TokenKind.DOT():
                _ = self.advance()
                token = self.current()
                if token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
                    path.append(token.value)
                    _ = self.advance()
                else:
                    raise Error(self.format_error("Expected key after dot in table header", token.pos))
            elif token.kind == TokenKind.RIGHT_BRACKET():
                _ = self.advance()
                break
            else:
                raise Error(self.format_error("Expected dot or closing bracket in table header", token.pos))
        
        return path^
    
    fn ensure_table_path(mut self, result: Dict[String, TomlValue], path: List[String]) raises -> Dict[String, TomlValue]:
        """Ensure a nested table path exists, creating tables as needed.
        
        Args:
            result: Root dictionary.
            path: List of keys forming the path (e.g., ["database", "primary"]).
            
        Returns:
            New dictionary with path ensured.
        """
        if len(path) == 0:
            # Copy and return
            var copy = Dict[String, TomlValue]()
            for entry in result.items():
                copy[entry.key] = entry.value.copy()
            return copy^
        
        # Copy result
        var new_result = Dict[String, TomlValue]()
        for entry in result.items():
            new_result[entry.key] = entry.value.copy()
        
        # Check/create first level
        var first_key = path[0]
        if not new_result.__contains__(first_key):
            var new_table = Dict[String, TomlValue]()
            new_result[first_key] = TomlValue(new_table^)
        elif not new_result[first_key].is_table():
            raise Error("Cannot redefine key as table - key exists but is not a table: " + first_key)
        
        # For paths longer than 1, recursively ensure nested tables
        if len(path) > 1:
            # Get the current table, modify it, put it back
            var current_table = new_result[first_key].as_table()
            var remaining_path = List[String]()
            for i in range(1, len(path)):
                remaining_path.append(path[i])
            current_table = self.ensure_table_path(current_table^, remaining_path)
            new_result[first_key] = TomlValue(current_table^)
        
        return new_result^
    
    fn merge_tables(self, existing: Dict[String, TomlValue], var new_table: TomlValue, key: String) raises -> Dict[String, TomlValue]:
        """Merge a new table value into existing table, checking for conflicts.
        
        Args:
            existing: Existing table.
            new_table: New table to merge in.
            key: The key being set (for error messages).
            
        Returns:
            Merged table.
        """
        if not new_table.is_table():
            raise Error("Cannot merge non-table value into table for key: " + key)
        
        var result = Dict[String, TomlValue]()
        # Copy existing entries
        for entry in existing.items():
            result[entry.key] = entry.value.copy()
        
        # Merge new entries
        var new_entries = new_table.as_table()
        for entry in new_entries.items():
            if result.__contains__(entry.key):
                # Key exists - check if both are tables for recursive merge
                if result[entry.key].is_table() and entry.value.is_table():
                    # Recursively merge nested tables
                    var merged = self.merge_tables(result[entry.key].as_table(), entry.value.copy(), entry.key)
                    result[entry.key] = TomlValue(merged^)
                else:
                    # Duplicate key error - not both tables
                    raise Error("Duplicate key: " + entry.key)
            else:
                result[entry.key] = entry.value.copy()
        
        return result^
    
    fn set_in_table_path(mut self, result: Dict[String, TomlValue], path: List[String], key: String, var value: TomlValue) raises -> Dict[String, TomlValue]:
        """Set a key-value pair at a specific table path with duplicate key detection.
        
        Args:
            result: Root dictionary.
            path: Path to the target table.
            key: Key to set.
            value: Value to set.
            
        Returns:
            New dictionary with value set.
        """
        # Ensure the path exists first
        var new_result = self.ensure_table_path(result, path)
        
        if len(path) == 0:
            # Set at root level - check for duplicates
            if new_result.__contains__(key):
                # If both are tables, merge them (for dotted keys)
                if new_result[key].is_table() and value.is_table():
                    var merged = self.merge_tables(new_result[key].as_table(), value^, key)
                    new_result[key] = TomlValue(merged^)
                    return new_result^
                else:
                    raise Error("Duplicate key: " + key)
            new_result[key] = value^
            return new_result^
        else:
            # Navigate to target table and set
            var table = new_result[path[0]].as_table()
            if len(path) == 1:
                # Check for duplicates at this level
                if table.__contains__(key):
                    # If both are tables, merge them (for dotted keys)
                    if table[key].is_table() and value.is_table():
                        var merged = self.merge_tables(table[key].as_table(), value^, key)
                        table[key] = TomlValue(merged^)
                    else:
                        raise Error("Duplicate key: " + key)
                else:
                    table[key] = value^
                new_result[path[0]] = TomlValue(table^)
            else:
                # Recurse for deeper paths
                var remaining_path = List[String]()
                for i in range(1, len(path)):
                    remaining_path.append(path[i])
                table = self.set_in_table_path(table^, remaining_path, key, value^)
                new_result[path[0]] = TomlValue(table^)
            return new_result^
    
    fn create_nested_value_from_dotted_key(self, key_parts: List[String], var value: TomlValue) raises -> TomlValue:
        """Convert dotted key into nested table structure.
        
        For example: a.b.c = value becomes {a: {b: {c: value}}}
        
        Args:
            key_parts: List of key components from dotted key.
            value: The final value to set.
            
        Returns:
            TomlValue representing nested table structure.
        """
        if len(key_parts) == 1:
            return value^
        
        # Build from the innermost level outward
        var result = value^
        for i in range(len(key_parts) - 1, 0, -1):
            var table = Dict[String, TomlValue]()
            table[key_parts[i]] = result^
            result = TomlValue(table^)
        
        return result^
    
    fn parse_key_value_pair(mut self) raises -> KeyValuePair:
        """Parse a key = value pair and return the key and value.
        
        Returns:
            KeyValuePair containing the parsed key and value.
        """
        # Parse key (can be dotted: a.b.c)
        var key_parts = List[String]()
        
        # First key part
        var token = self.current()
        if token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
            key_parts.append(token.value)
            _ = self.advance()
        else:
            raise Error(self.format_error("Expected key", token.pos))
        
        # Handle dotted keys (a.b.c)
        while self.pos < len(self.tokens):
            try:
                token = self.current()
                if token.kind == TokenKind.DOT():
                    _ = self.advance()
                    token = self.current()
                    if token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
                        key_parts.append(token.value)
                        _ = self.advance()
                    else:
                        raise Error(self.format_error("Expected key after dot", token.pos))
                else:
                    break
            except:
                break
        
        # Expect equals sign
        self.expect(TokenKind.EQUALS())
        
        # Parse value
        var value = self.parse_value()
        
        # For simple key (not dotted), return it
        if len(key_parts) == 1:
            return KeyValuePair(key_parts[0], value^)
        else:
            # Create nested table structure for dotted keys
            # a.b.c = value becomes: return ("a", {b: {c: value}})
            var nested_value = self.create_nested_value_from_dotted_key(key_parts, value^)
            return KeyValuePair(key_parts[0], nested_value^)
    
    fn parse(mut self) raises -> Dict[String, TomlValue]:
        """Parse the entire TOML document.
        
        Returns:
            Dictionary containing all TOML data with nested table structures.
        """
        var result = Dict[String, TomlValue]()
        
        self.skip_newlines()
        
        while self.pos < len(self.tokens):
            var token = self.current()
            
            # EOF
            if token.kind == TokenKind.EOF():
                break
            
            # Comment (skip)
            elif token.kind == TokenKind.COMMENT():
                _ = self.advance()
                self.skip_newlines()
            
            # Newline (skip)
            elif token.kind == TokenKind.NEWLINE():
                self.skip_newlines()
            
            # Table header [section]
            elif token.kind == TokenKind.LEFT_BRACKET():
                # Check if it's an array of tables [[ ]]
                try:
                    var next_token = self.peek()
                    if next_token.kind == TokenKind.LEFT_BRACKET():
                        # Array of tables [[array]]
                        var token = self.current()
                        raise Error(self.format_error("Array of tables [[...]] not yet supported", token.pos))
                except:
                    pass
                
                # Parse table header and update current path
                self.current_table_path = self.parse_table_header()
                # Copy path to avoid aliasing issues
                var path_copy = List[String]()
                for i in range(len(self.current_table_path)):
                    path_copy.append(self.current_table_path[i])
                # Ensure the table path exists in result
                var updated_result = self.ensure_table_path(result, path_copy)
                result = updated_result^
                self.skip_newlines()
            
            # Key-value pair
            elif token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
                # Parse the key-value pair
                var pair = self.parse_key_value_pair()
                
                # Copy values to avoid partial destruction issues
                var parsed_key = String(pair.key)
                var parsed_value = pair.value.copy()
                
                # Copy path to avoid aliasing issues
                var path_copy = List[String]()
                for i in range(len(self.current_table_path)):
                    path_copy.append(self.current_table_path[i])
                # Set the value at the current table path
                var updated_result = self.set_in_table_path(result, path_copy, parsed_key, parsed_value^)
                result = updated_result^
                
                self.skip_newlines()
            
            else:
                var token = self.current()
                raise Error(self.format_error("Unexpected token at top level", token.pos))
        
        return result^


fn parse(content: String) raises -> Dict[String, TomlValue]:
    """Parse TOML content from a string.
    
    This is the main public API for parsing TOML.
    
    Args:
        content: TOML content as a string.
        
    Returns:
        Dictionary containing parsed TOML data.
        
    Example:
        ```mojo
        var data = parse('[package]\\nname = "mojo-toml"')
        print(data["name"].as_string())  # Prints: mojo-toml
        ```
    """
    var lexer = Lexer(content)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    return parser.parse()
