import fileinput

def is_visible(grid: list[tuple[int, ...]], x: int, y: int) -> bool:
    height = grid[y][x]
    return any([
        all(grid[y][dx] < height for dx in range(x)),
        all(grid[y][dx] < height for dx in range(x + 1, len(grid[y]))),
        all(grid[dy][x] < height for dy in range(y)),
        all(grid[dy][x] < height for dy in range(y + 1, len(grid))),
    ])


def scenic_score(grid: list[tuple[int, ...]], x: int, y: int) -> int:
    height = grid[y][x]
    left, right, top, bottom = 0, 0, 0, 0

    for dx in range(x - 1, -1, -1):
        left += 1
        if grid[y][dx] >= height:
            break

    for dx in range(x + 1, len(grid[y])):
        right += 1
        if grid[y][dx] >= height:
            break

    for dy in range(y - 1, -1, -1):
        top += 1
        if grid[dy][x] >= height:
            break

    for dy in range(y + 1, len(grid)):
        bottom += 1
        if grid[dy][x] >= height:
            break

    return left * right * top * bottom


def solve_puzzle(lines: list[str]) -> None:
    grid = [tuple(int(ch) for ch in line) for line in lines]
    print(sum(is_visible(grid, x, y) for y, row in enumerate(grid) for x, _ in enumerate(row)))
    print(max(scenic_score(grid, x, y) for y, row in enumerate(grid) for x, _ in enumerate(row)))


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    solve_puzzle(lines)
