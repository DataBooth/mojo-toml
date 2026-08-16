from toml import parse

def main() raises:
    var d = parse("infinity = inf\nnot_a_number = nan")
    print("Has infinity:", d.__contains__("infinity"))
    print("Has not_a_number:", d.__contains__("not_a_number"))
