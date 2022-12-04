import fileinput


def fully_contains(a: tuple[int, int], b: tuple[int, int]) -> bool:
    return (a[0] <= b[0] and a[1] >= b[1]) or (a[0] >= b[0] and a[1] <= b[1])


def overlaps(a: tuple[int, int], b: tuple[int, int]) -> bool:
    # Iirc it's possible to do overlap check with just 4 comparisons, but I'm too lazy to do it
    return any(
        [
            a[0] >= b[0] and a[0] <= b[1],
            a[1] >= b[0] and a[1] <= b[1],
            b[0] >= a[0] and b[0] <= a[1],
            b[1] >= a[0] and b[1] <= a[1],
        ]
    )


def into_range(s: str) -> tuple[int, int]:
    return tuple(map(int, s.split("-")))


def into_ranges(line: str) -> tuple[tuple[int, int], tuple[int, int]]:
    return tuple(map(into_range, line.split(",")))


if __name__ == "__main__":
    ranges = [into_ranges(line.strip()) for line in fileinput.input("-")]
    print(sum(map(int, (fully_contains(*r) for r in ranges))))
    print(sum(map(int, (overlaps(*r) for r in ranges))))
