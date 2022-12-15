import sys

from utils import match_transform_inputs

Point = tuple[int, int]


def solve_puzzle(coords: list[tuple[Point, Point]]) -> None:
    row = set()
    tracked_row = int(sys.argv[1])
    for scanner, beacon in coords:
        fill_intersection(row, tracked_row, scanner, beacon)
    for _, (x, y) in coords:
        if y == tracked_row:
            row.discard(x)
    print(len(row))


def point(x: str, y: str) -> Point:
    return int(x), int(y)


def manhattan(a: Point, b: Point) -> int:
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


def fill_intersection(row: set[int], tracked_row: int, scanner: Point, beacon: Point) -> None:
    radius = manhattan(scanner, beacon)
    width = radius - abs(scanner[1] - tracked_row)
    for x in range(scanner[0] - width, scanner[0] + width + 1):
        row.add(x)


if __name__ == "__main__":
    beacons = match_transform_inputs(r"x=(-?\d+), y=(-?\d+)", point)
    solve_puzzle(beacons)
