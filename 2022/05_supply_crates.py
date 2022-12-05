import fileinput
import re


def into_crates(lines: list[str]) -> list[list[str]]:
    crates: list[list[str]] = []
    crate_count = int(lines[-1].rsplit(maxsplit=1)[-1])
    for _ in range(crate_count):
        crates.append([])

    for line in reversed(lines[:-1]):
        for index in range(0, len(line) // 4 + 1):
            content = line[index * 4 + 1]
            if content != " ":
                crates[index].append(content)

    return crates


def into_moves(lines: list[str]) -> list[tuple[int, int, int]]:
    moves = []
    for line in lines:
        move = re.fullmatch(r"move (\d+) from (\d) to (\d)", line).groups()
        moves.append(tuple(int(m) for m in move))
    return moves


if __name__ == "__main__":
    lines = [line.strip("\n") for line in fileinput.input("-")]
    separator = lines.index("")
    initial_crates, moves = into_crates(lines[:separator]), into_moves(lines[separator + 1 :])

    crates = [c.copy() for c in initial_crates]
    for amount, from_, to in moves:
        for _ in range(amount):
            content = crates[from_ - 1].pop()
            crates[to - 1].append(content)
    print("".join(crate[-1] for crate in crates))

    crates = [c.copy() for c in initial_crates]
    for amount, from_, to in moves:
        content = crates[from_ - 1][-amount:]
        crates[to - 1].extend(content)
        del crates[from_ - 1][-amount:]
    print("".join(crate[-1] for crate in crates))
