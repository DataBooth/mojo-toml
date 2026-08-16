"""Test if Dict iteration works without [] dereference operator."""

from std.collections import Dict

def main() raises:
    var data = Dict[String, String]()
    data["name"] = "Alice"
    data["age"] = "30"
    data["city"] = "Sydney"

    print("Testing Dict iteration without [] operator:")
    print()

    # Try accessing without [] dereference
    for entry in data.items():
        print("Key:", entry.key, "Value:", entry.value)

    print()
    print("✅ Success! Can access .key and .value without [] operator")
