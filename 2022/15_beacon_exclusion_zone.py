from concurrent.futures import ThreadPoolExecutor, as_completed
from multiprocessing import cpu_count
import sys

from utils import match_transform_inputs

Point = tuple[int, int]


def check_range(y_range: range, x_range: range, beacons: list[tuple[Point, int]]) -> Point | None:
    for y in y_range:
        x = x_range.start
        while x < x_range.stop:
            overlap = max(radius - manhattan((x, y), beacon) + 1 for beacon, radius in beacons)
            if overlap > 0:
                x += overlap
                continue
            return x, y
    return None


def solve_puzzle(coords: list[tuple[Point, Point]]) -> None:
    beacons = list(map(lambda x: (x[0], manhattan(*x)), coords))
    max_coord = 4_000_000 if len(sys.argv) == 1 else 20
    checked_row = 2_000_000 if len(sys.argv) == 1 else 10
    thread_count = cpu_count()
    range_height = max_coord // thread_count
    with ThreadPoolExecutor(thread_count) as executor:
        futures = {
            executor.submit(
                check_range,
                range(range_height * i, range_height * (i + 1)),
                range(max_coord),
                beacons,
            )
            for i in range(thread_count)
        }
        for future in as_completed(futures):
            if result := future.result():
                print(result[0] * 4_000_000 + result[1])


def point(x: str, y: str) -> Point:
    return int(x), int(y)


def manhattan(a: Point, b: Point) -> int:
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


if __name__ == "__main__":
    beacons = match_transform_inputs(r"x=(-?\d+), y=(-?\d+)", point)
    solve_puzzle(beacons)
