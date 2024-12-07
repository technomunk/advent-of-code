const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type, comptime rhs_len: usize) type {
    return struct {
        const Self = @This();

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

            if (canSolveP1(lhs, rhs[0..operands])) {
                self.p1 += lhs;
            }
            if (canSolveP2(lhs, rhs[0..operands])) {
                self.p2 += lhs;
            }
        }

        pub fn solveP1(self: *Self) T {
            return self.p1;
        }
        pub fn solveP2(self: *Self) T {
            return self.p2;
        }

        fn canSolveP1(lhs: T, rhs: []const T) bool {
            return canSolveP1Recursive(lhs, 0, rhs);
        }

        fn canSolveP1Recursive(total: T, acc: T, remaining: []const T) bool {
            if (remaining.len == 1) {
                return acc + remaining[0] == total or acc * remaining[0] == total;
            }
            if (acc > total) {
                return false;
            }

            return canSolveP1Recursive(total, acc + remaining[0], remaining[1..]) or canSolveP1Recursive(total, acc * remaining[0], remaining[1..]);
        }

        fn canSolveP2(lhs: T, rhs: []const T) bool {
            return canSolveP2Recursive(lhs, 0, rhs);
        }
        fn canSolveP2Recursive(total: T, acc: T, remaining: []const T) bool {
            if (remaining.len == 1) {
                return acc + remaining[0] == total or acc * remaining[0] == total or util.numconcat(T, acc, remaining[0], 10) == total;
            }
            if (acc > total) {
                return false;
            }

            return canSolveP2Recursive(total, acc + remaining[0], remaining[1..]) or canSolveP2Recursive(total, acc * remaining[0], remaining[1..]) or canSolveP2Recursive(total, util.numconcat(T, acc, remaining[0], 10), remaining[1..]);
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u64, 16), 128);
}
