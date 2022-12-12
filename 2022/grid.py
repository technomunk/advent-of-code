import operator
from functools import reduce
from typing import Callable, Generator, Generic, Iterable, Iterator, Self, TypeVar

T = TypeVar("T")
OT = TypeVar("OT")


class Grid(Generic[T]):
    """
    N-dimensional regular grid
    """

    def __init__(self, dims: tuple[int, ...], values: Iterable[T]) -> None:
        expected_len = reduce(operator.mul, dims)
        assert all(dim > 0 for dim in dims)
        self.dims = dims
        self.values = list(values)
        assert len(self.values) == expected_len

    def __len__(self) -> int:
        return len(self.values)

    def __getitem__(self, index: tuple[int, ...] | int) -> T:
        if isinstance(index, tuple):
            index = self.linear_index(index)
        return self.values[index]

    def __setitem__(self, index: tuple[int, ...] | int, value: T) -> None:
        if isinstance(index, tuple):
            index = self.linear_index(index)
        self.values[index] = value

    def __iter__(self) -> Iterator[T]:
        return iter(self.values)

    def direct_neighbor_indexes(
        self, index: tuple[int, ...]
    ) -> Generator[tuple[int, ...], None, None]:
        """Get neighbors whose dimensional index is off by one at most."""
        mutable_index = list(index)
        for i, dim in enumerate(self.dims):
            mutable_index[i] -= 1
            if mutable_index[i] >= 0 and mutable_index[i] < dim:
                yield tuple(mutable_index)
            mutable_index[i] += 2
            if mutable_index[i] >= 0 and mutable_index[i] < dim:
                yield tuple(mutable_index)
            mutable_index[i] -= 1

    def linear_index(self, index: tuple[int, ...]) -> int:
        assert len(index) == len(self.dims) and all(idx < dim for idx, dim in zip(index, self.dims))
        result = 0
        size = 1
        for idx, dim in zip(index, self.dims):
            if idx < 0:
                idx += dim
            result += size * idx
            size *= dim
        return result

    def dimensional_index(self, index: int) -> tuple[int, ...]:
        if index < 0:
            index += len(self)
        assert index < len(self)
        result = []
        size = 1
        for dim in self.dims:
            size *= dim
            result.append(index % size)
            index //= size
        return tuple(result)

    def includes_index(self, index: tuple[int, ...]) -> bool:
        return all(idx >= 0 and idx <= self.dims[i] for i, idx in enumerate(index))
