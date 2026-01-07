"""mojo-toml: The first native TOML 1.0 parser for Mojo.

This module provides TOML parsing capabilities without Python dependencies.

Example:
    from toml import parse
    
    var config = parse('''
        [package]
        name = "mojo-toml"
        version = "0.1.0"
    ''')
"""

from .lexer import Lexer, Token, TokenKind, Position
