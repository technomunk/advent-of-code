const std = @import("std");
const util = @import("util.zig");

pub const Dir2 = enum {
    Up,
    Right,
    Down,
    Left,

    pub fn rotateRight(self: Dir2) Dir2 {
        return switch (self) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
        };
    }
    pub fn rotateLeft(self: Dir2) Dir2 {
        return switch (self) {
            .Up => .Left,
            .Right => .Up,
            .Down => .Right,
            .Left => .Down,
        };
    }

    pub fn format(self: Dir2, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (std.mem.eql(u8, fmt, "c")) {
            const c: u8 = switch (self) {
                .Up => '^',
                .Right => '>',
                .Down => 'v',
                .Left => '<',
            };
            try writer.print("{c}", .{c});
            return;
        }
        const name: []const u8 = switch (self) {
            .Up => "Up",
            .Right => "Right",
            .Down => "Down",
            .Left => "Left",
        };
        try writer.print("Dir2.{s}\n", .{name});
    }

    pub fn turnsTo(self: Dir2, to: Dir2) u2 {
        if (self == to)
            return 0;
        if (self.rotateLeft() == to or self.rotateRight() == to)
            return 1;
        return 2;
    }
};

test "Dir2.turnsTo" {
    const a = Dir2.Left;
    try std.testing.expectEqual(0, a.turnsTo(Dir2.Left));
    try std.testing.expectEqual(1, a.turnsTo(Dir2.Up));
    try std.testing.expectEqual(1, a.turnsTo(Dir2.Down));
    try std.testing.expectEqual(2, a.turnsTo(Dir2.Right));
}

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
        pub fn mod(self: Self, o: Self) Self {
            return Self{ .x = @mod(self.x, o.x), .y = @mod(self.y, o.y) };
        }
        pub fn modn(self: Self, n: T) Self {
            return Self{ .x = @mod(self.x, n), .y = @mod(self.y, n) };
        }

        pub fn eq(self: Self, o: Self) bool {
            return self.x == o.x and self.y == o.y;
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

        pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            try writer.print("({[x]}, {[y]})", self);
        }

        pub fn asIndex2(self: Self) Index2 {
            return Index2{ .x = @intCast(self.x), .y = @intCast(self.y) };
        }
    };
}

pub const Index2 = struct {
    x: usize,
    y: usize,

    pub fn corner(center: Index2, a: Index2, b: Index2) Index2 {
        return .{
            .x = center.x +% a.x -% center.x +% b.x -% center.x,
            .y = center.y +% a.y -% center.y +% b.y -% center.y,
        };
    }

    pub fn shift(self: Index2, dir: Dir2) Index2 {
        return switch (dir) {
            .Up => Index2{ .x = self.x, .y = self.y - 1 },
            .Right => Index2{ .x = self.x + 1, .y = self.y },
            .Down => Index2{ .x = self.x, .y = self.y + 1 },
            .Left => Index2{ .x = self.x - 1, .y = self.y },
        };
    }

    pub fn dirTo(self: Index2, to: Index2) Dir2 {
        if (self.x == to.x) {
            return if (to.y < self.y) .Up else .Down;
        }
        return if (to.x < self.x) .Left else .Right;
    }

    pub fn eq(self: Index2, o: Index2) bool {
        return self.x == o.x and self.y == o.y;
    }
};

test "Index2.dirTo" {
    const pos = Index2{ .x = 1, .y = 1 };
    try std.testing.expectEqual(.Left, pos.dirTo(.{ .x = 0, .y = 1 }));
    try std.testing.expectEqual(.Right, pos.dirTo(.{ .x = 2, .y = 1 }));
    try std.testing.expectEqual(.Up, pos.dirTo(.{ .x = 1, .y = 0 }));
    try std.testing.expectEqual(.Down, pos.dirTo(.{ .x = 1, .y = 2 }));
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

        pub fn addRow(self: *Self) ![]T {
            const new = try self.values.addManyAsSlice(self.width);
            self.height += 1;
            return new;
        }

        pub fn includes(self: *Self, index: Index2) bool {
            return index.x < self.width and index.y < self.height;
        }

        pub fn get(self: *Self, index: Index2) *T {
            return &self.values.items[index.x + index.y * self.width];
        }
        pub fn getCpy(self: *const Self, index: Index2) T {
            return self.values.items[index.x + index.y * self.width];
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
            if (std.mem.indexOf(T, self.values.items, &needle)) |idx| {
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

        pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    try writer.print("{c}", .{self.getCpy(.{ .x = x, .y = y })});
                }
                try writer.writeAll("\n");
            }
        }
    };
}
