const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();

    map: geom.DenseGrid(u4), // 4 bits is enough to represent the 10 possible heights
    stack: std.ArrayList(geom.Index2),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .map = geom.DenseGrid(u4).init(allocator),
            .stack = std.ArrayList(geom.Index2).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.map.deinit();
        self.stack.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        if (line.len > self.map.width) {
            self.map.width = line.len;
        }
        var new = try self.map.values.addManyAsSlice(line.len);
        for (line, 0..) |c, i| {
            new[i] = @intCast(c - '0');
        }
        self.map.height += 1;
    }

    pub fn solveP1(self: *Self) usize {
        var answer: usize = 0;
        for (self.map.values.items, 0..) |h, i| {
            if (h != 0) {
                continue;
            }

            const x = i % self.map.width;
            const y = i / self.map.width;
            answer += self.trailheadScore(x, y);
        }
        return answer;
    }
    pub fn solveP2(self: *Self) usize {
        _ = self;
        return 0;
    }

    fn trailheadScore(self: *Self, x: usize, y: usize) usize {
        // dfs
        var result: usize = 0;

        // note that the stack should be empty even after it has been used
        self.stack.append(.{ .x = x, .y = y }) catch @panic("OOM");
        var seen = util.Set(geom.Index2).init(self.stack.allocator);
        defer seen.deinit();

        while (self.stack.popOrNull()) |coord| {
            if (seen.has(coord)) {
                continue;
            }

            seen.add(coord) catch @panic("OOM");
            const h = self.map.get(coord) + 1;
            if (h == 10) {
                result += 1;
                continue;
            }
            for (self.map.cardinalNeighbors(coord)) |n| {
                if (self.map.get(n) == h) {
                    self.stack.append(n) catch @panic("OOM");
                }
            }
        }

        return result;
    }

    fn printGrid(grid: *geom.DenseGrid(u4)) void {
        for (0..grid.height) |y| {
            for (grid.getRow(y)) |c| {
                std.debug.print("{c}", .{@as(u8, c) + '0'});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 64);
}
