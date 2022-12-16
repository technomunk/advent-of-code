from dataclasses import dataclass, field
from typing import Self

from utils import match_transform_inputs


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

    def max_relative_neighbor(
        self, valves: dict[str, Self], ignore: set[str] = {}
    ) -> tuple[str, float]:
        max_flow = 0
        neighbor = ""
        for identifier, distance in self.distances.items():
            if identifier in ignore:
                continue

            heuristic_flow = valves[identifier].flow_rate / (distance**1.2)
            if heuristic_flow > max_flow:
                max_flow = heuristic_flow
                neighbor = identifier

        return neighbor, max_flow


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


def calculate_distances(valves: dict[str, Valve]) -> None:
    identifiers = list(valves.keys())
    for i, a in enumerate(identifiers):
        for b in identifiers[i + 1 :]:
            calculate_distance(valves, a, b)


def optimal_path(valves: dict[str, Valve]) -> int:
    ignore = {identifier for identifier, valve in valves.items() if valve.flow_rate <= 0}
    point = "AA"
    time = 30
    total_flow = 0
    while time > 0 and point:
        ignore.add(point)
        np, flow = valves[point].max_relative_neighbor(valves, ignore)
        if np == "":
            break
        distance = valves[point].distances[np]
        time -= distance
        if distance > time:
            break
        total_flow += valves[np].relieved_pressure(time)
        time -= 1
        point = np
        print(np, f"time={time:2} total={total_flow:5} flow={flow}")
    return total_flow


def solve_puzzle(valves: dict[str, Valve]) -> None:
    calculate_distances(valves)
    ignore = frozenset(identifier for identifier, valve in valves.items() if valve.flow_rate <= 0)
    print(optimal_path(valves))


if __name__ == "__main__":
    valves = {
        identifier: valve
        for ((identifier, valve),) in match_transform_inputs(
            r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w\s,]+)",
            Valve.from_regex,
        )
    }
    solve_puzzle(valves)
