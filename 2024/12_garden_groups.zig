const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();

    const Region = struct {
        area: usize,
        perimeter: usize,
    };

    const Plot = struct {
        plant: u8,
        regionIdx: usize,
    };

    grid: geom.DenseGrid(Plot),
    regions: std.ArrayList(Region),
    nextRegion: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .grid = geom.DenseGrid(Plot).init(allocator),
            .regions = std.ArrayList(Region).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.grid.deinit();
        self.regions.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        if (self.grid.width < line.len) {
            self.grid.width = line.len;
        }

        const new = try self.grid.values.addManyAsSlice(line.len);
        for (line, new) |p, *c| {
            c.plant = p;
            c.regionIdx = self.nextRegion;
            self.nextRegion += 1;
        }
        self.grid.height += 1;
    }

    pub fn solveP1(self: *Self) usize {
        self.calcRegions() catch @panic("welp");

        var cost: usize = 0;
        for (self.regions.items) |r| {
            cost += r.area * r.perimeter;
        }
        return cost;
    }
    pub fn solveP2(self: *Self) usize {
        _ = self;
        return 0;
    }

    fn calcRegions(self: *Self) !void {
        var stack = std.ArrayList(geom.Index2).init(self.regions.allocator);
        defer stack.deinit();

        // Go through the grid, merging similar plots and remembering which ones have been updated
        var idxIter = self.grid.coordinateIterator();
        while (idxIter.next()) |idx| {
            var plot = self.grid.get(idx);
            for (self.grid.cardinalNeighbors(idx)) |nidx| {
                var neighbor = self.grid.get(nidx);
                if (plot.plant == neighbor.plant) {
                    if (plot.regionIdx < neighbor.regionIdx) {
                        neighbor.regionIdx = plot.regionIdx;
                        try stack.append(nidx);
                    } else {
                        plot.regionIdx = neighbor.regionIdx;
                        try stack.append(idx);
                    }
                }
            }
        }

        while (stack.popOrNull()) |idx| {
            var plot = self.grid.get(idx);
            for (self.grid.cardinalNeighbors(idx)) |nidx| {
                var neighbor = self.grid.get(nidx);
                if (plot.plant == neighbor.plant and plot.regionIdx != neighbor.regionIdx) {
                    if (plot.regionIdx < neighbor.regionIdx) {
                        neighbor.regionIdx = plot.regionIdx;
                        try stack.append(nidx);
                    } else {
                        plot.regionIdx = neighbor.regionIdx;
                        try stack.append(idx);
                    }
                }
            }
        }

        try self.collectRegions();
    }

    fn collectRegions(self: *Self) !void {
        var regionMap = std.AutoHashMap(usize, usize).init(self.regions.allocator);
        defer regionMap.deinit();

        var idxIter = self.grid.coordinateIterator();
        while (idxIter.next()) |idx| {
            const plot = self.grid.get(idx);
            const neighbors = self.grid.cardinalNeighbors(idx);
            var perimeter = 4 - neighbors.len;
            for (neighbors) |nidx| {
                const neighbor = self.grid.get(nidx);
                if (neighbor.plant != plot.plant) {
                    perimeter += 1;
                }
            }
            const rm = try regionMap.getOrPut(plot.regionIdx);
            if (!rm.found_existing) {
                rm.value_ptr.* = self.regions.items.len;
                try self.regions.append(.{ .area = 0, .perimeter = 0 });
            }
            var region = &self.regions.items[rm.value_ptr.*];
            region.area += 1;
            region.perimeter += perimeter;
        }
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
