const std = @import("std");
const util = @import("util.zig");

fn Reports(comptime T: type, comptime MAX_LEN: usize) type {
    return struct {
        const Self = @This();

        values: std.ArrayList(std.ArrayList(T)),

        fn init(allocator: anytype) Self {
            return Self{
                .values = std.ArrayList(std.ArrayList(T)).init(allocator),
            };
        }

        fn parseLine(self: *Self, line: []const u8) !void {
            var values = std.mem.splitSequence(u8, line, " ");
            var line_vals = std.ArrayList(T).init(self.values.allocator);
            while (values.next()) |val| {
                const value = try std.fmt.parseInt(T, val, 10);
                try line_vals.append(value);
            }
            try self.values.append(line_vals);
        }

        fn deinit(self: *Self) void {
            for (self.values.items) |line| {
                line.deinit();
            }
            self.values.deinit();
        }

        fn solveP1(self: *Self) T {
            var total: T = 0;
            for (self.values.items) |line| {
                if (!_isSafe(line.items)) {
                    continue;
                }
                total += 1;
            }
            return total;
        }

        fn solveP2(self: *Self) T {
            var total: T = 0;
            for (self.values.items) |line| {
                if (!_isSafe(line.items) and !_isSafeRemovingOne(line.items)) {
                    continue;
                }
                total += 1;
            }
            return total;
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
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    var reports = Reports(u32, 16).init(allocator);
    defer reports.deinit();

    var buffer: [64]u8 = undefined;

    while (try util.readLine(stdin, &buffer)) |line| {
        try reports.parseLine(line);
    }

    try stdout.print("P1: {}\nP2: {}\n", .{ reports.solveP1(), reports.solveP2() });
}
