const std = @import("std");
const util = @import("util.zig");

const NodeId = [2]u8;
const Graph = struct {
    pub const Node = struct {
        neighbors: util.Set(NodeId),
    };

    edges: std.AutoHashMap(NodeId, Node),

    nodes: std.ArrayList(NodeId),

    pub fn init(allocator: std.mem.Allocator) Graph {
        return Graph{
            .edges = std.AutoHashMap(NodeId, Node).init(allocator),
            .nodes = std.ArrayList(NodeId).init(allocator),
        };
    }

    pub fn deinit(self: *Graph) void {
        var nodeIter = self.edges.valueIterator();
        while (nodeIter.next()) |node| {
            node.neighbors.deinit();
        }
        self.edges.deinit();
        self.nodes.deinit();
    }

    pub fn addNode(self: *Graph, id: NodeId) !void {
        try self.getOrAdd(id);
    }
    pub fn addEdge(self: *Graph, a: NodeId, b: NodeId) !void {
        _ = try self.getOrAdd(a);
        var bNode = try self.getOrAdd(b);
        var aNode = self.edges.getPtr(a).?;
        try aNode.neighbors.add(b);
        try bNode.neighbors.add(a);
    }

    pub fn findCliquesOfSize3(self: *const Graph) !std.ArrayList([3]NodeId) {
        var result = std.ArrayList([3]NodeId).init(self.edges.allocator);
        const nodes = self.nodes.items;

        for (0..nodes.len) |aidx| {
            for ((aidx + 1)..nodes.len) |bidx| {
                for ((bidx + 1)..nodes.len) |cidx| {
                    const clique: [3]NodeId = .{ nodes[aidx], nodes[bidx], nodes[cidx] };
                    if (self.isClique(&clique))
                        try result.append(clique);
                }
            }
        }

        return result;
    }

    fn getOrAdd(self: *Graph, id: NodeId) !*Node {
        const entry = try self.edges.getOrPut(id);
        if (!entry.found_existing) {
            entry.value_ptr.neighbors = util.Set(NodeId).init(self.edges.allocator);
            try self.nodes.append(id);
        }
        return entry.value_ptr;
    }

    fn isClique(self: *const Graph, clique: []const NodeId) bool {
        for (0..clique.len) |a| {
            const aNeighbors = self.edges.get(clique[a]).?.neighbors;
            for ((a + 1)..clique.len) |b| {
                if (!aNeighbors.has(clique[b]))
                    return false;
            }
        }
        return true;
    }
};

const Solution = struct {
    const Self = @This();

    graph: Graph,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .graph = Graph.init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.graph.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        try self.graph.addEdge(parseNode(line[0..2]), parseNode(line[3..5]));
    }

    pub fn solveP1(self: *Self) !usize {
        var result: usize = 0;
        var cliques = try self.graph.findCliquesOfSize3();
        defer cliques.deinit();

        for (cliques.items) |clique| {
            var startsWithT = false;
            for (clique) |nidx| {
                if (nidx[0] == 't') {
                    startsWithT = true;
                    break;
                }
            }
            result += @intFromBool(startsWithT);
        }

        return result;
    }
    pub fn solveP2(self: *Self) !usize {
        _ = self;
        return 0;
    }

    fn startsWith(char: u8) fn (NodeId) bool {
        return struct {
            pub fn inner(node: NodeId) bool {
                return node[0] == char;
            }
        }.inner;
    }

    fn parseNode(s: []const u8) NodeId {
        return .{ s[0], s[1] };
    }
};

pub fn main() !void {
    try util.execSolution(Solution, .{ .safe_allocator = false });
}
