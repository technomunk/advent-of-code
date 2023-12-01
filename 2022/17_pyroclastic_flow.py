import sys
from math import lcm
from typing import Literal

from utils import slurp_lines

ROCKS = [
    bytes.fromhex("3C"),  # horizontal line
    bytes.fromhex("10 38 10"),  # plus
    bytes.fromhex("38 08 08"),  # corner
    bytes.fromhex("20 20 20 20"),  # vertical line
    bytes.fromhex("30 30"),  # square
]

LEFT_EDGE = 128
RIGHT_EDGE = 2


def shift(rock: bytes, rows: bytes, left: bool) -> None:
    assert len(rock) == len(rows)

    if left:
        if any(byte & LEFT_EDGE for byte in rock):
            return rock
    else:
        if any(byte & RIGHT_EDGE for byte in rock):
            return rock

    moved_rock = bytes(byte << 1 if left else byte >> 1 for byte in rock)
    return rock if intersect(moved_rock, rows) else moved_rock


def intersect(a: bytes, b: bytes) -> bool:
    return any(byte_a & byte_b for byte_a, byte_b in zip(a, b))


def strmask(b: int) -> str:
    return "".join("#" if b & (128 >> i) else "." for i in range(7))


class Pit:
    def __init__(self, streams: str) -> None:
        self.pile = bytearray(64)
        self.streams = streams
        self.stream_index = -1
        self.offset = 0
        self.top = 0

    def drop(self, rock: bytes) -> None:
        height = self.top + 3

        # drop while possible
        rows = self.pile[height : height + len(rock)]
        while not intersect(rock, rows) and height >= 0:
            rock = shift(rock, rows, self.stream() == "<")
            height -= 1
            rows = self.pile[height : height + len(rock)]
        height += 1

        # insert rock into pile
        for i, byte in enumerate(rock):
            self.pile[height + i] |= byte

    def __getitem__(self, idx: slice | int) -> bytes:
        if isinstance(idx, slice):
            pass

    def stream(self) -> Literal["<", ">"]:
        self.stream_index += 1
        if self.stream_index == len(self.streams):
            self.stream_index = 0
        return self.streams[self.stream_index]

    def draw(self) -> None:
        for byte in reversed(self.pile):
            print(f"{strmask(byte)}")
        print("=" * 7)


def solve_puzzle(streams: str) -> None:
    pit = Pit(streams)
    for i in range(2022):
        pit.drop(ROCKS[i % len(ROCKS)])

    for i in range(2022, 1_000_000_000_000):
        if i % 1_000_000 == 0:
            print(i, end="\r")
        pit.drop(ROCKS[i % len(ROCKS)])

    print(pit.height)


if __name__ == "__main__":
    streams = slurp_lines()[0]
    solve_puzzle(streams)
