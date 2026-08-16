"""Table writer tests for mojo-toml.

Tests the serialisation of tables with [section] headers and nested structures.
"""

from std.testing import assert_equal, assert_true, TestSuite
from toml import TomlValue, to_toml
from std.collections import Dict, List


def test_write_simple_table() raises:
    """Test writing a simple table with [section] header."""
    var config = Dict[String, TomlValue]()

    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("localhost")
    db["port"] = TomlValue(5432)
    db["enabled"] = TomlValue(True)
    db["timeout"] = TomlValue(30.5)

    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Should have [database] header
    assert_true(output.find("[database]") != -1)
    assert_true(output.find("host = \"localhost\"") != -1)
    assert_true(output.find("port = 5432") != -1)
    assert_true(output.find("enabled = true") != -1)


def test_write_multiple_tables() raises:
    """Test writing multiple tables."""
    var config = Dict[String, TomlValue]()

    var app = Dict[String, TomlValue]()
    app["name"] = TomlValue("myapp")
    app["version"] = TomlValue("1.0.0")
    app["debug"] = TomlValue(False)
    app["port"] = TomlValue(8080)

    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("localhost")
    db["user"] = TomlValue("admin")
    db["password"] = TomlValue("secret")
    db["port"] = TomlValue(5432)

    config["app"] = TomlValue(app^)
    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Should have both table headers
    assert_true(output.find("[app]") != -1)
    assert_true(output.find("[database]") != -1)


def test_write_nested_table() raises:
    """Test writing nested tables."""
    var config = Dict[String, TomlValue]()

    var primary = Dict[String, TomlValue]()
    primary["host"] = TomlValue("primary.db")
    primary["port"] = TomlValue(5432)

    var db = Dict[String, TomlValue]()
    db["primary"] = TomlValue(primary^)

    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Should have dotted table header
    assert_true(output.find("[database.primary]") != -1)
    assert_true(output.find("host = \"primary.db\"") != -1)
    assert_true(output.find("port = 5432") != -1)


def test_write_deeply_nested_tables() raises:
    """Test writing deeply nested tables (3 levels)."""
    var config = Dict[String, TomlValue]()

    var replica = Dict[String, TomlValue]()
    replica["host"] = TomlValue("replica.db")
    replica["port"] = TomlValue(5433)

    var primary = Dict[String, TomlValue]()
    primary["host"] = TomlValue("primary.db")
    primary["replica"] = TomlValue(replica^)

    var db = Dict[String, TomlValue]()
    db["primary"] = TomlValue(primary^)

    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Should have nested dotted headers
    assert_true(output.find("[database.primary]") != -1)
    assert_true(output.find("[database.primary.replica]") != -1)


def test_write_table_with_root_keys() raises:
    """Test writing mix of root keys and tables."""
    var config = Dict[String, TomlValue]()

    # Root keys
    config["name"] = TomlValue("myapp")
    config["version"] = TomlValue("1.0.0")

    # Table
    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("localhost")
    db["port"] = TomlValue(5432)
    db["user"] = TomlValue("admin")
    db["password"] = TomlValue("secret")

    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Root keys should come first
    assert_true(output.find("name = \"myapp\"") != -1)
    assert_true(output.find("version = \"1.0.0\"") != -1)

    # Then table
    assert_true(output.find("[database]") != -1)
    assert_true(output.find("host = \"localhost\"") != -1)


def test_write_small_section_table() raises:
    """Test that 2-key tables use section format at root level."""
    var config = Dict[String, TomlValue]()

    var point = Dict[String, TomlValue]()
    point["x"] = TomlValue(10)
    point["y"] = TomlValue(20)

    config["point"] = TomlValue(point^)

    var output = to_toml(config)

    # 2-key table at root level uses section format
    assert_true(output.find("[point]") != -1)
    assert_true(output.find("x = 10") != -1)
    assert_true(output.find("y = 20") != -1)


def test_write_table_with_array() raises:
    """Test writing table containing arrays."""
    var config = Dict[String, TomlValue]()

    var ports = List[TomlValue]()
    ports.append(TomlValue(8080))
    ports.append(TomlValue(8081))
    ports.append(TomlValue(8082))

    var server = Dict[String, TomlValue]()
    server["host"] = TomlValue("0.0.0.0")
    server["ports"] = TomlValue(ports^)
    server["enabled"] = TomlValue(True)
    server["timeout"] = TomlValue(30)

    config["server"] = TomlValue(server^)

    var output = to_toml(config)

    assert_true(output.find("[server]") != -1)
    assert_true(output.find("host = \"0.0.0.0\"") != -1)
    assert_true(output.find("ports = [8080, 8081, 8082]") != -1)


