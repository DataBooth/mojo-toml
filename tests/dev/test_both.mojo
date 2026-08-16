from toml import parse

def main() raises:
    var d1 = parse("a = inf\nb = nan")
    print("Test 1 passed")

    var d2 = parse("infinity = inf\nnot_a_number = nan")
    print("Test 2 passed")
