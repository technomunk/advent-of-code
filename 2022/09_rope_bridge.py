import fileinput
from typing import Literal

DIRECTIONS = {
    "U": (0, 1),
    "D": (0, -1),
    "L": (-1, 0),
    "R": (1, 0),
}


class Rope:
    def __init__(self, knots: int) -> None:
        self.knots = [(0, 0) for _ in range(knots)]
        self.tail_positions = {(0, 0)}
        self.min = 0, 0
        self.max = 0, 0

    @property
    def head(self) -> tuple[int, int]:
        return self.knots[0]

    @head.setter
    def head(self, value: tuple[int, int]):
        self.knots[0] = value

    @property
    def tail(self) -> tuple[int, int]:
        return self.knots[-1]

    @tail.setter
    def tail(self, value: tuple[int, int]):
        self.knots[-1] = value

    def move(self, direction: Literal["U", "D", "L", "R"], steps: int) -> None:
        dx, dy = DIRECTIONS[direction]
        for _ in range(steps):
            self.head = self.head[0] + dx, self.head[1] + dy
            self.pull_tail()
            self.min = min(self.min[0], self.head[0]), min(self.min[1], self.head[1])
            self.max = max(self.max[0], self.head[0]), max(self.max[1], self.head[1])

    def pull_tail(self) -> None:
        for i, (x, y) in enumerate(self.knots[1:], 1):
            dx = self.knots[i - 1][0] - x
            dy = self.knots[i - 1][1] - y

            if abs(dx) > 1:
                if dy == 0:
                    self.knots[i] = self.knots[i][0] + sign(dx), self.knots[i][1]
                else:
                    self.knots[i] = self.knots[i][0] + sign(dx), self.knots[i][1] + sign(dy)

            elif abs(dy) > 1:
                if dx == 0:
                    self.knots[i] = self.knots[i][0], self.knots[i][1] + sign(dy)
                else:
                    self.knots[i] = self.knots[i][0] + sign(dx), self.knots[i][1] + sign(dy)

            self.tail_positions.add(self.tail)

    def __repr__(self) -> str:
        return f"Rope(knots={repr(self.knots)})"

    def __str__(self) -> str:
        lines = []
        line = []
        for y in range(self.max[1], self.min[1] - 1, -1):
            line.clear()
            for x in range(self.min[0], self.max[0] + 1):
                try:
                    idx = self.knots.index((x, y))
                except ValueError:
                    idx = None

                if idx == 0:
                    line.append("H")
                elif idx == len(self.knots) - 1:
                    line.append("T")
                elif idx:
                    line.append(str(idx))
                elif (x, y) in self.tail_positions:
                    line.append("#")
                else:
                    line.append(".")

            lines.append("".join(line))

        return "\n".join(lines)


def sign(value: int) -> Literal[-1, 0, 1]:
    if value > 0:
        return 1
    elif value == 0:
        return 0
    return -1


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    rope_2 = Rope(2)
    rope_10 = Rope(10)
    for line in lines:
        direction, steps = line.split()
        rope_2.move(direction, int(steps))
        rope_10.move(direction, int(steps))

    print(len(rope_2.tail_positions))
    print(len(rope_10.tail_positions))
