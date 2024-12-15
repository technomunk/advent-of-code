const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();
    const Tile = enum {
        Empty,
        Robot,
        Box,
        Wall,

        pub fn format(self: Tile, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            const c: u8 = switch (self) {
                .Empty => '.',
                .Robot => '@',
                .Box => 'O',
                .Wall => '#',
            };
            try writer.print("{c}", .{c});
        }

        pub fn isMovable(self: Tile) bool {
            return self == .Robot or self == .Box;
        }
    };

    map: geom.DenseGrid(Tile),
    directions: std.ArrayList(geom.Dir2),
    inputIsDirections: bool = false,
    robot: geom.Index2 = undefined,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .map = geom.DenseGrid(Tile).init(allocator),
            .directions = std.ArrayList(geom.Dir2).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.map.deinit();
        self.directions.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        if (self.inputIsDirections) {
            try self.processDirections(line);
        } else if (line.len == 0) {
            self.inputIsDirections = true;
        } else {
            try self.processMap(line);
        }
    }

    pub fn finalizeInput(self: *Self) !void {
        self.robot = self.map.coordOf(.Robot).?;
    }

    fn processDirections(self: *Self, line: []const u8) !void {
        const new = try self.directions.addManyAsSlice(line.len);
        for (new, line) |*d, c| {
            d.* = switch (c) {
                '<' => .Left,
                '>' => .Right,
                '^' => .Up,
                'v' => .Down,
                else => @panic("Unknown direction"),
            };
        }
    }

    fn processMap(self: *Self, line: []const u8) !void {
        self.map.width = line.len;
        for (try self.map.addRow(), line) |*t, c| {
            t.* = switch (c) {
                '.' => .Empty,
                '@' => .Robot,
                'O' => .Box,
                '#' => .Wall,
                else => @panic("Unknown tile"),
            };
        }
    }

    pub fn solveP1(self: *Self) usize {
        for (self.directions.items) |d| {
            self.applyMove(d);
        }
        return self.sumBoxCoords();
    }

    pub fn solveP2(self: *Self) usize {
        _ = self;
        return 0;
    }

    fn applyMove(self: *Self, move: geom.Dir2) void {
        var cursor = self.robot;
        while (self.isInBounds(cursor) and self.map.getCpy(cursor).isMovable()) {
            cursor = cursor.shift(move);
        }
        if (self.map.getCpy(cursor) != .Empty)
            return;
        var last: Tile = .Empty;
        cursor = self.robot;
        while (true) {
            const tmp = self.map.getCpy(cursor);
            self.map.set(cursor, last);
            last = tmp;
            cursor = cursor.shift(move);
            if (last == .Empty)
                break;
        }
        self.robot = self.robot.shift(move);
    }

    fn sumBoxCoords(self: *Self) usize {
        var result: usize = 0;
        for (1..self.map.height - 1) |y| {
            for (1..self.map.width - 1) |x| {
                if (self.map.get(.{ .x = x, .y = y }).* == .Box) {
                    result += 100 * y + x;
                }
            }
        }
        return result;
    }

    fn isInBounds(self: *const Self, cursor: geom.Index2) bool {
        return cursor.x > 0 and cursor.x < self.map.width - 1 and cursor.y > 0 and cursor.y < self.map.height - 1;
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 1024);
}