def test_write_mixed_nested_structure() raises:
    """Test complex structure with root keys and nested tables."""
    var config = Dict[String, TomlValue]()

    # Root keys
    config["title"] = TomlValue("My App")
    config["version"] = TomlValue("2.0.0")

    # Simple nested table
    var logging = Dict[String, TomlValue]()
    logging["level"] = TomlValue("info")
    logging["file"] = TomlValue("/var/log/app.log")
    logging["max_size"] = TomlValue(10485760)
    logging["rotate"] = TomlValue(True)

    # Deeper nested table
    var replica = Dict[String, TomlValue]()
    replica["host"] = TomlValue("replica.example.com")
    replica["port"] = TomlValue(5433)

    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("primary.example.com")
    db["port"] = TomlValue(5432)
    db["replica"] = TomlValue(replica^)

    config["logging"] = TomlValue(logging^)
    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Check structure
    assert_true(output.find("title = \"My App\"") != -1)
    assert_true(output.find("[logging]") != -1)
    assert_true(output.find("[database]") != -1)
    assert_true(output.find("[database.replica]") != -1)


def test_write_table_with_nested_section() raises:
    """Test table containing a nested section table."""
    var config = Dict[String, TomlValue]()

    # Nested table
    var credentials = Dict[String, TomlValue]()
    credentials["user"] = TomlValue("admin")
    credentials["pass"] = TomlValue("secret")

    # Parent table
    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("localhost")
    db["port"] = TomlValue(5432)
    db["credentials"] = TomlValue(credentials^)
    db["timeout"] = TomlValue(30)

    config["database"] = TomlValue(db^)

    var output = to_toml(config)

    # Parent should have [database] header
    assert_true(output.find("[database]") != -1)
    assert_true(output.find("host = \"localhost\"") != -1)

    # Nested table should have its own section header
    assert_true(output.find("[database.credentials]") != -1)


def test_write_empty_table() raises:
    """Test writing an empty table."""
    var config = Dict[String, TomlValue]()

    var empty = Dict[String, TomlValue]()
    config["empty"] = TomlValue(empty^)

    var output = to_toml(config)

    # Empty table should be inline
    assert_equal(output, "empty = { }\n")


def test_write_table_hierarchy() raises:
    """Test proper hierarchy in nested tables."""
    var config = Dict[String, TomlValue]()

    # Create: servers.alpha and servers.beta
    var alpha = Dict[String, TomlValue]()
    alpha["ip"] = TomlValue("10.0.0.1")
    alpha["role"] = TomlValue("primary")
    alpha["port"] = TomlValue(8080)
    alpha["enabled"] = TomlValue(True)

    var beta = Dict[String, TomlValue]()
    beta["ip"] = TomlValue("10.0.0.2")
    beta["role"] = TomlValue("secondary")
    beta["port"] = TomlValue(8081)
    beta["enabled"] = TomlValue(False)

    var servers = Dict[String, TomlValue]()
    servers["alpha"] = TomlValue(alpha^)
    servers["beta"] = TomlValue(beta^)

    config["servers"] = TomlValue(servers^)

    var output = to_toml(config)

    # Should have both nested sections
    assert_true(output.find("[servers.alpha]") != -1)
    assert_true(output.find("[servers.beta]") != -1)
    assert_true(output.find("ip = \"10.0.0.1\"") != -1)
    assert_true(output.find("ip = \"10.0.0.2\"") != -1)


def main() raises:
    """Run all table writer tests."""
    var suite = TestSuite()
    suite.test[test_write_simple_table]()
    suite.test[test_write_multiple_tables]()
    suite.test[test_write_nested_table]()
    suite.test[test_write_deeply_nested_tables]()
    suite.test[test_write_table_with_root_keys]()
    suite.test[test_write_small_section_table]()
    suite.test[test_write_table_with_array]()
    suite.test[test_write_mixed_nested_structure]()
    suite.test[test_write_table_with_nested_section]()
    suite.test[test_write_empty_table]()
    suite.test[test_write_table_hierarchy]()
    suite^.run()
