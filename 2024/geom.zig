const std = @import("std");
const util = @import("util.zig");

pub const Dir2 = enum {
    Up,
    Right,
    Down,
    Left,

    pub fn rotateRight(self: Dir2) Dir2 {
        switch (self) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
        }
    }
    pub fn rotateLeft(self: Dir2) Dir2 {
        switch (self) {
            .Up => .Left,
            .Right => .Up,
            .Down => .Right,
            .Left => .Down,
        }
    }
};

pub fn Point2(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const ZERO: Self = Self{ .x = 0, .y = 0 };

        x: T,
        y: T,

        pub fn add(a: Self, b: Self) Self {
            return Self{ .x = a.x + b.x, .y = a.y + b.y };
        }
        pub fn addi(self: *Self, o: Self) void {
            self.x += o.x;
            self.y += o.y;
        }

        pub fn sub(lhs: Self, rhs: Self) Self {
            return Self{
                .x = lhs.x - rhs.x,
                .y = lhs.y - rhs.y,
            };
        }
        pub fn subi(self: *Self, o: Self) void {
            self.x -= o.x;
            self.y -= o.x;
        }

        pub fn mult(self: Self, m: T) Self {
            return Self{ .x = self.x * m, .y = self.y * m };
        }

        pub fn dir(dir_: Dir2) Self {
            return switch (dir_) {
                .Up => Self{ .x = 0, .y = 1 },
                .Right => Self{ .x = 1, .y = 0 },
                .Down => Self{ .x = 0, .y = -1 },
                .Left => Self{ .x = -1, .y = 0 },
            };
        }

        pub fn isInside(self: *Self, min: Self, max: Self) bool {
            return self.x >= min.x and self.y >= min.y and self.x < max.x and self.y < max.y;
        }
    };
}

pub const Index2 = struct {
    x: usize,
    y: usize,
};

pub fn DenseGrid(comptime T: type) type {
    return struct {
        const Self = @This();

        values: std.ArrayList(T),
        width: usize,
        height: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .values = std.ArrayList(T).init(allocator),
                .width = 1,
                .height = 0,
            };
        }
        pub fn deinit(self: *Self) void {
            self.values.deinit();
        }

        pub fn clone(self: *const Self) !Self {
            var values = std.ArrayList(T).init(self.values.allocator);
            try values.appendSlice(self.values.items);
            return Self{
                .values = values,
                .width = self.width,
                .height = self.height,
            };
        }

        pub fn append(self: *Self, item: T) !void {
            try self.values.append(item);
        }
        pub fn appendRow(self: *Self, row: []const T) !void {
            try self.values.appendSlice(row);
            self.height += 1;
        }

        pub fn get(self: *Self, index: Index2) *T {
            return &self.values.items[index.x + index.y * self.width];
        }
        pub fn set(self: *Self, index: Index2, value: T) void {
            self.values.items[index.x + index.y * self.width] = value;
        }

        const Index2Iterator = struct {
            i: usize,
            width: usize,
            height: usize,

            pub fn next(self: *Index2Iterator) ?Index2 {
                const y = self.i / self.width;
                if (y >= self.height) {
                    return null;
                }
                const x = self.i % self.width;
                self.i += 1;
                return .{ .x = x, .y = y };
            }
        };
        pub fn coordinateIterator(self: *const Self) Index2Iterator {
            return Index2Iterator{
                .i = 0,
                .height = self.height,
                .width = self.width,
            };
        }

        pub fn getRow(self: *Self, y: usize) []T {
            const start = y * self.width;
            const end = start + self.width;
            return self.values.items[start..end];
        }

        pub fn count(self: *const Self, value: T) usize {
            var result: usize = 0;
            for (self.values.items) |item| {
                if (item == value) {
                    result += 1;
                }
            }
            return result;
        }
        pub fn countAnyOf(self: *const Self, values: []const T) usize {
            var result: usize = 0;
            for (self.values.items) |item| {
                if (util.contains(T, values, item)) {
                    result += 1;
                }
            }
            return result;
        }

        pub fn coordOf(self: *const Self, value: T) ?Index2 {
            const needle: [1]T = .{value};
            if (std.mem.indexOf(T, self.values.items, needle)) |idx| {
                return .{ .x = idx % self.width, .y = idx / self.width };
            }
            return null;
        }

        var coords: [4]Index2 = undefined;
        pub fn cardinalNeighbors(self: *const Self, index: Index2) []Index2 {
            var len: usize = 0;
            if (index.x > 0) {
                coords[len] = .{ .x = index.x - 1, .y = index.y };
                len += 1;
            }
            if (index.x + 1 < self.width) {
                coords[len] = .{ .x = index.x + 1, .y = index.y };
                len += 1;
            }
            if (index.y > 0) {
                coords[len] = .{ .x = index.x, .y = index.y - 1 };
                len += 1;
            }
            if (index.y + 1 < self.height) {
                coords[len] = .{ .x = index.x, .y = index.y + 1 };
                len += 1;
            }
            return coords[0..len];
        }
    };
}
