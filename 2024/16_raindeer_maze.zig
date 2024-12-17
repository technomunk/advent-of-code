const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();

    const Node = struct {
        pos: geom.Index2,
        dir: geom.Dir2,
    };

    const Prev = struct {
        len: usize = 0,
        vals: [4]Node = undefined,

        pub fn append(self: *Prev, prev: Node) void {
            self.vals[self.len] = prev;
            self.len += 1;
        }
        pub fn set(self: *Prev, prev: Node) void {
            self.vals[0] = prev;
            self.len = 1;
        }

        pub fn asSlice(self: *Prev) []Node {
            return self.vals[0..self.len];
        }
    };

    maze: geom.DenseGrid(u8),
    costs: std.AutoHashMap(Node, usize),
    prev: std.AutoHashMap(Node, Prev),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .maze = geom.DenseGrid(u8).init(allocator),
            .costs = std.AutoHashMap(Node, usize).init(allocator),
            .prev = std.AutoHashMap(Node, Prev).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.maze.deinit();
        self.costs.deinit();
        self.prev.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        self.maze.width = line.len;
        try self.maze.appendRow(line);
    }

    pub fn finalizeInput(self: *Self) !void {
        try self.dijkstra(self.maze.coordOf('S').?);
    }

    pub fn solveP1(self: *Self) usize {
        const to = self.maze.coordOf('E').?;
        return self.minCost(to);
    }
    pub fn solveP2(self: *Self) usize {
        var tiles = self.calcTilesOnOptimalPath() catch @panic("OOM");
        defer tiles.deinit();
        return @intCast(tiles.count());
    }

    fn dijkstra(self: *Self, from: geom.Index2) !void {
        const PrioCtx = struct {
            costs: *@TypeOf(self.costs),

            pub fn cmp(ctx: @This(), a: Node, b: Node) std.math.Order {
                const aCost = ctx.costs.get(a) orelse std.math.maxInt(usize);
                const bCost = ctx.costs.get(b) orelse std.math.maxInt(usize);
                return std.math.order(aCost, bCost);
            }
        };
        var pq = std.PriorityQueue(Node, PrioCtx, PrioCtx.cmp).init(self.costs.allocator, .{ .costs = &self.costs });
        defer pq.deinit();

        const fromNode = Node{ .pos = from, .dir = .Right };
        try self.costs.put(fromNode, 0);
        try pq.add(fromNode);

        while (pq.removeOrNull()) |node| {
            for (self.maze.cardinalNeighbors(node.pos)) |n| {
                if (self.maze.getCpy(n) == '#')
                    continue;

                const nNode = Node{ .pos = n, .dir = node.pos.dirTo(n) };
                const newCost = self.costs.get(node).? + calcCost(node.pos, n, node.dir);
                const oldCost = self.costs.get(nNode) orelse std.math.maxInt(usize);
                if (newCost < oldCost) {
                    try pq.add(nNode);
                    try self.costs.put(nNode, newCost);
                }
                if (newCost <= oldCost) {
                    var entry = try self.prev.getOrPut(nNode);
                    if (newCost == oldCost) {
                        entry.value_ptr.append(node);
                    } else {
                        entry.value_ptr.set(node);
                    }
                }
            }
        }
    }

    fn calcTilesOnOptimalPath(self: *Self) !util.Set(geom.Index2) {
        var stack = std.ArrayList(Node).init(self.costs.allocator);
        defer stack.deinit();

        var minDir: geom.Dir2 = .Right;
        var minDirCost: usize = std.math.maxInt(usize);
        const toPos = self.maze.coordOf('E').?;
        for (geom.Dir2.ALL) |dir| {
            if (self.costs.get(.{ .pos = toPos, .dir = dir })) |cost| {
                if (cost < minDirCost) {
                    minDirCost = cost;
                    minDir = dir;
                }
            }
        }

        var tiles = util.Set(geom.Index2).init(self.costs.allocator);

        try stack.append(.{ .pos = toPos, .dir = minDir });
        while (stack.popOrNull()) |n| {
            try tiles.add(n.pos);
            if (self.prev.getPtr(n)) |prev| {
                for (prev.asSlice()) |p| {
                    try stack.append(p);
                }
            }
        }

        return tiles;
    }

    fn calcCost(a: geom.Index2, b: geom.Index2, dir: geom.Dir2) usize {
        const bDir = a.dirTo(b);
        return 1000 * @as(usize, @intCast(dir.turnsTo(bDir))) + 1;
    }

    fn minCost(self: *const Self, pos: geom.Index2) usize {
        var result: usize = std.math.maxInt(usize);
        for (geom.Dir2.ALL) |dir| {
            if (self.costs.get(.{ .pos = pos, .dir = dir })) |cost| {
                result = @min(result, cost);
            }
        }
        return result;
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
