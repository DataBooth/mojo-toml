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


# TOML Value variant type - can hold any TOML value
struct TomlValue(Copyable, Movable):
    """Represents any TOML value type.
    
    TOML supports: strings, integers, floats, booleans, datetimes,
    arrays, and tables (nested dicts).
    """
    
    var value_type: Int  # 0=STRING, 1=INTEGER, 2=FLOAT, 3=BOOLEAN, 4=ARRAY, 5=TABLE
    var string_value: String
    var int_value: Int
    var float_value: Float64
    var bool_value: Bool
    var array_value: List[TomlValue]
    var table_value: Dict[String, TomlValue]
    
    fn __init__(out self, value: String):
        """Create string value."""
        self.value_type = 0  # STRING
        self.string_value = value
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, value: Int):
        """Create integer value."""
        self.value_type = 1  # INTEGER
        self.string_value = ""
        self.int_value = value
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, value: Float64):
        """Create float value."""
        self.value_type = 2  # FLOAT
        self.string_value = ""
        self.int_value = 0
        self.float_value = value
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, value: Bool):
        """Create boolean value."""
        self.value_type = 3  # BOOLEAN
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = value
        self.array_value = List[TomlValue]()
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, var value: List[TomlValue]):
        """Create array value."""
        self.value_type = 4  # ARRAY
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = value^
        self.table_value = Dict[String, TomlValue]()
    
    fn __init__(out self, var value: Dict[String, TomlValue]):
        """Create table (inline table) value."""
        self.value_type = 5  # TABLE
        self.string_value = ""
        self.int_value = 0
        self.float_value = 0.0
        self.bool_value = False
        self.array_value = List[TomlValue]()
        self.table_value = value^
    
    fn is_string(self) -> Bool:
        return self.value_type == 0
    
    fn is_int(self) -> Bool:
        return self.value_type == 1
    
    fn is_float(self) -> Bool:
        return self.value_type == 2
    
    fn is_bool(self) -> Bool:
        return self.value_type == 3
    
    fn is_array(self) -> Bool:
        return self.value_type == 4
    
    fn is_table(self) -> Bool:
        return self.value_type == 5
    
    fn copy(self) -> Self:
        """Create a copy of this value."""
        if self.value_type == 0:  # STRING
            return TomlValue(self.string_value)
        elif self.value_type == 1:  # INTEGER
            return TomlValue(self.int_value)
        elif self.value_type == 2:  # FLOAT
            return TomlValue(self.float_value)
        elif self.value_type == 3:  # BOOLEAN
            return TomlValue(self.bool_value)
        elif self.value_type == 4:  # ARRAY
            var arr_copy = List[TomlValue]()
            for i in range(len(self.array_value)):
                arr_copy.append(self.array_value[i].copy())
            return TomlValue(arr_copy^)
        elif self.value_type == 5:  # TABLE
            var table_copy = self.table_value.copy()
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
        return self.table_value.copy()


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
    var current_table: List[String]  # Track current table path like ["database", "primary"]
    
    fn __init__(out self, var tokens: List[Token]):
        """Initialise parser with token stream.
        
        Args:
            tokens: List of tokens from lexer.
        """
        self.tokens = tokens^
        self.pos = 0
        self.current_table = List[String]()
    
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
        var tok = self.tokens[peek_pos]
        return Token(tok.kind, tok.value, tok.pos)
    
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
            raise Error("Expected token type but got different type")
    
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
                raise Error("Expected key in inline table")
            
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
                    raise Error("Trailing comma not allowed in inline tables")
            elif token.kind == TokenKind.RIGHT_BRACE():
                _ = self.advance()
                break
            else:
                raise Error("Expected comma or closing brace in inline table")
        
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
                raise Error("Expected comma or closing bracket in array")
        
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
            raise Error("Unexpected token in value position")
    
    fn parse_key_value(mut self, mut result: Dict[String, TomlValue]) raises:
        """Parse a key = value pair and add to result dict.
        
        Args:
            result: Dictionary to add the key-value pair to.
        """
        # Parse key (can be dotted: a.b.c)
        var key_parts = List[String]()
        
        # First key part
        var token = self.current()
        if token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
            key_parts.append(token.value)
            _ = self.advance()
        else:
            raise Error("Expected key")
        
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
                        raise Error("Expected key after dot")
                else:
                    break
            except:
                break
        
        # Expect equals sign
        self.expect(TokenKind.EQUALS())
        
        # Parse value
        var value = self.parse_value()
        
        # For simple key (not dotted), just add to result
        if len(key_parts) == 1:
            result[key_parts[0]] = value^
        else:
            # TODO: Handle dotted keys by creating nested dicts
            # For now, just use the last part
            result[key_parts[len(key_parts) - 1]] = value^
    
    fn parse(mut self) raises -> Dict[String, TomlValue]:
        """Parse the entire TOML document.
        
        Returns:
            Dictionary containing all TOML data.
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
            
            # Key-value pair
            elif token.kind == TokenKind.KEY() or token.kind == TokenKind.STRING():
                self.parse_key_value(result)
                self.skip_newlines()
            
            # TODO: Table headers [section]
            # TODO: Array of tables [[array]]
            
            else:
                raise Error("Unexpected token at top level")
        
        return result^


fn parse(content: String) raises -> Dict[String, TomlValue]:
    """Parse TOML content from a string.
    
    This is the main public API for parsing TOML.
    
    Args:
        content: TOML content as a string.
        
    Returns:
        Dictionary containing parsed TOML data.
        
    Example:
        var data = parse('[package]\\nname = "mojo-toml"')
        print(data["name"].as_string())  # Prints: mojo-toml
    """
    var lexer = Lexer(content)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    return parser.parse()
