import fileinput
import re
from typing import Callable, Sequence, TypeVar

T = TypeVar("T")


def match_transform(
    line: str,
    pattern: str | re.Pattern[str],
    transform: Callable[[tuple[str, ...]], T],
) -> tuple[T, ...]:
    def transform_match(match: re.Match) -> T:
        return transform(*match.groups())

    return tuple(map(transform_match, re.finditer(pattern, line)))


def match_transform_inputs(
    pattern: str | re.Pattern[str],
    transform: Callable[[tuple[str, ...]], T],
    input_: str = "-",
) -> list[tuple[T, ...]]:
    return [match_transform(line.strip(), pattern, transform) for line in fileinput.input(input_)]


def slurp_lines(input_: str = "-") -> list[str]:
    return [line.strip() for line in fileinput.input(input_)]


def rindex(seq: Sequence[T], value: T) -> int:
    """Get the index of the latest element that equals provided value"""
    for index in range(len(seq) - 1, -1, -1):
        if seq[index] == value:
            return index
    raise ValueError()


def minmax(*values: T) -> tuple[T, T]:
    min_ = values[0]
    max_ = values[0]
    for value in values[1:]:
        if value < min_:
            min_ = value
        if value > max_:
            max_ = value
    return min_, max_


def safe_index(seq: Sequence[T], value: T) -> int | None:
    try:
        return seq.index(value)
    except ValueError:
        return None
