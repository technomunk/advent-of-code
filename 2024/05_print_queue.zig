const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();

        order: std.AutoHashMap(T, std.ArrayList(T)),
        seen: std.ArrayList(T),
        readingOrder: bool,
        p1: usize,
        p2: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .order = std.AutoHashMap(T, std.ArrayList(T)).init(allocator),
                .seen = std.ArrayList(T).init(allocator),
                .readingOrder = true,
                .p1 = 0,
                .p2 = 0,
            };
        }
        pub fn deinit(self: *Self) void {
            var it = self.order.valueIterator();
            while (it.next()) |arr| {
                arr.deinit();
            }
            self.order.deinit();
            self.seen.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            if (line.len == 0) {
                self.readingOrder = false;
                return;
            }

            if (self.readingOrder)
                try self.ingestOrder(line)
            else
                try self.ingestManual(line);
        }

        pub fn solveP1(self: *Self) !usize {
            return self.p1;
        }
        pub fn solveP2(self: *Self) !usize {
            return self.p2;
        }

        fn ingestOrder(self: *Self, line: []const u8) !void {
            var parts = std.mem.splitScalar(u8, line, '|');
            const before = try std.fmt.parseInt(T, parts.next().?, 10);
            const after = try std.fmt.parseInt(T, parts.next().?, 10);
            var entry = try self.order.getOrPut(before);
            if (!entry.found_existing)
                entry.value_ptr.* = std.ArrayList(T).init(self.order.allocator);
            try entry.value_ptr.append(after);
        }

        fn ingestManual(self: *Self, line: []const u8) !void {
            self.seen.clearRetainingCapacity();
            var pages = std.mem.splitScalar(u8, line, ',');
            var allCorrect = true;
            while (pages.next()) |page| {
                const pageIdx = try std.fmt.parseInt(T, page, 10);
                if (!self.canAppendRetainingOrder(pageIdx))
                    allCorrect = false;
                try self.seen.append(pageIdx);
            }
            if (allCorrect) {
                self.p1 += self.seen.items[self.seen.items.len / 2];
            } else {
                self.orderSeen();
                self.p2 += self.seen.items[self.seen.items.len / 2];
            }
        }
        fn canAppendRetainingOrder(self: *Self, pageIdx: T) bool {
            if (self.order.get(pageIdx)) |required_after| {
                for (required_after.items) |after| {
                    if (util.contains(T, self.seen.items, after))
                        return false;
                }
            }
            return true;
        }

        fn orderSeen(self: *Self) void {
            std.mem.sort(T, self.seen.items, self, cmp);
        }

        fn cmp(self: *Self, a: T, b: T) bool {
            if (self.order.get(a)) |required_after| {
                if (util.contains(T, required_after.items, b))
                    return true;
            }
            return false;
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u32), 128);
}
