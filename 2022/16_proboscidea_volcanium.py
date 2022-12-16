from dataclasses import dataclass, field
from typing import Self

from utils import match_transform_inputs

_path_cache = {}


@dataclass
class Valve:
    flow_rate: int
    connections: list[str]
    distances: dict[str, int] = field(init=False)

    @classmethod
    def from_regex(cls, identifier: str, flow: str, connections: str) -> tuple[str, Self]:
        return identifier, cls(int(flow), connections.split(", "))


# Calculate relative distances for each valve
# then we can immediately know how much flow we can get at each point
def calculate_distances(valves: dict[str, Valve]) -> None:
    for identifier, valve in valves.items():
        valve.distances = {identifier: 0}
        for connection in valve.connections:
            valve.distances[connection] = 1


def optimal_path(
    valves: dict[str, Valve],
    time: int,
    identifier: str,
    opened: frozenset[str] = frozenset(),
) -> int:
    global _path_cache
    cached_result = _path_cache.get((time, identifier, opened))
    if cached_result is not None:
        return cached_result

    if time <= 0 or valves.keys() == opened:
        return 0

    valve = valves[identifier]
    options = [
        optimal_path(valves, time - 1, connection, opened) for connection in valve.connections
    ]

    if identifier not in opened and time > 1:
        pressure = (time - 1) * valve.flow_rate
        options.extend(
            pressure + optimal_path(valves, time - 2, connection, opened | {identifier})
            for connection in valve.connections
        )

    result = max(options)
    _path_cache[(time, identifier, opened)] = result
    return result


def solve_puzzle(valves: dict[str, Valve]) -> None:
    print(optimal_path(valves, 30, "AA"))


if __name__ == "__main__":
    valves = {
        identifier: valve
        for ((identifier, valve),) in match_transform_inputs(
            r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w\s,]+)",
            Valve.from_regex,
        )
    }
    solve_puzzle(valves)
