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

        pub fn clone(self: *Self) !Self {
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

        pub fn get(self: *Self, x: usize, y: usize) T {
            return self.values.items[x + y * self.width];
        }
        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.values.items[x + y * self.width] = value;
        }

        pub fn getRow(self: *Self, y: usize) []T {
            const start = y * self.width;
            const end = start + self.width;
            return self.values.items[start..end];
        }

        pub fn count(self: *Self, value: T) usize {
            var result: usize = 0;
            for (self.values.items) |item| {
                if (item == value) {
                    result += 1;
                }
            }
            return result;
        }
        pub fn countAnyOf(self: *Self, values: []const T) usize {
            var result: usize = 0;
            for (self.values.items) |item| {
                if (util.contains(T, values, item)) {
                    result += 1;
                }
            }
            return result;
        }
    };
}
