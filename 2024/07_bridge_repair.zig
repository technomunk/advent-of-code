const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type, comptime rhs_len: usize) type {
    return struct {
        const Self = @This();

        const P1_OPS = .{ &mul, &add };
        const P2_OPS = .{ &mul, &add, &concat };

        p1: T,
        p2: T,

        pub fn init(_: std.mem.Allocator) Self {
            return Self{
                .p1 = 0,
                .p2 = 0,
            };
        }
        pub fn deinit(_: *Self) void {}

        pub fn processLine(self: *Self, line: []const u8) !void {
            var it = std.mem.splitSequence(u8, line, ": ");
            const lhs = try std.fmt.parseInt(T, it.next().?, 10);
            it = std.mem.splitSequence(u8, it.next().?, " ");
            var operands: T = 0;
            var rhs: [rhs_len]T = undefined;
            while (it.next()) |operand| {
                rhs[operands] = try std.fmt.parseInt(T, operand, 10);
                operands += 1;
            }

            if (canSolve(lhs, rhs[0..operands], &P1_OPS))
                self.p1 += lhs;
            if (canSolve(lhs, rhs[0..operands], &P2_OPS))
                self.p2 += lhs;
        }

        pub fn solveP1(self: *Self) !T {
            return self.p1;
        }
        pub fn solveP2(self: *Self) !T {
            return self.p2;
        }

        fn canSolve(lhs: T, rhs: []const T, comptime ops: []const *const fn (T, T) T) bool {
            // Reduce stack pressure of recursive calls by combining total and ops into 1 pointer
            const Equation = struct {
                total: T,

                fn canSolve(self: *const @This(), acc: T, rem: []const T) bool {
                    if (rem.len == 1) {
                        for (ops) |op| {
                            if (op(acc, rem[0]) == self.total) {
                                return true;
                            }
                        }
                        return false;
                    }
                    if (acc > self.total)
                        return false;

                    for (ops) |op| {
                        if (self.canSolve(op(acc, rem[0]), rem[1..]))
                            return true;
                    }
                    return false;
                }
            };

            const eq = Equation{ .total = lhs };
            return eq.canSolve(rhs[0], rhs[1..]);
        }

        fn mul(lhs: T, rhs: T) T {
            return lhs * rhs;
        }
        fn add(lhs: T, rhs: T) T {
            return lhs + rhs;
        }
        fn concat(lhs: T, rhs: T) T {
            return util.numconcat(T, lhs, rhs, 10);
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u64, 16), 128);
}
