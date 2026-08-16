"""Table header tests for mojo-toml.

Tests TOML table header parsing [section] and nested table structures.
"""

from std.testing import assert_equal, assert_true, TestSuite
from toml import parse


def test_simple_table() raises:
    """Test parsing simple table header."""
    var data = parse("""
[database]
host = "localhost"
port = 5432
""")

    assert_true(data.__contains__("database"))
    assert_true(data["database"].is_table())

    var db = data["database"].as_table()
    assert_equal(db["host"].as_string(), "localhost")
    assert_equal(db["port"].as_int(), 5432)


def test_multiple_tables() raises:
    """Test parsing multiple table headers."""
    var data = parse("""
[server]
host = "0.0.0.0"
port = 8080

[database]
host = "localhost"
port = 5432
""")

    assert_true(data["server"].is_table())
    assert_true(data["database"].is_table())

    var server = data["server"].as_table()
    assert_equal(server["host"].as_string(), "0.0.0.0")
    assert_equal(server["port"].as_int(), 8080)

    var db = data["database"].as_table()
    assert_equal(db["host"].as_string(), "localhost")
    assert_equal(db["port"].as_int(), 5432)


def test_nested_table() raises:
    """Test parsing nested table with dotted header."""
    var data = parse("""
[database.primary]
host = "localhost"
port = 5432
""")

    assert_true(data["database"].is_table())
    var db = data["database"].as_table()

    assert_true(db["primary"].is_table())
    var primary = db["primary"].as_table()

    assert_equal(primary["host"].as_string(), "localhost")
    assert_equal(primary["port"].as_int(), 5432)


def test_root_and_table() raises:
    """Test mixing root-level keys with table headers."""
    var data = parse("""
title = "MyApp"
version = "1.0.0"

[server]
port = 8080
""")

    assert_equal(data["title"].as_string(), "MyApp")
    assert_equal(data["version"].as_string(), "1.0.0")

    assert_true(data["server"].is_table())
    var server = data["server"].as_table()
    assert_equal(server["port"].as_int(), 8080)


def test_deeply_nested_table() raises:
    """Test deeply nested table structure."""
    var data = parse("""
[a.b.c.d]
value = 42
""")

    var a = data["a"].as_table()
    var b = a["b"].as_table()
    var c = b["c"].as_table()
    var d = c["d"].as_table()

    assert_equal(d["value"].as_int(), 42)


def test_table_with_arrays() raises:
    """Test table containing arrays."""
    var data = parse("""
[config]
ports = [8080, 8081, 8082]
hosts = ["localhost", "127.0.0.1"]
""")

    var config = data["config"].as_table()

    var ports = config["ports"].as_array()
    assert_equal(len(ports), 3)
    assert_equal(ports[0].as_int(), 8080)

    var hosts = config["hosts"].as_array()
    assert_equal(len(hosts), 2)
    assert_equal(hosts[0].as_string(), "localhost")


def test_table_with_inline_table() raises:
    """Test table containing inline table."""
    var data = parse("""
[server]
address = {host = "localhost", port = 8080}
timeout = 30
""")

    var server = data["server"].as_table()

    assert_true(server["address"].is_table())
    var address = server["address"].as_table()
    assert_equal(address["host"].as_string(), "localhost")
    assert_equal(address["port"].as_int(), 8080)

    assert_equal(server["timeout"].as_int(), 30)


def test_multiple_nested_tables() raises:
    """Test multiple nested table sections."""
    var data = parse("""
[database.primary]
host = "db1.example.com"
port = 5432

[database.replica]
host = "db2.example.com"
port = 5433
""")

    var db = data["database"].as_table()

    var primary = db["primary"].as_table()
    assert_equal(primary["host"].as_string(), "db1.example.com")
    assert_equal(primary["port"].as_int(), 5432)

    var replica = db["replica"].as_table()
    assert_equal(replica["host"].as_string(), "db2.example.com")
    assert_equal(replica["port"].as_int(), 5433)


def main() raises:
    """Run all table header tests."""
    var suite = TestSuite()
    suite.test[test_simple_table]()
    suite.test[test_multiple_tables]()
    suite.test[test_nested_table]()
    suite.test[test_root_and_table]()
    suite.test[test_deeply_nested_table]()
    suite.test[test_table_with_arrays]()
    suite.test[test_table_with_inline_table]()
    suite.test[test_multiple_nested_tables]()
    suite^.run()
