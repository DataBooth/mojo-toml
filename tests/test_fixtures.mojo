"""Tests for fixture TOML files.

These tests validate that the parser can handle real-world configuration files
across various domains: apps, builds, ML, APIs, and games.
"""

from toml import parse
from testing import assert_equal, assert_true, assert_false, TestSuite


fn read_fixture(filename: String) raises -> String:
    """Read a fixture file from the fixtures directory."""
    var path = "fixtures/" + filename

    with open(path, "r") as f:
        return f.read()


fn test_app_config() raises:
    """Test parsing a typical application configuration file."""
    var content = read_fixture("app_config.toml")
    var config = parse(content)

    # Application metadata
    assert_equal(config["app_name"].as_string(), "DataProcessor")
    assert_equal(config["version"].as_string(), "2.1.0")
    assert_equal(config["author"].as_string(), "DataBooth")
    assert_equal(config["license"].as_string(), "MIT")

    # Server configuration
    assert_equal(config["host"].as_string(), "0.0.0.0")
    assert_equal(config["port"].as_int(), 8080)
    assert_false(config["debug"].as_bool())
    assert_equal(config["log_level"].as_string(), "INFO")

    # Database settings
    assert_equal(config["db_host"].as_string(), "localhost")
    assert_equal(config["db_port"].as_int(), 5432)
    assert_equal(config["db_name"].as_string(), "analytics")
    assert_equal(config["db_timeout"].as_float(), 30.0)

    # Feature flags
    assert_true(config["enable_cache"].as_bool())
    assert_true(config["enable_metrics"].as_bool())
    assert_false(config["enable_profiling"].as_bool())

    # Performance tuning
    assert_equal(config["max_connections"].as_int(), 100)
    assert_equal(config["worker_threads"].as_int(), 4)
    assert_equal(config["request_timeout"].as_float(), 60.0)
    assert_equal(config["cache_size"].as_int(), 1024)


fn test_build_config() raises:
    """Test parsing a build configuration file."""
    var content = read_fixture("build_config.toml")
    var config = parse(content)

    # Basic metadata
    assert_equal(config["name"].as_string(), "mojo-lib")
    assert_equal(config["version"].as_string(), "0.1.0")
    assert_equal(config["edition"].as_string(), "2024")
    assert_equal(config["authors"].as_string(), "DataBooth Team")

    # Compilation settings
    assert_equal(config["optimization_level"].as_int(), 3)
    assert_false(config["debug_symbols"].as_bool())
    assert_equal(config["target"].as_string(), "native")
    assert_true(config["parallel_build"].as_bool())

    # Linting configuration
    assert_equal(config["max_line_length"].as_int(), 100)
    assert_false(config["allow_warnings"].as_bool())
    assert_true(config["strict_mode"].as_bool())

    # Test configuration
    assert_equal(config["test_threads"].as_int(), 8)
    assert_equal(config["test_timeout"].as_float(), 300.0)
    assert_equal(config["coverage_threshold"].as_float(), 80.0)


fn test_ml_config() raises:
    """Test parsing a machine learning model configuration file."""
    var content = read_fixture("ml_config.toml")
    var config = parse(content)

    # Model metadata
    assert_equal(config["model_name"].as_string(), "customer-churn-predictor")
    assert_equal(config["version"].as_string(), "1.2.3")
    assert_equal(config["created_date"].as_string(), "2026-01-07")

    # Hyperparameters
    assert_equal(config["learning_rate"].as_float(), 0.001)
    assert_equal(config["batch_size"].as_int(), 32)
    assert_equal(config["num_epochs"].as_int(), 100)
    assert_equal(config["dropout_rate"].as_float(), 0.2)
    assert_equal(config["weight_decay"].as_float(), 0.0001)

    # Architecture
    assert_equal(config["num_layers"].as_int(), 5)
    assert_equal(config["hidden_size"].as_int(), 256)
    assert_equal(config["activation"].as_string(), "relu")
    assert_true(config["use_batch_norm"].as_bool())

    # Training settings
    assert_true(config["early_stopping"].as_bool())
    assert_equal(config["patience"].as_int(), 10)
    assert_equal(config["min_delta"].as_float(), 0.0001)
    assert_equal(config["validation_split"].as_float(), 0.2)

    # Performance metrics
    assert_equal(config["target_accuracy"].as_float(), 0.95)
    assert_equal(config["target_precision"].as_float(), 0.90)
    assert_equal(config["target_recall"].as_float(), 0.85)
    assert_equal(config["target_f1"].as_float(), 0.875)

    # Data preprocessing
    assert_true(config["normalize_features"].as_bool())
    assert_equal(config["handle_missing"].as_string(), "mean")
    assert_equal(config["scale_method"].as_string(), "standard")


