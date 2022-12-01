import fileinput
from itertools import groupby
from typing import Generator, Iterable


def load_groups(lines: list[str]) -> Generator[list[int], None, None]:
    for has_contents, group in groupby(lines, bool):
        if has_contents:
            yield [int(calories) for calories in group]


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    groups = list(load_groups(lines))
    sums = [sum(g) for g in groups]
    print(max(sums))
    print(sum(sorted(sums, reverse=True)[:3]))
