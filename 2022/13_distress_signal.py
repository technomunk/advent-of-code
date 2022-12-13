from functools import cmp_to_key
from itertools import groupby, zip_longest
from typing import Literal, Union

from utils import rindex, slurp_lines

Packet = list[Union[int, "Packet"]]


def tokenize(line: str) -> list[Literal["[", "]"] | int]:
    token_start = None
    tokens = []
    for i, char in enumerate(line):
        if char in "[],":
            if token_start is not None:
                tokens.append(int(line[token_start:i]))
                token_start = None
            if char in "[]":
                tokens.append(char)
        elif token_start is None:
            token_start = i

    return tokens


def slurp_packet(tokens: list[Literal["[", "]"] | int]) -> tuple[Packet, int]:
    assert tokens[0] == "["
    result = []
    i = 1
    while i < len(tokens):
        match tokens[i]:
            case "[":
                value, length = slurp_packet(tokens[i:])
                result.append(value)
                i += length
            case "]":
                return result, i
            case _:
                result.append(tokens[i])
        i += 1
    return result


def parse_packet(line: str) -> Packet:
    return slurp_packet(tokenize(line))[0]


def are_ordered(first: Packet | int, second: Packet | int) -> bool | None:
    if isinstance(first, int):
        if isinstance(second, int):
            if first == second:
                return None
            return first < second
        first = [first]
    if isinstance(second, int):
        second = [second]

    for a, b in zip_longest(first, second, fillvalue=None):
        if a is None:
            return True
        if b is None:
            return False
        known_order = are_ordered(a, b)
        if known_order is not None:
            return known_order

    return None


@cmp_to_key
def sort_key(a: Packet, b: Packet) -> int:
    known_order = are_ordered(a, b)
    assert known_order is not None
    return -1 if known_order else 1


if __name__ == "__main__":
    lines = slurp_lines("-")
    pairs = []
    # Note that the inputs are valid python syntax, so it could be copy-pasted or evaluated by the interpreter
    # but that feels very much against the spirit of the challenge
    for has_content, pair in groupby(lines, bool):
        if has_content:
            pairs.append(tuple(parse_packet(element) for element in pair))

    print(sum(i * are_ordered(*pair) for i, pair in enumerate(pairs, start=1)))

    packets = [element for pair in pairs for element in pair]
    packets.append([[2]])
    packets.append([[6]])
    packets.sort(key=sort_key)
    print((packets.index([[2]]) + 1) * (packets.index([[6]]) + 1))
