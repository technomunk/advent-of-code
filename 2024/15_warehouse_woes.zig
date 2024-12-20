const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Neighbor = enum { Left, Right };
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

    pub fn getNeighbor(_: Tile) ?geom.Dir2 {
        return null;
    }

    pub fn hasGps(self: Tile) bool {
        return self == .Box;
    }
};
const WideTile = enum {
    Empty,
    Robot,
    BoxL,
    BoxR,
    Wall,

    pub fn format(self: WideTile, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        const c: u8 = switch (self) {
            .Empty => '.',
            .Robot => '@',
            .BoxL => '[',
            .BoxR => ']',
            .Wall => '#',
        };
        try writer.print("{c}", .{c});
    }

    pub fn isMovable(self: WideTile) bool {
        return self == .Robot or self == .BoxL or self == .BoxR;
    }

    pub fn getNeighbor(self: WideTile) ?geom.Dir2 {
        return switch (self) {
            .BoxL => .Right,
            .BoxR => .Left,
            else => null,
        };
    }

    pub fn hasGps(self: WideTile) bool {
        return self == .BoxL;
    }
};

fn Map(comptime T: type) type {
    return struct {
        const Self = @This();
        map: geom.DenseGrid(T),
        robot: geom.Index2,

        pub fn create(map: geom.DenseGrid(T)) Self {
            return Self{
                .map = map,
                .robot = map.coordOf(.Robot).?,
            };
        }

        pub fn applyMove(self: *Self, dir: geom.Dir2) void {
            if (!self.canMove(self.robot, dir))
                return;
            self.move(self.robot, dir);
            self.robot = self.robot.shift(dir);
        }

        pub fn sumBoxCoords(self: *const Self) usize {
            var result: usize = 0;
            for (1..self.map.height - 1) |y| {
                for (1..self.map.width - 1) |x| {
                    if (self.map.getCpy(.{ .x = x, .y = y }).hasGps()) {
                        result += 100 * y + x;
                    }
                }
            }
            return result;
        }

        fn canMove(self: *const Self, cursor: geom.Index2, dir: geom.Dir2) bool {
            if (cursor.x == 0 or cursor.y == 0 or cursor.x >= self.map.width - 1 or cursor.y >= self.map.height - 1) {
                return false;
            }

            const next = cursor.shift(dir);
            const nextTile = self.map.getCpy(next);
            if (nextTile == .Empty)
                return true;
            if (!nextTile.isMovable())
                return false;
            if (!self.canMove(next, dir))
                return false;
            // No need for neighbor checks with horizontal moves
            if (dir == .Left or dir == .Right) {
                return true;
            }
            if (nextTile.getNeighbor()) |n| {
                return self.canMove(next.shift(n), dir);
            }
            return true;
        }

        fn move(self: *Self, cursor: geom.Index2, dir: geom.Dir2) void {
            const next = cursor.shift(dir);
            const nextTile = self.map.get(next);
            if (nextTile.isMovable()) {
                if (dir == .Up or dir == .Down) {
                    if (nextTile.getNeighbor()) |n| {
                        self.move(next.shift(n), dir);
                    }
                }
                self.move(next, dir);
            }
            nextTile.* = self.map.getCpy(cursor);
            self.map.set(cursor, .Empty);
        }
    };
}

const Solution = struct {
    const Self = @This();

    map: geom.DenseGrid(Tile),
    directions: std.ArrayList(geom.Dir2),
    inputIsDirections: bool = false,

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

    pub fn solveP1(self: *Self) !usize {
        var copy = try self.map.clone();
        defer copy.deinit();
        var map = Map(Tile).create(copy);
        for (self.directions.items) |d| {
            map.applyMove(d);
        }
        return map.sumBoxCoords();
    }

    pub fn solveP2(self: *Self) !usize {
        var copy = try widen(self.map);
        defer copy.deinit();
        var map = Map(WideTile).create(copy);
        for (self.directions.items) |d| {
            map.applyMove(d);
        }
        return map.sumBoxCoords();
    }

    fn widen(map: geom.DenseGrid(Tile)) !geom.DenseGrid(WideTile) {
        var result = geom.DenseGrid(WideTile).init(map.values.allocator);
        result.width = map.width * 2;
        result.height = map.height;
        const new = try result.values.addManyAsSlice(result.width * result.height);
        for (map.values.items, 0..) |t, i| {
            const l, const r = flatten(t);
            new[i * 2 + 0] = l;
            new[i * 2 + 1] = r;
        }
        return result;
    }

    fn flatten(tile: Tile) [2]WideTile {
        return switch (tile) {
            .Empty => .{ .Empty, .Empty },
            .Robot => .{ .Robot, .Empty },
            .Box => .{ .BoxL, .BoxR },
            .Wall => .{ .Wall, .Wall },
        };
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 1024);
}
