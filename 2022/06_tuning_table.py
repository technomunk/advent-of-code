import fileinput
from collections import deque


def detect_marker(seq: str, marker_len: int = 4) -> int:
    seen = deque(seq[:marker_len], maxlen=marker_len)
    for index, char in enumerate(seq[marker_len:], start=marker_len):
        if len(seen) == len(set(seen)):
            return index
        seen.append(char)
    raise


if __name__ == "__main__":
    lines = [line.strip() for line in fileinput.input("-")]
    for line in lines:
        print(detect_marker(line, 4))
        print(detect_marker(line, 14))
