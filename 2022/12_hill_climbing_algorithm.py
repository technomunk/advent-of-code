import fileinput
from collections import deque
from copy import deepcopy

from grid import Grid
from utils import safe_index


def shortest_path(grid: Grid[int], from_: tuple[int, int], to: tuple[int, int]) -> int:
    """breadth-first search"""
    checked = Grid(grid.dims, (False for _ in grid))
    to_check = deque([(from_, 0)])

    while to_check:
        index, distance = to_check.popleft()
        distance += 1
        height = grid[index]
        for neighbor_index in grid.direct_neighbor_indexes(index):
            if (grid[neighbor_index] - height) <= 1 and not checked[neighbor_index]:
                if neighbor_index == to:
                    return distance
                checked[neighbor_index] = True
                to_check.append((neighbor_index, distance))

    raise


def shortest_stroll(grid: Grid[int], target: tuple[int, int]) -> int:
    checked = Grid(grid.dims, (False for _ in grid))
    to_check = deque([(target, 0)])

    while to_check:
        index, distance = to_check.popleft()
        distance += 1
        height = grid[index]
        for neighbor_index in grid.direct_neighbor_indexes(index):
            neighbor_height = grid[neighbor_index]
            if (height - neighbor_height) <= 1 and not checked[neighbor_index]:
                if neighbor_height == 0:
                    return distance
                checked[neighbor_index] = True
                to_check.append((neighbor_index, distance))

    raise


def find_start_and_finish(lines: str) -> tuple[tuple[int, int], tuple[int, int]]:
    from_ = 0, 0
    to = 0, 0
    for y, line in enumerate(lines):
        x = safe_index(line, "S")
        if x is not None:
            from_ = x, y
        x = safe_index(line, "E")
        if x is not None:
            to = x, y
    return from_, to


def height(ch: str) -> int:
    match ch:
        case "S":
            return 0
        case "E":
            return 25
        case _:
            return ord(ch) - ord("a")


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    from_, to = find_start_and_finish(lines)
    grid = Grid((len(lines[0]), len(lines)), (height(ch) for line in lines for ch in line))
    print(shortest_path(grid, from_, to))
    print(shortest_stroll(grid, to))
