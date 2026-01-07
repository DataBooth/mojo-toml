from toml import parse

fn main() raises:
    # Test exactly what the test has
    var data = parse("infinity = inf\nnot_a_number = nan")
    print("Has infinity:", data.__contains__("infinity"))
    if data.__contains__("infinity"):
        print("  is float:", data["infinity"].is_float())
    print("Has not_a_number:", data.__contains__("not_a_number"))
    if data.__contains__("not_a_number"):
        print("  is float:", data["not_a_number"].is_float())
