const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();

        left: std.ArrayList(T),
        right: std.ArrayList(T),
        counts: std.AutoHashMap(T, T),

        pub fn init(allocator: anytype) Self {
            return Self{
                .left = std.ArrayList(T).init(allocator),
                .right = std.ArrayList(T).init(allocator),
                .counts = std.AutoHashMap(T, T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.left.deinit();
            self.right.deinit();
            self.counts.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            const spaceIndex = std.mem.indexOf(u8, line, "   ").?;
            const l = try std.fmt.parseInt(T, line[0..spaceIndex], 10);
            const r = try std.fmt.parseInt(T, line[spaceIndex + 3 ..], 10);
            try self.left.append(l);
            try self.right.append(r);
        }

        pub fn solveP1(self: *Self) T {
            std.mem.sort(T, self.left.items, {}, std.sort.asc(T));
            std.mem.sort(T, self.right.items, {}, std.sort.asc(T));
            var total: T = 0;
            for (self.left.items, self.right.items) |l, r| {
                total += @max(l, r) - @min(l, r);
            }
            return total;
        }

        pub fn solveP2(self: *Self) T {
            for (self.right.items) |r| {
                const entry = self.counts.getOrPutValue(r, 0) catch {
                    @panic("OOM");
                };
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
    try util.execSolution(Solution(u32), 128);
}
