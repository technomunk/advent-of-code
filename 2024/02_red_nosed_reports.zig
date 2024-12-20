const std = @import("std");
const util = @import("util.zig");

fn Reports(comptime T: type, comptime MAX_LEN: usize) type {
    return struct {
        const Self = @This();

        p1: T,
        p2: T,

        pub fn init(_: anytype) Self {
            return Self{
                .p1 = 0,
                .p2 = 0,
            };
        }

        pub fn deinit(_: *Self) void {}

        pub fn processLine(self: *Self, line: []const u8) !void {
            var values = std.mem.splitSequence(u8, line, " ");
            var report: [MAX_LEN]T = undefined;
            var index: usize = 0;
            while (values.next()) |val| {
                report[index] = try std.fmt.parseInt(T, val, 10);
                index += 1;
            }
            if (_isSafe(report[0..index])) {
                self.p1 += 1;
                self.p2 += 1;
            } else if (_isSafeRemovingOne(report[0..index]))
                self.p2 += 1;
        }

        pub fn solveP1(self: *Self) !T {
            return self.p1;
        }

        pub fn solveP2(self: *Self) !T {
            return self.p2;
        }

        fn _isSafe(line: []const T) bool {
            var last = line[0];
            const is_growing = line[1] > last;
            for (line[1..]) |v| {
                if ((v == last) or (v > last and v - last > 3) or (v < last and last - v > 3)) {
                    return false;
                }
                const v_is_growing = v > last;
                if (v_is_growing != is_growing) {
                    return false;
                }
                last = v;
            }
            return true;
        }

        fn _isSafeRemovingOne(line: []const T) bool {
            var nline: [MAX_LEN]T = undefined;
            for (0..line.len) |x| {
                var nline_len: usize = 0;
                for (line, 0..) |v, y| {
                    if (x == y) {
                        continue;
                    }
                    nline[nline_len] = v;
                    nline_len += 1;
                }
                if (_isSafe(nline[0 .. line.len - 1])) {
                    return true;
                }
            }
            return false;
        }
    };
}

pub fn main() !void {
    try util.execSolution(Reports(u32, 16), 128);
}
