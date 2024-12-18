const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Cell = enum {
    empty,
    filled,
    pub fn format(self: Cell, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (fmt.len == 1 and fmt[0] == 'c') {
            const c: u8 = switch (self) {
                .empty => '.',
                .filled => '#',
            };
            return writer.print("{c}", .{c});
        }
        const name = switch (self) {
            .empty => "empty",
            .filled => "filled",
        };
        return writer.print("Cell.{s}", .{name});
    }
};
const PFCtx = struct {
    space: *const geom.DenseGrid(Cell),

    var coords: [4]geom.Index2 = undefined;
    pub fn getNeighbors(self: PFCtx, node: geom.Index2) []geom.Index2 {
        var foundNeighbors: usize = 0;
        for (self.space.cardinalNeighbors(node)) |n| {
            if (self.space.getCpy(n) == .empty) {
                coords[foundNeighbors] = n;
                foundNeighbors += 1;
            }
        }
        return coords[0..foundNeighbors];
    }
    pub fn heuristic(_: PFCtx, a: geom.Index2, b: geom.Index2) usize {
        return geom.Index2.hamiltonDist(a, b);
    }
    pub fn calcDist(_: PFCtx, _: geom.Index2, _: geom.Index2) usize {
        return 1;
    }
    pub fn eq(_: PFCtx, a: geom.Index2, b: geom.Index2) bool {
        return a.eq(b);
    }
};
const PathFinder = util.PathFinder(geom.Index2, PFCtx);

const Solution = struct {
    const Self = @This();
    const FROM = geom.Index2{ .x = 0, .y = 0 };
    const TO = geom.Index2{ .x = 70, .y = 70 };

    space: geom.DenseGrid(Cell),
    bytes: std.ArrayList(geom.Index2),
    pathfinder: PathFinder,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .space = geom.DenseGrid(Cell).init(allocator),
            .bytes = std.ArrayList(geom.Index2).init(allocator),
            .pathfinder = undefined,
        };
    }
    pub fn deinit(self: *Self) void {
        self.space.deinit();
        self.bytes.deinit();
        self.pathfinder.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        const commaPos = std.mem.indexOfScalar(u8, line, ',').?;
        const x = try std.fmt.parseInt(usize, line[0..commaPos], 10);
        const y = try std.fmt.parseInt(usize, line[commaPos + 1 ..], 10);
        try self.bytes.append(.{ .x = x, .y = y });
    }

    pub fn finalizeInput(self: *Self) !void {
        self.space.width = TO.x + 1;
        self.space.height = TO.y + 1;
        try self.space.fill(.empty);
        self.pathfinder = PathFinder.init(self.space.values.allocator, .{ .space = &self.space });
    }

    pub fn solveP1(self: *Self) !usize {
        for (self.bytes.items[0..1024]) |b| {
            self.space.set(b, .filled);
        }

        return try self.pathfinder.lowestPathScore(FROM, TO);
    }
    pub fn solveP2(self: *Self) geom.Index2 {
        for (self.bytes.items[1024..]) |b| {
            self.space.set(b, .filled);
            self.pathfinder.reset();
            self.pathfinder.pathfind(FROM, TO) catch |err| {
                switch (err) {
                    PathFinder.PathError.NoPathExists => return b,
                    else => @panic("Something went wrong"),
                }
            };
        }
        @panic("Path never blocked");
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 64);
}
