const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Node = struct {
    const Class = enum {
        Start,
        Intersection,
        End,
    };
    pos: geom.Index2,
    class: Class,
};

const Graph = struct {
    const NodeId = usize;
    nodes: std.ArrayList(Node),
    // A => B => cost
    edges: std.AutoHashMap(NodeId, std.AutoHashMap(NodeId, usize)),

    pub fn init(allocator: std.mem.Allocator) Graph {
        return Graph{
            .nodes = std.ArrayList(Node).init(allocator),
            .edges = std.AutoHashMap(NodeId, std.AutoHashMap(NodeId, usize)).init(allocator),
        };
    }
    pub fn deinit(self: *Graph) void {
        self.nodes.deinit();
        var edgeIter = self.edges.valueIterator();
        while (edgeIter.next()) |e| {
            e.deinit();
        }
        self.edges.deinit();
    }

    pub fn addNode(self: *Graph, node: Node) !NodeId {
        const id = self.nodes.items.len;
        try self.nodes.append(node);
        return id;
    }
    pub fn addEdge(self: *Graph, a: NodeId, b: NodeId, dist: usize) !void {
        const entry = try self.edges.getOrPut(a);
        if (!entry.found_existing) {
            entry.value_ptr.* = std.AutoHashMap(NodeId, usize).init(self.edges.allocator);
        }
        try entry.value_ptr.put(b, dist);
    }

    pub fn getNeighbors(self: *Graph, node: NodeId) ?[*]NodeId {
        if (self.edges.get(node)) |edgeMap| {
            return edgeMap.keyIterator().items;
        }
        return null;
    }
};

const Solution = struct {
    const Self = @This();

    maze: geom.DenseGrid(u8),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .maze = geom.DenseGrid(u8).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.maze.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        self.maze.width = line.len;
        try self.maze.appendRow(line);
    }

    pub fn solveP1(self: *Self) usize {
        return self.dfs(self.maze.coordOf('S').?, self.maze.coordOf('E').?) catch @panic("OOM");
    }
    pub fn solveP2(self: *Self) usize {
        _ = self;
        return 0;
    }

    fn dfs(self: *Self, from: geom.Index2, to: geom.Index2) !usize {
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

        var costs = std.AutoHashMap(geom.Index2, usize).init(self.maze.values.allocator);
        defer costs.deinit();

        try costs.put(from, 0);

        while (stack.popOrNull()) |node| {
            for (self.maze.cardinalNeighbors(node.pos)) |n| {
                if (self.maze.getCpy(n) == '#')
                    continue;

                const cost = node.cost + calcCost(node.pos, n, node.dir);
                const knownCost = costs.get(n) orelse std.math.maxInt(usize) - cost;
                if (cost < knownCost) {
                    try stack.append(.{ .pos = n, .cost = cost, .dir = node.pos.dirTo(n) });
                    try costs.put(n, cost);
                    // try last.put(n, node.pos);
                }
            }
        }

        return costs.get(to).?;
    }

    fn calcCost(a: geom.Index2, b: geom.Index2, dir: geom.Dir2) usize {
        const bDir = a.dirTo(b);
        return 1000 * @as(usize, @intCast(dir.turnsTo(bDir))) + 1;
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
