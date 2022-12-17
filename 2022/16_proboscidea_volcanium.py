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

    def max_relative_neighbor(self, valves: dict[str, Self], ignore: set[str]) -> str:
        max_flow = 0
        neighbor = ""
        for identifier, distance in self.distances.items():
            if identifier in ignore:
                continue

            heuristic_flow = valves[identifier].flow_rate / (distance**2)
            if heuristic_flow > max_flow:
                max_flow = heuristic_flow
                neighbor = identifier

        return neighbor


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


def optimal_single_path(valves: dict[str, Valve]) -> int:
    ignore = {identifier for identifier, valve in valves.items() if valve.flow_rate <= 0}
    point = "AA"
    time = 30
    total_flow = 0
    while time > 0 and point:
        ignore.add(point)
        np = valves[point].max_relative_neighbor(valves, ignore)
        if not np:
            break
        distance = valves[point].distances[np]
        time -= distance
        if time <= 0:
            break
        total_flow += valves[np].relieved_pressure(time)
        time -= 1
        point = np

    return total_flow


def optimal_double_path(valves: dict[str, Valve]) -> int:
    ignore = {identifier for identifier, valve in valves.items() if valve.flow_rate <= 0}
    point_a = "AA"
    point_b = "AA"
    time_a = 26
    time_b = 26
    total_flow = 0
    while (time_a > 0 or time_b > 0) and (point_a or point_b):
        if time_a > time_b:
            np = valves[point_a].max_relative_neighbor(valves, ignore)
            ignore.add(np)
            if not np:
                time_a = 0
                continue
            distance = valves[point_a].distances[np]
            point_a = np
            time_a -= distance
            if time_a <= 0:
                continue
            total_flow += valves[np].relieved_pressure(time_a)
            time_a -= 1
        else:
            np = valves[point_b].max_relative_neighbor(valves, ignore)
            ignore.add(np)
            if not np:
                time_b = 0
                continue
            distance = valves[point_b].distances[np]
            point_b = np
            time_b -= distance
            if time_b <= 0:
                continue
            total_flow += valves[np].relieved_pressure(time_b)
            time_b -= 1
    return total_flow


def solve_puzzle(valves: dict[str, Valve]) -> None:
    calculate_distances(valves)
    print(optimal_single_path(valves))
    print(optimal_double_path(valves))


if __name__ == "__main__":
    valves = {
        identifier: valve
        for ((identifier, valve),) in match_transform_inputs(
            r"Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([\w\s,]+)",
            Valve.from_regex,
        )
    }
    solve_puzzle(valves)
