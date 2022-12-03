import fileinput
from typing import Generator, Iterable


def priority(item: str) -> int:
    order = ord(item)
    if order < ord("a"):
        return order - ord("A") + 27
    return order - ord("a") + 1


def halves(line: str) -> tuple[str, str]:
    half = len(line) // 2
    return line[:half], line[half:]


def triplets(lines: list[str]) -> Generator[tuple[str, str, str], None, None]:
    for i in range(0, len(lines), 3):
        yield lines[i], lines[i + 1], lines[i + 2]


def itemize(group: Iterable[str]) -> tuple[str, ...]:
    return tuple(set(items) for items in group)


def common(*sacks: set[str]) -> str:
    sacks = iter(sacks)
    intersection = next(sacks)
    for sack in sacks:
        intersection &= sack
    return intersection.pop()


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    compartment_items = map(itemize, (halves(line) for line in lines))
    group_items = map(itemize, (triplet for triplet in triplets(lines)))
    print(sum(priority(common(*items)) for items in compartment_items))
    print(sum(priority(common(*items)) for items in group_items))
