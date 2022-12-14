from io import StringIO

from grid import Grid
from utils import match_transform_inputs, minmax

Point = tuple[int, int]

EMPTY = 0
WALL = 1
SAND = 2
PARTICLES = {EMPTY: ".", WALL: "#", SAND: "O"}


class Sandpit:
    def __init__(self, walls: list[tuple[Point, ...]]) -> None:
        height = max(point[1] for path in walls for point in path) + 2
        self.min_x = 500 - height
        width = height * 2
        self.grid = Grid((width, height), (EMPTY for _ in range(height * width)))
        for wall in walls:
            self._insert_wall(wall)

    def __str__(self) -> None:
        result = StringIO()
        for y in range(self.grid.dims[1]):
            for x in range(self.grid.dims[0]):
                result.write(PARTICLES[self.grid[x, y]])
            result.write("\n")
        return result.getvalue()

    def count_sand(self) -> int:
        return sum(p == SAND for p in self.grid)

    def _insert_wall(self, wall: tuple[Point, ...]) -> None:
        for a, b in zip(wall, wall[1:]):
            min_x, max_x = minmax(a[0], b[0])
            min_y, max_y = minmax(a[1], b[1])
            for y in range(min_y, max_y + 1):
                for x in range(min_x, max_x + 1):
                    self.grid[x - self.min_x, y] = WALL

    def drop_sand(self, floor: bool) -> bool:
        if self.grid[500 - self.min_x, 0]:
            return False

        x = 500 - self.min_x
        for y in range(1, self.grid.dims[1]):
            if self.grid[x, y]:
                if self.grid[x - 1, y]:
                    if self.grid[x + 1, y]:
                        self.grid[x, y - 1] = SAND
                        return True
                    else:
                        x += 1
                else:
                    x -= 1

        if floor:
            self.grid[x, y] = SAND
            return True

        return False


def into_point(s: str) -> Point:
    return tuple(int(x) for x in s.split(","))


if __name__ == "__main__":
    walls = match_transform_inputs(r"(\d+,\d+)", into_point)
    sandpit = Sandpit(walls)
    while sandpit.drop_sand(floor=False):
        pass
    print(sandpit.count_sand())
    while sandpit.drop_sand(floor=True):
        pass
    print(sandpit.count_sand())
