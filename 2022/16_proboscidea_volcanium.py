from dataclasses import dataclass
from functools import cache
from typing import Self

from utils import match_transform_inputs


@dataclass
class Valve:
    flow_rate: int
    connections: list[str]

    @classmethod
    def from_regex(cls, identifier: str, flow: str, connections: str) -> tuple[str, Self]:
        return identifier, cls(int(flow), connections.split(", "))


class Solution:
    def __init__(self, valves: dict[str, Valve]) -> None:
        self.valves = valves

    @cache
    def optimal_path(self, time: int, identifier: str, opened: frozenset[str] = frozenset()) -> int:
        """Find the path that relieves the most pressure."""
        if time <= 0:
            return 0

        valve = valves[identifier]

        options = [
            self.optimal_path(time - 1, connection, opened) for connection in valve.connections
        ]

        if identifier not in opened:
            pressure = (time - 1) * valve.flow_rate
            options.extend(
                pressure + self.optimal_path(time - 2, connection, frozenset(opened | {identifier}))
                for connection in valve.connections
            )

            options.append(pressure)

        return max(options)


def solve_puzzle(valves: dict[str, Valve]) -> None:
    print(Solution(valves).optimal_path(30, "AA"))


if __name__ == "__main__":
    valves = {
        identifier: valve
        for ((identifier, valve),) in match_transform_inputs(
            r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w\s,]+)",
            Valve.from_regex,
        )
    }
    solve_puzzle(valves)
