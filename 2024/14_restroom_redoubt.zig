const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

pub fn Solution(comptime T: type) type {
    const Pt2 = geom.Point2(T);
    const Robot = struct {
        pos: Pt2,
        vel: Pt2,

        fn parse(line: []const u8) !@This() {
            const pos_start = std.mem.indexOfScalar(u8, line, '=').? + 1;
            const pos_end = std.mem.indexOfScalar(u8, line, ' ').?;
            const px, const py = try parsePair(line[pos_start..pos_end]);
            const vel_start = std.mem.indexOfScalarPos(u8, line, pos_end, '=').? + 1;
            const vx, const vy = try parsePair(line[vel_start..]);
            return .{
                .pos = Pt2{ .x = px, .y = py },
                .vel = Pt2{ .x = vx, .y = vy },
            };
        }

        fn parsePair(segment: []const u8) !struct { T, T } {
            const sep = std.mem.indexOfScalar(u8, segment, ',').?;
            const a = try std.fmt.parseInt(T, segment[0..sep], 10);
            const b = try std.fmt.parseInt(T, segment[sep + 1 ..], 10);
            return .{ a, b };
        }
    };

    return struct {
        const Self = @This();

        robots: std.ArrayList(Robot),
        grid: geom.DenseGrid(u8),

        pub fn init(allocator: std.mem.Allocator) Self {
            var grid = geom.DenseGrid(u8).init(allocator);
            grid.width = 101;
            grid.height = 103;
            const new = grid.values.addManyAsSlice(101 * 103) catch @panic("OOM");
            for (new) |*c| {
                c.* = 0;
            }
            return Self{
                .robots = std.ArrayList(Robot).init(allocator),
                .grid = grid,
            };
        }
        pub fn deinit(self: *Self) void {
            self.robots.deinit();
            self.grid.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            try self.robots.append(try Robot.parse(line));
        }

        pub fn solveP1(self: *Self) usize {
            var quadrants: [4]usize = .{ 0, 0, 0, 0 };
            for (self.robots.items) |r| {
                const pos = step(r, 100);
                if (quadrant(pos)) |q| {
                    quadrants[q] += 1;
                }
            }
            var result = quadrants[0];
            for (quadrants[1..]) |q| {
                result *= q;
            }
            return result;
        }
        pub fn solveP2(self: *Self) usize {
            var steps: usize = 0;
            while (true) {
                for (self.robots.items) |*r| {
                    r.pos = step(r.*, 1);
                }
                steps += 1;
                std.debug.print("After {} steps:\n", .{steps});
                self.printBots();
            }
        }

        fn quadrant(pos: Pt2) ?usize {
            if (pos.x == 50 or pos.y == 51) {
                return null;
            }
            const left = pos.x < 50;
            const top = pos.y < 51;
            return @as(usize, @intFromBool(left)) + 2 * @as(usize, @intFromBool(top));
        }

        fn step(r: Robot, n: T) Pt2 {
            return r.pos.add(r.vel.mult(n)).mod(.{ .x = 101, .y = 103 });
        }

        fn printBots(self: *Self) void {
            for (self.grid.values.items) |*c| {
                c.* = 0;
            }

            for (self.robots.items) |r| {
                self.grid.set(r.pos.asIndex2(), self.grid.get(r.pos.asIndex2()).* + 1);
            }

            for (0..self.grid.height) |y| {
                for (self.grid.getRow(y)) |c| {
                    const char: u8 = if (c == 0) '.' else if (c >= 10) 'x' else '0' + c;
                    std.debug.print("{c}", .{char});
                }
                std.debug.print("\n", .{});
            }
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(i32), 64);
}
