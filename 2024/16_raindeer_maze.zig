const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();

    maze: geom.DenseGrid(u8),
    costs: std.AutoHashMap(geom.Index2, usize),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .maze = geom.DenseGrid(u8).init(allocator),
            .costs = std.AutoHashMap(geom.Index2, usize).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.maze.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        self.maze.width = line.len;
        try self.maze.appendRow(line);
    }

    pub fn finalizeInput(self: *Self) !void {
        try self.gatherCosts(self.maze.coordOf('S').?);
    }

    pub fn solveP1(self: *Self) usize {
        const to = self.maze.coordOf('E').?;
        return self.costs.get(to).?;
    }
    pub fn solveP2(self: *Self) usize {
        var tiles = self.calcTilesOnOptimalPath() catch @panic("OOM");
        var tileIter = tiles.iterator();
        while (tileIter.next()) |n| {
            self.maze.set(n.*, 'O');
        }
        std.debug.print("{}\n", .{self.maze});
        return 0;
    }

    fn gatherCosts(self: *Self, from: geom.Index2) !void {
        const TempNode = struct {
            pos: geom.Index2,
            cost: usize,
            dir: geom.Dir2,
        };
        var stack = std.ArrayList(TempNode).init(self.maze.values.allocator);
        defer stack.deinit();

        try stack.append(.{
            .pos = from,
            .cost = 0,
            .dir = .Right,
        });

        try self.costs.put(from, 0);

        while (stack.popOrNull()) |node| {
            for (self.maze.cardinalNeighbors(node.pos)) |n| {
                if (self.maze.getCpy(n) == '#')
                    continue;

                const cost = node.cost + calcCost(node.pos, n, node.dir);
                const knownCost = self.costs.get(n) orelse std.math.maxInt(usize);
                if (cost < knownCost) {
                    try stack.append(.{ .pos = n, .cost = cost, .dir = node.pos.dirTo(n) });
                    try self.costs.put(n, cost);
                }
            }
        }
    }

    fn calcTilesOnOptimalPath(self: *const Self) !util.Set(geom.Index2) {
        const TempNode = struct {
            pos: geom.Index2,
            dir: geom.Dir2,
        };
        var stack = std.ArrayList(TempNode).init(self.maze.values.allocator);
        defer stack.deinit();
        var seen = util.Set(geom.Index2).init(stack.allocator);

        const to = self.maze.coordOf('E').?;
        try stack.append(.{ .pos = to, .dir = undefined });
        while (stack.popOrNull()) |node| {
            if (seen.has(node.pos))
                continue;

            try seen.add(node.pos);

            for (self.maze.cardinalNeighbors(node.pos)) |n| {
                if (self.maze.getCpy(n) == '#')
                    continue;

                const costStep: usize = if (node.pos.eq(to)) 1 else calcCost(node.pos, n, node.dir);
                const optimalCost = self.costs.get(node.pos).? - costStep;
                if (self.maze.getCpy(n) == 'x')
                    std.debug.print("{} cost {?}, optimal: {}\n", .{ n, self.costs.get(n), optimalCost });
                if (self.costs.get(n).? <= optimalCost) {
                    try stack.append(.{ .pos = n, .dir = node.pos.dirTo(n) });
                }
            }
        }

        return seen;
    }

    fn calcCost(a: geom.Index2, b: geom.Index2, dir: geom.Dir2) usize {
        const bDir = a.dirTo(b);
        return 1000 * @as(usize, @intCast(dir.turnsTo(bDir))) + 1;
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
