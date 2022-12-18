from utils import match_transform_inputs

Point = tuple[int, int, int]


def neighbors(x: int, y: int, z: int) -> list[Point]:
    return [
        (x - 1, y, z),
        (x + 1, y, z),
        (x, y - 1, z),
        (x, y + 1, z),
        (x, y, z - 1),
        (x, y, z + 1),
    ]


def fill_void(walls: set[Point], point: Point, bounds: Point) -> bool:
    max_x, max_y, max_z = bounds
    visited = set()
    to_visit = [point]

    while to_visit:
        point = to_visit.pop()
        visited.add(point)
        for neighbor in neighbors(*point):
            x, y, z = neighbor
            if any([x < 0, x > max_x, y < 0, y > max_y, z < 0, z > max_z]):
                return False
            if neighbor not in walls and neighbor not in visited:
                to_visit.append(neighbor)

    walls |= visited
    return True


def outside_surface_area(walls: set[Point]) -> int:
    max_x, max_y, max_z = 0, 0, 0
    for x, y, z in walls:
        max_x = max(max_x, x)
        max_y = max(max_y, y)
        max_z = max(max_z, z)

    bounds = max_x, max_y, max_z
    for point in walls.copy():
        for neighbor in neighbors(*point):
            fill_void(walls, neighbor, bounds)

    return surface_area(walls)


def surface_area(droplet: set[Point]) -> int:
    area = 0
    for x, y, z in droplet:
        faces = [
            (x - 1, y, z),
            (x + 1, y, z),
            (x, y - 1, z),
            (x, y + 1, z),
            (x, y, z - 1),
            (x, y, z + 1),
        ]
        area += sum(face not in droplet for face in faces)
    return area


def solve_puzzle(points: list[Point]) -> None:
    print(surface_area(set(points)))
    print(outside_surface_area(set(points)))


if __name__ == "__main__":
    points = match_transform_inputs(r"(\d+)", int)
    solve_puzzle(points)
