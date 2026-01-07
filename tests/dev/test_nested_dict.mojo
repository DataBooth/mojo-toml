"""Test if we can now build nested Dict structures."""

from collections import Dict

struct TomlValue(Movable, Copyable):
    var data: String
    var is_table: Bool
    var table: Dict[String, TomlValue]
    
    fn __init__(out self, value: String):
        self.data = value
        self.is_table = False
        self.table = Dict[String, TomlValue]()
    
    fn __init__(out self, owned table: Dict[String, TomlValue]):
        self.data = ""
        self.is_table = True
        self.table = table^
    
    fn __copyinit__(out self, existing: Self):
        self.data = existing.data
        self.is_table = existing.is_table
        self.table = Dict[String, TomlValue]()
        if existing.is_table:
            for entry in existing.table.items():
                self.table[entry.key] = entry.value.copy()
    
    fn __moveinit__(out self, owned existing: Self):
        self.data = existing.data^
        self.is_table = existing.is_table
        self.table = existing.table^
    
    fn as_string(self) -> String:
        return self.data
    
    fn as_table(self) -> Dict[String, TomlValue]:
        var result = Dict[String, TomlValue]()
        for entry in self.table.items():
            result[entry.key] = entry.value.copy()
        return result^


fn main() raises:
    print("Testing nested Dict structure building:")
    print()
    
    # Simulate parsing: [database] host = "localhost"
    var root = Dict[String, TomlValue]()
    
    # Create database table
    var db_table = Dict[String, TomlValue]()
    db_table["host"] = TomlValue("localhost")
    db_table["port"] = TomlValue("5432")
    
    # Add to root
    root["database"] = TomlValue(db_table^)
    
    # Create server table
    var srv_table = Dict[String, TomlValue]()
    srv_table["host"] = TomlValue("0.0.0.0")
    srv_table["port"] = TomlValue("8080")
    
    # Add to root
    root["server"] = TomlValue(srv_table^)
    
    # Now test nested access
    print("✅ Created nested structure!")
    print()
    
    # Access via nested tables
    var db = root["database"].as_table()
    print("Database host:", db["host"].as_string())
    print("Database port:", db["port"].as_string())
    
    var srv = root["server"].as_table()
    print("Server host:", srv["host"].as_string())
    print("Server port:", srv["port"].as_string())
    
    print()
    print("✅ Success! Nested table access works!")
