from dataclasses import dataclass, field
from heapq import heapify, heappush
from typing import Self

from utils import match_transform_inputs

_path_cache = {}


@dataclass
class Valve:
    flow_rate: int
    connections: list[str]
    distances: dict[str, int] = field(default_factory=dict)

    @classmethod
    def from_regex(cls, identifier: str, flow: str, connections: str) -> tuple[str, Self]:
        return identifier, cls(int(flow), connections.split(", "))

    def relieved_pressure(self, time: int) -> int:
        return self.flow_rate * (time - 1)


def calculate_distance(valves: dict[str, Valve], a: str, b: str) -> None:
    """
    Find shortest distance between 2 valves and set it in valves' distances field
    also stores intermediate results
    """
    valve_a = valves[a]
    valve_a.distances[a] = 0

    to_check = {identifier for identifier in valves.keys()}
    while to_check:
        identifier = min(to_check, key=lambda x: valve_a.distances.get(x, len(valves)))
        to_check.discard(identifier)

        for connection in valves[identifier].connections:
            if connection not in to_check:
                continue

            distance = valve_a.distances[identifier] + 1
            if distance < valve_a.distances.get(connection, len(valves)):
                valve_a.distances[connection] = distance
                valves[connection].distances[a] = distance


# Calculate relative distances for each valve
# then we can immediately know how much flow we can get at each point
# ! always turn on valve or walk toward valve to turn on !
# so we want to turn on as many valves as possible, and we just want to find optimal order
def calculate_distances(valves: dict[str, Valve]) -> None:
    identifiers = list(valves.keys())
    for i, a in enumerate(identifiers):
        for b in identifiers[i + 1 :]:
            calculate_distance(valves, a, b)


def optimal_path(
    valves: dict[str, Valve],
    time: int,
    identifier: str,
    ignore: frozenset[str],
) -> int:
    global _path_cache
    cached_result = _path_cache.get((time, identifier, ignore))
    if cached_result is not None:
        return cached_result

    if time <= 0 or len(valves) == len(ignore):
        return 0

    ignore |= {identifier}
    valve = valves[identifier]
    options = [
        optimal_path(valves, time - distance, connection, ignore)
        for connection, distance in valve.distances.items()
        if connection not in ignore
    ]

    pressure = valve.relieved_pressure(time)
    options.extend(
        pressure + optimal_path(valves, time - distance - 1, connection, ignore)
        for connection, distance in valve.distances.items()
        if connection not in ignore
    )

    options.append(pressure)

    result = max(options)
    _path_cache[(time, identifier, ignore)] = result
    return result


def solve_puzzle(valves: dict[str, Valve]) -> None:
    calculate_distances(valves)
    ignore = frozenset(identifier for identifier, valve in valves.items() if valve.flow_rate <= 0)
    print(optimal_path(valves, 30, "AA", ignore))


if __name__ == "__main__":
    valves = {
        identifier: valve
        for ((identifier, valve),) in match_transform_inputs(
            r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w\s,]+)",
            Valve.from_regex,
        )
    }
    solve_puzzle(valves)
