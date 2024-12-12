const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Solution = struct {
    const Self = @This();

    const Region = struct {
        area: usize = 0,
        perimeter: usize = 0,
        sides: usize = 0,
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

    pub fn finalizeInput(self: *Self) !void {
        try self.calcRegions();
        self.countRegionSides();
    }

    pub fn solveP1(self: *Self) usize {
        var cost: usize = 0;
        for (self.regions.items) |r| {
            cost += r.area * r.perimeter;
        }
        return cost;
    }
    pub fn solveP2(self: *Self) usize {
        var cost: usize = 0;
        for (self.regions.items) |r| {
            cost += r.area * r.sides;
        }
        return cost;
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
            var plot = self.grid.get(idx);
            const neighbors = self.grid.cardinalNeighbors(idx);
            var perimeter = 4 - neighbors.len;
            var opposingNeighbors = false;
            var lastNeighbor: ?geom.Index2 = null;
            for (neighbors) |nidx| {
                const neighbor = self.grid.get(nidx);
                if (neighbor.plant != plot.plant) {
                    perimeter += 1;
                } else {
                    if (lastNeighbor) |ln| {
                        opposingNeighbors = ln.x == nidx.x or ln.y == nidx.y;
                    } else {
                        lastNeighbor = nidx;
                    }
                }
            }

            const rm = try regionMap.getOrPut(plot.regionIdx);
            if (!rm.found_existing) {
                rm.value_ptr.* = self.regions.items.len;
                try self.regions.append(.{});
            }
            plot.regionIdx = rm.value_ptr.*;
            var region = &self.regions.items[rm.value_ptr.*];
            region.area += 1;
            region.perimeter += perimeter;
        }
    }

    fn countRegionSides(self: *Self) void {
        var idxIter = self.grid.coordinateIterator();
        while (idxIter.next()) |idx| {
            const plot = self.grid.get(idx);
            const corners = self.countCorners(idx);
            self.regions.items[plot.regionIdx].sides += corners;
        }
    }

    fn countCorners(self: *Self, idx: geom.Index2) usize {
        // The easy cases are:
        // 000  0x0  000  0x0
        // 0x0  0x0  xxx  0x0(and 4 rotations)
        // 000  0x0  000  000
        // But we need to count corner neighbors for
        // ?x0  ?x?  ?x?
        // xx0  xxx  xxx
        // 000  ?x?  000

        const plot = self.grid.get(idx);
        var cardinalCount: usize = 0;

        var opposingNeighbors = false;

        var last_nidx: ?geom.Index2 = null;
        var corner_idx: ?geom.Index2 = null;
        for (self.grid.cardinalNeighbors(idx)) |nidx| {
            const n = self.grid.get(nidx);
            if (n.regionIdx != plot.regionIdx) {
                continue;
            }
            cardinalCount += 1;
            if (last_nidx) |lnidx| {
                opposingNeighbors = lnidx.x == nidx.x or lnidx.y == nidx.y;
                if (!opposingNeighbors) {
                    corner_idx = idx.corner(lnidx, nidx);
                }
            } else {
                last_nidx = nidx;
            }
        }

        switch (cardinalCount) {
            0 => return 4,
            1 => return 2,
            2 => if (opposingNeighbors) {
                return 0;
            } else {
                if (self.grid.get(corner_idx.?).regionIdx == plot.regionIdx) {
                    return 1;
                }
                return 2;
            },
            3 => return self.count3Corners(idx),
            4 => return self.count4Corners(idx),
            else => @panic("Impossible condition"),
        }
    }

    fn count3Corners(self: *Self, idx: geom.Index2) usize {
        var dy: usize = 0;
        var dx: usize = 0;
        var isVertical = false;
        const plot = self.grid.get(idx);

        for (self.grid.cardinalNeighbors(idx)) |nidx| {
            if (self.grid.get(nidx).regionIdx != plot.regionIdx) {
                continue;
            }
            if (nidx.x != idx.x) {
                if (dx == 0) {
                    if (nidx.x > idx.x) {
                        dx = 1;
                    } else {
                        dx = std.math.maxInt(usize);
                    }
                    continue;
                }
                isVertical = false;
            }
            if (nidx.y != idx.y) {
                if (dy == 0) {
                    if (nidx.y > idx.y) {
                        dy = 1;
                    } else {
                        dy = std.math.maxInt(usize);
                    }
                    continue;
                }
                isVertical = true;
            }
        }

        var corner_indices: [2]geom.Index2 = undefined;
        if (isVertical) {
            corner_indices[0] = geom.Index2{ .x = idx.x +% dx, .y = idx.y - 1 };
            corner_indices[1] = geom.Index2{ .x = idx.x +% dx, .y = idx.y + 1 };
        } else {
            corner_indices[0] = geom.Index2{ .x = idx.x - 1, .y = idx.y +% dy };
            corner_indices[1] = geom.Index2{ .x = idx.x + 1, .y = idx.y +% dy };
        }

        var count: usize = 0;
        for (corner_indices) |cidx| {
            count += @intFromBool(self.grid.get(cidx).regionIdx != plot.regionIdx);
        }
        return count;
    }

    fn count4Corners(self: *Self, idx: geom.Index2) usize {
        const plot = self.grid.get(idx);
        var count: usize = 0;
        const CORNER_INDICES: [4]geom.Index2 = .{
            .{ .x = idx.x -% 1, .y = idx.y -% 1 },
            .{ .x = idx.x -% 1, .y = idx.y + 1 },
            .{ .x = idx.x + 1, .y = idx.y -% 1 },
            .{ .x = idx.x + 1, .y = idx.y + 1 },
        };
        for (CORNER_INDICES) |cidx| {
            count += @intFromBool(self.grid.get(cidx).regionIdx != plot.regionIdx);
        }
        return count;
    }

    fn debugPrint(self: *Self) void {
        var idxToPlant = std.AutoHashMap(usize, u8).init(self.regions.allocator);
        defer idxToPlant.deinit();

        for (self.grid.values.items) |c| {
            const entry = idxToPlant.getOrPut(c.regionIdx) catch @panic("OOM");
            if (!entry.found_existing) {
                entry.value_ptr.* = c.plant;
            }
        }

        for (self.regions.items, 0..) |r, i| {
            const p: u8 = idxToPlant.get(i).?;
            std.debug.print("{c} {}*{} = {}\n", .{ p, r.area, r.sides, r.area * r.sides });
        }
    }

    fn debugPrintRegion(self: *Self, index: usize) void {
        for (0..self.grid.height) |y| {
            for (0..self.grid.width) |x| {
                var c: u8 = '.';
                const plot = self.grid.get(.{ .x = x, .y = y });
                if (plot.regionIdx == index) {
                    c = plot.plant;
                }
                std.debug.print("{c}", .{c});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
