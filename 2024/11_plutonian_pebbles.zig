const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();
        const CacheKey = struct { T, usize };

        cache: std.AutoHashMap(CacheKey, usize),
        p1: usize = 0,
        p2: usize = 0,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .cache = std.AutoHashMap(CacheKey, usize).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.cache.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            var it = std.mem.splitScalar(u8, line, ' ');
            while (it.next()) |n| {
                const num = try std.fmt.parseInt(T, n, 10);
                self.p1 += try self.blink(25, num);
                self.p2 += try self.blink(75, num);
            }
        }

        pub fn solveP1(self: *Self) !usize {
            return self.p1;
        }
        pub fn solveP2(self: *Self) !usize {
            return self.p2;
        }

        fn blink(self: *Self, times: usize, n: T) !usize {
            if (self.cache.get(.{ n, times })) |a| {
                return a;
            }

            if (times == 1) {
                if (split(n) != null)
                    return 2;
                return 1;
            }
            if (n == 0)
                return self.blink(times - 1, 1);

            if (split(n)) |ans| {
                const blinks = try self.blink(times - 1, ans[0]) + try self.blink(times - 1, ans[1]);
                try self.cache.put(.{ n, times }, blinks);
                return blinks;
            } else {
                const blinks = try self.blink(times - 1, n * 2024);
                try self.cache.put(.{ n, times }, blinks);
                return blinks;
            }
        }

        fn split(n: T) ?struct { T, T } {
            var digits: usize = 1;
            var nm = n / 10;
            while (nm > 0) {
                digits += 1;
                nm /= 10;
            }

            if (digits & 1 == 0) {
                const pivot = std.math.powi(T, 10, @intCast(digits >> 1)) catch @panic("Overflow!?");
                const b = n % pivot;
                return .{ n / pivot, b };
            }
            return null;
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u64), 64);
}