fn test_api_config() raises:
    """Test parsing a REST API configuration file."""
    var content = read_fixture("api_config.toml")
    var config = parse(content)

    # Service metadata
    assert_equal(config["service_name"].as_string(), "analytics-api")
    assert_equal(config["version"].as_string(), "3.0.0")
    assert_equal(config["environment"].as_string(), "production")
    assert_equal(config["region"].as_string(), "us-west-2")

    # Network settings
    assert_equal(config["bind_address"].as_string(), "127.0.0.1")
    assert_equal(config["bind_port"].as_int(), 9000)
    assert_true(config["use_https"].as_bool())
    assert_equal(config["cert_path"].as_string(), "/etc/ssl/cert.pem")

    # Rate limiting
    assert_true(config["rate_limit_enabled"].as_bool())
    assert_equal(config["requests_per_second"].as_float(), 100.0)
    assert_equal(config["burst_size"].as_int(), 150)

    # Timeouts
    assert_equal(config["connection_timeout"].as_float(), 5.0)
    assert_equal(config["read_timeout"].as_float(), 30.0)
    assert_equal(config["write_timeout"].as_float(), 30.0)
    assert_equal(config["idle_timeout"].as_float(), 120.0)

    # Monitoring
    assert_true(config["enable_metrics"].as_bool())
    assert_equal(config["metrics_port"].as_int(), 9090)
    assert_equal(config["health_check_interval"].as_float(), 10.0)

    # Security
    assert_true(config["cors_enabled"].as_bool())
    assert_equal(config["max_request_size"].as_int(), 10485760)
    assert_true(config["require_auth"].as_bool())
    assert_equal(config["session_timeout"].as_float(), 3600.0)


fn test_game_settings() raises:
    """Test parsing a game engine settings file."""
    var content = read_fixture("game_settings.toml")
    var config = parse(content)

    # Game metadata
    assert_equal(config["title"].as_string(), "Epic Adventure")
    assert_equal(config["version"].as_string(), "1.0.0-beta")
    assert_equal(config["developer"].as_string(), "Indie Studio")

    # Graphics settings
    assert_equal(config["resolution_width"].as_int(), 1920)
    assert_equal(config["resolution_height"].as_int(), 1080)
    assert_false(config["fullscreen"].as_bool())
    assert_true(config["vsync"].as_bool())
    assert_equal(config["fps_limit"].as_int(), 60)
    assert_equal(config["anti_aliasing"].as_int(), 4)

    # Audio settings
    assert_equal(config["master_volume"].as_float(), 0.8)
    assert_equal(config["music_volume"].as_float(), 0.6)
    assert_equal(config["sfx_volume"].as_float(), 0.7)
    assert_equal(config["voice_volume"].as_float(), 0.9)
    assert_true(config["mute_on_focus_loss"].as_bool())

    # Gameplay settings
    assert_equal(config["difficulty"].as_string(), "normal")
    assert_true(config["autosave_enabled"].as_bool())
    assert_equal(config["autosave_interval"].as_float(), 300.0)
    assert_true(config["show_tutorials"].as_bool())
    assert_false(config["invert_y_axis"].as_bool())

    # Physics
    assert_equal(config["gravity"].as_float(), -9.81)
    assert_equal(config["time_scale"].as_float(), 1.0)
    assert_equal(config["fixed_timestep"].as_float(), 0.016666667)
    assert_equal(config["max_physics_steps"].as_int(), 10)

    # Network
    assert_false(config["enable_multiplayer"].as_bool())
    assert_equal(config["server_address"].as_string(), "game.example.com")
    assert_equal(config["server_port"].as_int(), 27015)
    assert_equal(config["network_timeout"].as_float(), 10.0)
    assert_equal(config["max_players"].as_int(), 16)


def main():
    """Run all fixture tests."""
    var suite = TestSuite()
    suite.test[test_app_config]()
    suite.test[test_build_config]()
    suite.test[test_ml_config]()
    suite.test[test_api_config]()
    suite.test[test_game_settings]()
    suite^.run()
