import fileinput
import re
from typing import Callable, TypeVar

T = TypeVar("T")


def match_transform(
    line: str,
    pattern: str | re.Pattern[str],
    transform: Callable[[str], T],
) -> tuple[T, ...]:
    return tuple(map(transform, re.match(pattern, line).groups()))


def match_transform_inputs(
    pattern: str | re.Pattern[str],
    transform: Callable[[str], T],
    input_: str = "-",
) -> list[tuple[T, ...]]:
    return [match_transform(line.strip(), pattern, transform) for line in fileinput.input(input_)]
