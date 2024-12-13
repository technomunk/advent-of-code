const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

fn Solution(comptime T: type) type {
    const Pt2 = geom.Point2(T);
    const Machine = struct {
        a: Pt2,
        b: Pt2,
        prize: Pt2,

        pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            try writer.print("M{{ A: {[a]}, B: {[b]}, Prize: {[prize]} }}", self);
        }
    };
    const MachineParser = struct {
        const Self = @This();
        const ParseState = enum { A, B, Prize };
        state: ParseState = .A,

        a_delta: Pt2 = undefined,
        b_delta: Pt2 = undefined,

        fn parse(self: *Self, line: []const u8) !?Machine {
            if (line.len == 0) {
                return null;
            }
            switch (self.state) {
                .A => {
                    self.state = .B;
                    self.a_delta = try parseDelta(line);
                },
                .B => {
                    self.state = .Prize;
                    self.b_delta = try parseDelta(line);
                },
                .Prize => {
                    self.state = .A;
                    return Machine{
                        .a = self.a_delta,
                        .b = self.b_delta,
                        .prize = try parsePrize(line),
                    };
                },
            }
            return null;
        }

        fn parseDelta(line: []const u8) !Pt2 {
            const x_start = std.mem.indexOfScalar(u8, line, 'X').? + 1;
            const x_end = std.mem.indexOfScalar(u8, line, ',').?;
            const y_start = std.mem.indexOfScalar(u8, line, 'Y').? + 1;
            return Pt2{
                .x = try std.fmt.parseInt(T, line[x_start..x_end], 10),
                .y = try std.fmt.parseInt(T, line[y_start..], 10),
            };
        }
        fn parsePrize(line: []const u8) !Pt2 {
            const x_start = std.mem.indexOfScalar(u8, line, '=').? + 1;
            const x_end = std.mem.indexOfScalar(u8, line, ',').?;
            const y_start = std.mem.indexOfScalarPos(u8, line, x_end, '=').? + 1;
            return Pt2{
                .x = try std.fmt.parseInt(T, line[x_start..x_end], 10),
                .y = try std.fmt.parseInt(T, line[y_start..], 10),
            };
        }
    };
    return struct {
        const Self = @This();

        parser: MachineParser = .{},
        machines: std.ArrayList(Machine),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .machines = std.ArrayList(Machine).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.machines.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            if (try self.parser.parse(line)) |m| {
                try self.machines.append(m);
            }
        }

        pub fn solveP1(self: *Self) usize {
            var total: usize = 0;
            for (self.machines.items) |*m| {
                total += cheapestPath(m);
            }
            return total;
        }
        pub fn solveP2(self: *Self) usize {
            var total: usize = 0;
            for (self.machines.items) |*m| {
                m.prize.x += 10_000_000_000_000;
                m.prize.y += 10_000_000_000_000;
                total += cheapestPath(m);
            }
            return total;
        }

        fn cheapestPath(m: *const Machine) usize {
            // Solve system 2 of linear equations:
            // a*x1 + b*x2 = X (1)
            // a*y1 + b*y2 = Y (2)
            //
            // Solve (1) [a*x1 + b*x2 = X] for a:
            // a = (X - b*x2) / x1 (3)
            // Solve (2) [a*y1 + b*y2 = Y] for b:
            // b = (Y - a*y1) / y2 (4)
            //
            // Replace b in (3)[a = (X - b*x2) / x1] with rhs of (4) [b = (Y - a*y1) / y2]
            // a = (X - ((Y - a*y1) / y2)*x2) / x1
            // a*x1 = (X - ((Y - a*y1)*x2 / y2))
            // a*x1 = (X*y2 - x2*(Y-a*y1)) / y2
            // a*x1*y2 = X*y2 - x2*(Y-a*y1)
            // a*x1*y2 = X*y2 - Y*x2 - a*x2*y1
            // a*(x1*y2 - x2*y1) = X*y2 - Y*x2
            // a = (X*y2 - Y*x2) / (x1*y2-x2*y1)

            const a = @divTrunc(m.prize.x * m.b.y -% m.prize.y * m.b.x, m.a.x * m.b.y -% m.b.x * m.a.y);
            const b = @divTrunc(m.prize.y - a * m.a.y, m.b.y);

            if (!m.a.mult(a).add(m.b.mult(b)).eq(m.prize)) {
                return 0;
            }

            return @intCast(a * 3 + b);
        }

        fn gcd(a: T, b: T) T {
            return @intCast(std.math.gcd(@as(u64, @intCast(a)), @as(u64, @intCast(b))));
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(i64), 32);
}
