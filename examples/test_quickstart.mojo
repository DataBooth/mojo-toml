"""Test version of the quickstart example.

This validates that the quickstart example works correctly
and demonstrates testing TOML parsing.
"""

from std.testing import assert_equal, assert_true, TestSuite
from toml import parse


def test_quickstart_app() raises:
    """Test parsing app section from quickstart.toml."""
    var content: String
    with open("examples/quickstart.toml", "r") as f:
        content = f.read()

    var config = parse(content)
    var app = config["app"].as_table()

    assert_equal(app["name"].as_string(), "QuickStart")
    assert_equal(app["version"].as_string(), "1.0.0")
    assert_equal(app["debug"].as_bool(), False)


def test_quickstart_database() raises:
    """Test parsing database section from quickstart.toml."""
    var content: String
    with open("examples/quickstart.toml", "r") as f:
        content = f.read()

    var config = parse(content)
    var db = config["database"].as_table()

    assert_equal(db["host"].as_string(), "localhost")
    assert_equal(db["port"].as_int(), 5432)
    assert_equal(db["timeout"].as_float(), 30.5)


def test_quickstart_features() raises:
    """Test parsing features array from quickstart.toml."""
    var content: String
    with open("examples/quickstart.toml", "r") as f:
        content = f.read()

    var config = parse(content)
    var features = config["features"].as_table()["enabled"].as_array()

    assert_equal(len(features), 3)
    assert_equal(features[0].as_string(), "auth")
    assert_equal(features[1].as_string(), "logging")
    assert_equal(features[2].as_string(), "metrics")


def test_quickstart_complete() raises:
    """Test complete parsing of quickstart.toml."""
    var content: String
    with open("examples/quickstart.toml", "r") as f:
        content = f.read()

    var config = parse(content)

    # Verify all top-level keys exist
    assert_true(config["app"].is_table())
    assert_true(config["database"].is_table())
    assert_true(config["features"].is_table())

    # Verify correct types
    var app = config["app"].as_table()
    assert_true(app["name"].is_string())
    assert_true(app["version"].is_string())
    assert_true(app["debug"].is_bool())

    var db = config["database"].as_table()
    assert_true(db["host"].is_string())
    assert_true(db["port"].is_int())
    assert_true(db["timeout"].is_float())

    var features = config["features"].as_table()["enabled"].copy()
    assert_true(features.is_array())


def main() raises:
    """Run all quickstart tests."""
    var suite = TestSuite()
    suite.test[test_quickstart_app]()
    suite.test[test_quickstart_database]()
    suite.test[test_quickstart_features]()
    suite.test[test_quickstart_complete]()
    suite^.run()
