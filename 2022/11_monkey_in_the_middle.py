import fileinput
import re
from copy import deepcopy
from dataclasses import dataclass
from itertools import groupby
from math import lcm
from typing import Callable, ClassVar, Self


@dataclass
class Monkey:
    items: list[int]
    operation: Callable[[int], int]
    test_value: int
    true_target: int
    false_target: int

    inspected_count: int = 0
    test_lcm: ClassVar[int]

    @classmethod
    def parse(cls, lines: list[str]) -> Self:
        items_line = re.sub(r"[^\d,]", "", lines[1])
        items = [int(item) for item in items_line.split(",")]
        operation = parse_operation(lines[2])
        test_value = int(re.sub(r"[^\d]", "", lines[3]))
        true_target = int(re.sub(r"[^\d]", "", lines[4]))
        false_target = int(re.sub(r"[^\d]", "", lines[5]))
        return cls(items, operation, test_value, true_target, false_target)

    def inspect_items(self, monkeys: list[Self], relief: bool) -> None:
        for item in self.items:
            worry = self.operation(item)
            if relief:
                worry //= 3
            worry %= self.test_lcm
            if worry % self.test_value == 0:
                monkeys[self.true_target].items.append(worry)
            else:
                monkeys[self.false_target].items.append(worry)
        self.inspected_count += len(self.items)
        self.items.clear()


def parse_operation(line: str) -> Callable[[int], int]:
    matches = re.fullmatch(r"Operation: new = (?P<a>old|\d+) (?P<op>[*+]) (?P<b>old|\d+)", line)
    a = matches.group("a")
    b = matches.group("b")

    def add(x: int) -> int:
        a_val = x if a == "old" else int(a)
        b_val = x if b == "old" else int(b)
        return a_val + b_val

    def mul(x: int) -> int:
        a_val = x if a == "old" else int(a)
        b_val = x if b == "old" else int(b)
        return a_val * b_val

    return add if matches.group("op") == "+" else mul


def solve_puzzle(lines: list[str]) -> None:
    relief_monkeys: list[Monkey] = []
    for has_content, mokney_lines in groupby(lines, bool):
        if has_content:
            relief_monkeys.append(Monkey.parse(list(mokney_lines)))
    stress_monkeys = deepcopy(relief_monkeys)
    Monkey.test_lcm = lcm(*(monkey.test_value for monkey in stress_monkeys))

    for _ in range(20):
        for monkey in relief_monkeys:
            monkey.inspect_items(relief_monkeys, relief=True)

    for _ in range(10_000):
        for monkey in stress_monkeys:
            monkey.inspect_items(stress_monkeys, relief=False)

    relief_monkey_business = sorted((monkey.inspected_count for monkey in relief_monkeys))[-2:]
    stress_monkey_business = sorted((monkey.inspected_count for monkey in stress_monkeys))[-2:]
    print(relief_monkey_business[0] * relief_monkey_business[1])
    print(stress_monkey_business[0] * stress_monkey_business[1])


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    solve_puzzle(lines)
