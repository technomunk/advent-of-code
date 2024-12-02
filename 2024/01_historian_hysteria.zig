const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();

        left: std.ArrayList(T),
        right: std.ArrayList(T),
        counts: std.AutoHashMap(T, T),

        fn init(allocator: anytype) Self {
            return Self{
                .left = std.ArrayList.init(allocator),
                .right = std.ArrayList.init(allocator),
                .counts = std.AutoHashMap(i32, i32).init(allocator),
            };
        }

        fn deinit(self: *Self) void {
            self.left.deinit();
            self.right.deinit();
            self.counts.deinit();
        }

        fn processLine(self: *Self, line: []const u8) !void {
            const spaceIndex = std.mem.indexOf(u8, line, "   ").?;
            const l = try std.fmt.parseInt(i32, line[0..spaceIndex], 10);
            const r = try std.fmt.parseInt(i32, line[spaceIndex + 3 ..], 10);
            try self.left.append(l);
            try self.right.append(r);
        }

        fn solveP1(self: *Self) T {
            std.mem.sort(T, self.left.items, {}, std.sort.asc(T));
            std.mem.sort(T, self.right.items, {}, std.sort.asc(T));
            var total: T = 0;
            for (self.left.items, self.right.items) |l, r| {
                var d = l - r;
                if (d < 0) {
                    d *= -1;
                }
                total += d;
            }
            return total;
        }

        fn solveP2(self: *Self) !T {
            for (self.right.items) |r| {
                const entry = try self.counts.getOrPutValue(r, 0);
                entry.value_ptr.* += 1;
            }
            var result: T = 0;
            for (self.left.items) |l| {
                result += l * (self.counts.get(l) orelse 0);
            }
            return result;
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u32));
}
