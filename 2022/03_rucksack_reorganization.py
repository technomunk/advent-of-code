import fileinput
from typing import Generator


def priority(item: str) -> int:
    order = ord(item)
    if order < ord("a"):
        return order - ord("A") + 27
    return order - ord("a") + 1


def compartments(line: str) -> tuple[set[str], set[str]]:
    half = len(line) // 2
    return set(line[:half]), set(line[half:])


def triplets(lines: list[str]) -> Generator[tuple[str, str, str], None, None]:
    for i in range(0, len(lines), 3):
        yield lines[i], lines[i + 1], lines[i + 2]


def common(*sacks: set[str]) -> str:
    sacks = iter(sacks)
    intersection = next(sacks)
    for sack in sacks:
        intersection &= sack
    return intersection.pop()


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    compartment_items = (compartments(line) for line in lines)
    group_items = map(lambda t: tuple(set(items) for items in t), (triplet for triplet in triplets(lines)))
    print(sum(priority(common(*items)) for items in compartment_items))
    print(sum(priority(common(*items)) for items in group_items))
