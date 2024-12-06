const std = @import("std");
const util = @import("util.zig");

const Solution = struct {
    const Self = @This();
    const Cell = enum(u8) {
        empty = '.',
        obstacle = '#',
        newObstacle = 'O',
        up = '^',
        right = '>',
        down = 'v',
        left = '<',
    };
    const VISITED: [4]Cell = .{ Cell.up, Cell.right, Cell.down, Cell.left };

    grid: util.DenseGrid(Cell),
    guard_x: isize,
    guard_y: isize,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .grid = util.DenseGrid(Cell).init(allocator),
            .guard_x = 0,
            .guard_y = 0,
        };
    }
    pub fn deinit(self: *Self) void {
        self.grid.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        if (self.grid.width == 1) {
            self.grid.width = line.len;
        }

        for (line, 0..) |c, i| {
            switch (c) {
                '.' => try self.grid.append(Cell.empty),
                '#' => try self.grid.append(Cell.obstacle),
                '^' => {
                    try self.grid.append(Cell.empty);
                    self.guard_x = @intCast(i);
                    self.guard_y = @intCast(self.grid.height);
                },
                else => std.debug.print("Unknown char: '{c}'", .{c}),
            }
        }
        self.grid.height += 1;
    }

    pub fn solveP1(self: *Self) usize {
        var gx = self.guard_x;
        var gy = self.guard_y;
        var dx: isize = 0;
        var dy: isize = -1;

        var grid = self.grid.clone() catch @panic("Couldn't clone grid");
        defer grid.deinit();

        while (gx >= 0 and gx < self.grid.width and gy >= 0 and gy < self.grid.height) {
            grid.set(@intCast(gx), @intCast(gy), cell(dx, dy));
            const nx = gx + dx;
            const ny = gy + dy;
            if (nx < 0 or nx >= self.grid.width or ny < 0 or ny >= self.grid.height) {
                break;
            }

            switch (grid.get(@intCast(nx), @intCast(ny))) {
                Cell.obstacle => {
                    const old_dx = dx;
                    dx = -dy;
                    dy = old_dx;
                },
                else => {
                    gx = nx;
                    gy = ny;
                },
            }
        }

        return grid.countAnyOf(&VISITED);
    }
    pub fn solveP2(self: *Self) usize {
        var gx = self.guard_x;
        var gy = self.guard_y;
        var dx: isize = 0;
        var dy: isize = -1;

        var newObstacles: usize = 0;
        while (gx >= 0 and gx < self.grid.width and gy >= 0 and gy < self.grid.height) {
            if (self.grid.get(@intCast(gx), @intCast(gy)) != Cell.newObstacle) {
                self.grid.set(@intCast(gx), @intCast(gy), cell(dx, dy));
            }
            const nx = gx + dx;
            const ny = gy + dy;
            if (nx < 0 or nx >= self.grid.width or ny < 0 or ny >= self.grid.height) {
                break;
            }

            if (self.obstacleCreatesLoop(nx, ny, dx, dy)) {
                newObstacles += 1;
            }

            switch (self.grid.get(@intCast(nx), @intCast(ny))) {
                Cell.obstacle => {
                    const old_dx = dx;
                    dx = -dy;
                    dy = old_dx;
                },
                else => {
                    gx = nx;
                    gy = ny;
                },
            }
        }

        return newObstacles;
    }

    fn obstacleCreatesLoop(self: *Self, x: isize, y: isize, odx: isize, ody: isize) bool {
        if (self.grid.get(@intCast(x), @intCast(y)) != Cell.empty) {
            return false;
        }

        var dx = -ody;
        var dy = odx;
        var grid = self.grid.clone() catch @panic("No clone");
        defer grid.deinit();

        grid.set(@intCast(x), @intCast(y), Cell.newObstacle);
        var gx = x - odx;
        var gy = y - ody;

        var steps: usize = 0;
        while (gx >= 0 and gx < grid.width and gy >= 0 and gy < grid.height) {
            grid.set(@intCast(gx), @intCast(gy), cell(dx, dy));
            steps += 1;
            if (steps == 10_000) {
                return true;
            }

            const nx = gx + dx;
            const ny = gy + dy;
            if (nx < 0 or nx >= grid.width or ny < 0 or ny >= grid.height) {
                return false;
            }

            const nextCell = grid.get(@intCast(nx), @intCast(ny));
            if (nextCell == Cell.obstacle or nextCell == Cell.newObstacle) {
                const old_dx = dx;
                dx = -dy;
                dy = old_dx;
            } else if (nextCell == cell(dx, dy)) {
                return true;
            } else {
                gx = nx;
                gy = ny;
            }
        }
        return false;
    }

    fn printGrid(grid: *util.DenseGrid(Cell)) void {
        for (0..grid.height) |y| {
            for (grid.getRow(y)) |c| {
                std.debug.print("{c}", .{@intFromEnum(c)});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }

    fn cell(dx: isize, dy: isize) Cell {
        return switch (dx) {
            -1 => Cell.left,
            1 => Cell.right,
            else => switch (dy) {
                -1 => Cell.up,
                1 => Cell.down,
                else => @panic("Uknown direction"),
            },
        };
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
