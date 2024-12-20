const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();

        map: geom.DenseGrid(T), // 4 bits is enough to represent the 10 possible heights
        stack: std.ArrayList(geom.Index2),
        seen: util.Set(geom.Index2),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .map = geom.DenseGrid(T).init(allocator),
                .stack = std.ArrayList(geom.Index2).init(allocator),
                .seen = util.Set(geom.Index2).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.map.deinit();
            self.stack.deinit();
            self.seen.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            self.map.width = line.len;
            var new = try self.map.values.addManyAsSlice(line.len);
            for (line, 0..) |c, i| {
                new[i] = @intCast(c - '0');
            }
            self.map.height += 1;
        }

        pub fn solveP1(self: *Self) !usize {
            var answer: usize = 0;
            for (self.map.values.items, 0..) |h, i| {
                if (h != 0)
                    continue;

                const x = i % self.map.width;
                const y = i / self.map.width;
                answer += try self.measureScore(x, y);
            }
            return answer;
        }
        pub fn solveP2(self: *Self) !usize {
            var answer: usize = 0;
            for (self.map.values.items, 0..) |h, i| {
                if (h != 0)
                    continue;

                const x = i % self.map.width;
                const y = i / self.map.width;
                answer += try self.measureRating(x, y);
            }
            return answer;
        }

        fn measureScore(self: *Self, x: usize, y: usize) !usize {
            // dfs
            var result: usize = 0;

            // note that the stack should be empty even after it has been used
            try self.stack.append(.{ .x = x, .y = y });
            var seen = util.Set(geom.Index2).init(self.stack.allocator);
            defer seen.deinit();

            var neighbors: [4]geom.Index2 = undefined;

            while (self.stack.popOrNull()) |coord| {
                if (seen.has(coord))
                    continue;

                try seen.add(coord);
                const h = self.map.getCpy(coord) + 1;
                if (h == 10) {
                    result += 1;
                    continue;
                }

                for (self.map.cardinalNeighbors(coord, &neighbors)) |n| {
                    if (self.map.getCpy(n) == h)
                        self.stack.append(n) catch @panic("OOM");
                }
            }

            return result;
        }
        fn measureRating(self: *Self, x: usize, y: usize) !usize {
            // dfs
            var result: usize = 0;
            var neighbors: [4]geom.Index2 = undefined;

            // note that the stack should be empty even after it has been used
            try self.stack.append(.{ .x = x, .y = y });

            while (self.stack.popOrNull()) |coord| {
                const h = self.map.getCpy(coord) + 1;
                if (h == 10) {
                    result += 1;
                    continue;
                }

                for (self.map.cardinalNeighbors(coord, &neighbors)) |n| {
                    if (self.map.getCpy(n) == h)
                        try self.stack.append(n);
                }
            }

            return result;
        }

        fn measureTrailhead(self: *Self, x: usize, y: usize, comptime isScore: bool) !usize {
            // dfs
            var result: usize = 0;

            // note that the stack should be empty even after it has been used
            try self.stack.append(.{ .x = x, .y = y });
            self.seen.clearRetainingCapacity();

            while (self.stack.popOrNull()) |coord| {
                if (self.seen.has(coord))
                    continue;

                const h = self.map.get(coord) + 1;
                if (h == 10) {
                    result += 1;
                    if (isScore)
                        try self.seen.add(coord);
                    continue;
                } else {
                    try self.seen.add(coord);
                }

                for (self.map.cardinalNeighbors(coord)) |n| {
                    if (self.map.get(n) == h)
                        try self.stack.append(n);
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
}

pub fn main() !void {
    try util.execSolution(Solution(u4), 64);
}
