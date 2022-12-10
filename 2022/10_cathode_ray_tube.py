import fileinput
from io import StringIO


class CPU:
    def __init__(self):
        self.x = 1
        self.cycle = 1
        self.samples: dict[int, int] = {}

    def noop(self) -> None:
        self.samples[self.cycle] = self.x
        self.cycle += 1

    def addx(self, dx: int):
        self.samples[self.cycle + 0] = self.x
        self.samples[self.cycle + 1] = self.x
        self.cycle += 2
        self.x += dx

    def crt(self) -> str:
        result = StringIO()
        for cycle, sample in self.samples.items():
            pos = (cycle - 1) % 40
            if abs(sample - pos) <= 1:
                result.write("#")
            else:
                result.write(".")
            if cycle % 40 == 0:
                result.write("\n")
        return result.getvalue()


SAMPLED_CYCLES = [20, 60, 100, 140, 180, 220]


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    cpu = CPU()
    for line in lines:
        opcode, *args = line.split()
        op = getattr(cpu, opcode)
        op(*(int(arg) for arg in args))

    print(sum(cycle * cpu.samples[cycle] for cycle in SAMPLED_CYCLES))
    print(cpu.crt())
