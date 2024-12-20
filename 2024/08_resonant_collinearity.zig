const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");
const comb = @import("comb.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Pt2 = geom.Point2(T);
        const Self = @This();

        antennae: std.AutoHashMap(u8, std.ArrayList(Pt2)),
        size: Pt2,

        antinodes: util.Set(Pt2),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .antennae = std.AutoHashMap(u8, std.ArrayList(Pt2)).init(allocator),
                .size = Pt2{ .x = 0, .y = 0 },
                .antinodes = util.Set(Pt2).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            var it = self.antennae.valueIterator();
            while (it.next()) |arr| {
                arr.deinit();
            }
            self.antennae.deinit();
            self.antinodes.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            if (self.size.x < line.len)
                self.size.x = @intCast(line.len);

            for (line, 0..) |c, x| {
                if (c == '.')
                    continue;
                try self.addAntenna(c, Pt2{ .x = @intCast(x), .y = self.size.y });
            }
            self.size.y += 1;
        }

        pub fn solveP1(self: *Self) !usize {
            var it = self.antennae.iterator();
            while (it.next()) |entry| {
                try self.generateStrictAntinodes(entry.value_ptr.items);
            }
            return self.antinodes.count();
        }
        pub fn solveP2(self: *Self) !usize {
            var it = self.antennae.iterator();
            while (it.next()) |entry| {
                try self.generateHarmonicAntinodes(entry.value_ptr.items);
            }
            return self.antinodes.count();
        }

        fn addAntenna(self: *Self, freq: u8, pos: Pt2) !void {
            const entry = try self.antennae.getOrPut(freq);
            if (!entry.found_existing)
                entry.value_ptr.* = std.ArrayList(Pt2).init(self.antennae.allocator);
            try entry.value_ptr.append(pos);
        }

        fn generateStrictAntinodes(self: *Self, antennae: []Pt2) !void {
            var combs = comb.Combinations(Pt2).of(antennae);
            var node: Pt2 = undefined;
            while (combs.next()) |pair| {
                var diff = pair[0].sub(pair[1].*);
                node = pair[0].add(diff);
                if (node.isInside(Pt2.ZERO, self.size))
                    try self.antinodes.add(node);

                diff = pair[1].sub(pair[0].*);
                node = pair[1].add(diff);
                if (node.isInside(Pt2.ZERO, self.size))
                    try self.antinodes.add(node);
            }
        }

        fn generateHarmonicAntinodes(self: *Self, antennae: []Pt2) !void {
            var combs = comb.Combinations(Pt2).of(antennae);
            var node: Pt2 = undefined;
            while (combs.next()) |pair| {
                var diff = pair[0].sub(pair[1].*);
                node = pair[0].add(diff);
                while (node.isInside(Pt2.ZERO, self.size)) {
                    try self.antinodes.add(node);
                    node.addi(diff);
                }

                diff = pair[1].sub(pair[0].*);
                node = pair[1].add(diff);
                while (node.isInside(Pt2.ZERO, self.size)) {
                    try self.antinodes.add(node);
                    node.addi(diff);
                }
            }
            for (antennae) |a| {
                try self.antinodes.add(a);
            }
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(i32), 64);
}
