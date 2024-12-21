const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Key = enum {
    up,
    a,
    left,
    down,
    right,

    pub fn pos(self: Key) geom.Index2 {
        return switch (self) {
            .up => .{ .x = 1, .y = 0 },
            .a => .{ .x = 2, .y = 0 },
            .left => .{ .x = 0, .y = 1 },
            .down => .{ .x = 1, .y = 1 },
            .right => .{ .x = 2, .y = 1 },
        };
    }

    pub fn format(self: Key, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{c}", .{self.char()});
    }

    pub fn char(self: Key) u8 {
        return switch (self) {
            .up => '^',
            .a => 'A',
            .left => '<',
            .down => 'v',
            .right => '>',
        };
    }

    pub fn print(keys: []const Key) void {
        for (keys) |k| {
            std.debug.print("{c}", .{k.char()});
        }
    }
};

fn getNumericPos(n: u8) geom.Index2 {
    return switch (n) {
        '0' => .{ .x = 1, .y = 3 },
        '1' => .{ .x = 0, .y = 2 },
        '2' => .{ .x = 1, .y = 2 },
        '3' => .{ .x = 2, .y = 2 },
        '4' => .{ .x = 0, .y = 1 },
        '5' => .{ .x = 1, .y = 1 },
        '6' => .{ .x = 2, .y = 1 },
        '7' => .{ .x = 0, .y = 0 },
        '8' => .{ .x = 1, .y = 0 },
        '9' => .{ .x = 2, .y = 0 },
        'A' => .{ .x = 2, .y = 3 },
        else => std.debug.panic("Unknown numeric key: {}", .{n}),
    };
}

const Solution = struct {
    const Self = @This();

    seq: std.ArrayList(Key),

    p1: usize = 0,
    p2: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .seq = std.ArrayList(Key).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.seq.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        try self.seq.ensureTotalCapacity(256);
        self.seq.clearRetainingCapacity();
        var keys = try self.navNumeric(line); // numeric -> directional 1
        std.debug.print("{s} =>", .{line});
        Key.print(keys);
        keys = try self.navDirectional(keys); // directional 1 -> directional 2  // one extra key here
        std.debug.print(" => ", .{});
        Key.print(keys);
        keys = try self.navDirectional(keys); // directional 2 -> manual
        std.debug.print(" => ", .{});
        Key.print(keys);
        std.debug.print("\n", .{});
        const cmplx = try calcComplexity(line, keys);
        std.debug.print("{s}: {}\n", .{ line, cmplx });
        self.p1 += cmplx;
    }

    pub fn solveP1(self: *Self) !usize {
        return self.p1;
    }
    pub fn solveP2(self: *Self) !usize {
        return self.p2;
    }

    fn navNumeric(self: *Self, combination: []const u8) ![]const Key {
        const seqStart = self.seq.items.len;

        var pos = geom.Index2{ .x = 2, .y = 3 };
        for (combination) |c| {
            // To get the shortest path we should move as left first (if possible)
            // then down
            // then up or right
            const cPos = getNumericPos(c);
            while (!pos.eq(cPos)) {
                if (pos.x > cPos.x and (pos.x > 1 or pos.y < 3)) {
                    try self.seq.append(.left);
                    pos.x -= 1;
                    continue;
                }
                if (pos.y < cPos.y) {
                    try self.seq.append(.down);
                    pos.y += 1;
                    continue;
                }
                if (pos.x < cPos.x) {
                    try self.seq.append(.right);
                    pos.x += 1;
                    continue;
                }
                if (pos.y > cPos.y) {
                    try self.seq.append(.up);
                    pos.y -= 1;
                    continue;
                }
            }
            try self.seq.append(.a);
        }
        return self.seq.items[seqStart..];
    }

    fn navDirectional(self: *Self, combination: []const Key) ![]const Key {
        const seqStart = self.seq.items.len;

        var pos = geom.Index2{ .x = 2, .y = 0 };
        for (combination) |c| {
            const cPos = c.pos();
            while (!pos.eq(cPos)) {
                if (pos.x > cPos.x and (pos.x > 1 or pos.y > 0)) {
                    try self.seq.append(.left);
                    pos.x -= 1;
                    continue;
                }
                if (pos.y < cPos.y) {
                    try self.seq.append(.down);
                    pos.y += 1;
                    continue;
                }
                if (pos.x < cPos.x) {
                    try self.seq.append(.right);
                    pos.x += 1;
                    continue;
                }
                if (pos.y > cPos.y) {
                    try self.seq.append(.up);
                    pos.y -= 1;
                    continue;
                }
            }
            try self.seq.append(.a);
        }
        return self.seq.items[seqStart..];
    }

    fn calcComplexity(line: []const u8, keys: []const Key) !usize {
        _ = line;
        return keys.len;
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 64);
}
