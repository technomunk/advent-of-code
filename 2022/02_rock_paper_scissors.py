import fileinput
from typing import Literal

POINTS = {
    "A": {"X": 3, "Y": 6, "Z": 0},
    "B": {"X": 0, "Y": 3, "Z": 6},
    "C": {"X": 6, "Y": 0, "Z": 3},
}
STRATEGIES = {
    "A": {"X": "Z", "Y": "X", "Z": "Y"},
    "B": {"X": "X", "Y": "Y", "Z": "Z"},
    "C": {"X": "Y", "Y": "Z", "Z": "X"},
}


def score(left: Literal["A", "B", "C"], right: Literal["X", "Y", "Z"]) -> int:
    return POINTS[left][right] + ord(right) - ord("W")


def strategy_score(left: Literal["A", "B", "C"], right: Literal["X", "Y", "Z"]) -> int:
    return score(left, STRATEGIES[left][right])


if __name__ == "__main__":
    strategies = [line.strip().split() for line in fileinput.input("-")]
    total_score = sum(score(l, r) for l, r in strategies)
    total_strategy_score = sum(strategy_score(*s) for s in strategies)
    print(total_score)
    print(total_strategy_score)
