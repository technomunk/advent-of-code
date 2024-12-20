const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();

    track: geom.DenseGrid(u8),
    dists: std.AutoHashMap(geom.Index2, usize),
    cheats: std.AutoHashMap(usize, usize),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .track = geom.DenseGrid(u8).init(allocator),
            .dists = std.AutoHashMap(geom.Index2, usize).init(allocator),
            .cheats = std.AutoHashMap(usize, usize).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.track.deinit();
        self.dists.deinit();
        self.cheats.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        self.track.width = line.len;
        try self.track.appendRow(line);
    }

    pub fn finalizeInput(self: *Self) !void {
        try self.findPath();
    }

    pub fn solveP1(self: *Self) !usize {
        try self.findCheats(2);
        var count: usize = 0;
        var cheatIter = self.cheats.iterator();
        const print = try self.cheats.allocator.alloc([2]usize, self.cheats.count());
        defer self.cheats.allocator.free(print);

        var printLen: usize = 0;
        while (cheatIter.next()) |entry| {
            if (entry.key_ptr.* >= 100)
                count += entry.value_ptr.*;
            print[printLen] = .{ entry.value_ptr.*, entry.key_ptr.* };
            printLen += 1;
        }

        std.mem.sort([2]usize, print, {}, lt);

        for (print) |cheat| {
            std.debug.print("{} cheats that save {} picoseconds\n", .{ cheat[0], cheat[1] });
        }
        std.debug.print("\n", .{});
        return count;
    }
    pub fn solveP2(self: *Self) !usize {
        try self.findCheats(20);
        var count: usize = 0;
        var cheatIter = self.cheats.iterator();
        const print = try self.cheats.allocator.alloc([2]usize, self.cheats.count());
        defer self.cheats.allocator.free(print);

        var printLen: usize = 0;
        while (cheatIter.next()) |entry| {
            if (entry.key_ptr.* >= 100)
                count += entry.value_ptr.*;
            if (entry.key_ptr.* >= 50) {
                print[printLen] = .{ entry.value_ptr.*, entry.key_ptr.* };
                printLen += 1;
            }
        }

        std.mem.sort([2]usize, print, {}, lt);

        for (print[0..printLen]) |cheat| {
            std.debug.print("{} cheats that save {} picoseconds\n", .{ cheat[0], cheat[1] });
        }

        return count;
    }

    fn findPath(self: *Self) !void {
        // Assume linear path and skip the stack
        var neighbors: [4]geom.Index2 = undefined;
        var node = self.track.coordOf('E').?;
        var dist: usize = 0;
        while (self.track.getCpy(node) != 'S') {
            try self.dists.put(node, dist);
            dist += 1;
            for (self.track.cardinalNeighbors(node, &neighbors)) |n| {
                if (self.track.getCpy(n) == '#' or self.dists.get(n) != null)
                    continue;
                node = n;
            }
        }
        try self.dists.put(node, dist);
    }

    fn findCheats(self: *Self, maxSteps: usize) !void {
        self.cheats.clearRetainingCapacity();
        var distIter = self.dists.iterator();
        while (distIter.next()) |entry| {
            try self.findCheatsOriginatingAt(entry.key_ptr.*, maxSteps);
        }
    }

    fn findCheatsOriginatingAt(self: *Self, pos: geom.Index2, maxSteps: usize) !void {
        const MIN_SAVE: usize = 0;

        const originalDist = self.dists.get(pos).?;
        const optimizedMaxSteps = @min(maxSteps, originalDist);
        const min_x = pos.x - @min(pos.x, optimizedMaxSteps);
        const min_y = pos.y - @min(pos.y, optimizedMaxSteps);
        const max_x = @min(self.track.width, pos.x + optimizedMaxSteps + 1);
        const max_y = @min(self.track.height, pos.y + optimizedMaxSteps + 1);

        for (min_y..max_y) |y| {
            for (min_x..max_x) |x| {
                const end = geom.Index2{ .x = x, .y = y };
                if (self.dists.get(end)) |dist| {
                    const steps = pos.hamiltonDist(end);
                    if (dist + steps >= originalDist)
                        continue;
                    const saved = originalDist - (dist + steps);
                    if (saved < MIN_SAVE)
                        continue;
                    const prev = self.cheats.get(saved).?;
                    try self.cheats.put(saved, prev + 1);
                }
            }
        }
    }
};

fn lt(_: void, a: [2]usize, b: [2]usize) bool {
    return a[1] < b[1];
}

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
