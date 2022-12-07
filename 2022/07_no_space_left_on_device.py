import fileinput


class Navigator:
    def __init__(self) -> None:
        self.path: list[str] = []
        self.tree: dict = {}

    def cd(self, dir_: str) -> str:
        match dir_:
            case "/":
                self.path = ["/"]
            case "..":
                self.path.pop()
            case _:
                self.path.append(dir_)

        return "/".join(self.path)

    def ls(self, lines: list[str]) -> None:
        leaf = self.tree
        for dir_ in self.path[1:]:
            leaf = leaf[dir_]

        for line in lines:
            a, b = line.split(maxsplit=1)
            if a == "dir":
                leaf.setdefault(b, {})
            else:
                leaf[b] = int(a)

    def collect_sizes(self) -> dict[str, int]:
        sizes = {}
        dir_size("", self.tree, sizes)
        return sizes


def dir_size(path: str, dir_: dict, sizes: dict[str, int]) -> int:
    size = 0
    for name, value in dir_.items():
        if isinstance(value, dict):
            member_size = dir_size(path + f"/{name}", value, sizes)
            size += member_size
        else:
            size += value
    sizes[path] = size
    return size


def solve_puzzle(lines: list[str]) -> None:
    navigator = Navigator()
    ls_output = []
    for line in lines:
        if line.startswith("$"):
            if ls_output:
                navigator.ls(ls_output)
                ls_output.clear()
            if line == "$ ls":
                continue
            # assume cd
            _, dir_ = line.rsplit(maxsplit=1)
            navigator.cd(dir_)
        else:
            ls_output.append(line)

    if ls_output:
        navigator.ls(ls_output)
        ls_output.clear()

    sizes = navigator.collect_sizes()
    print(sum(filter(lambda d: d <= 100_000, sizes.values())))
    remaining_space = 70_000_000 - sizes[""]
    to_free = 30_000_000 - remaining_space
    print(min(filter(lambda d: d >= to_free, sizes.values())))


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    solve_puzzle(lines)
