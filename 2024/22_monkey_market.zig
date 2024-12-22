const std = @import("std");
const util = @import("util.zig");

const Solution = struct {
    const Self = @This();
    const Seq = [4]i8;

    bananasPerSeq: std.AutoHashMap(Seq, u64),
    seen: util.Set(Seq),

    p1: u64 = 0,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .bananasPerSeq = std.AutoHashMap(Seq, u64).init(allocator),
            .seen = util.Set(Seq).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.bananasPerSeq.deinit();
        self.seen.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        const seed = try std.fmt.parseInt(u64, line, 10);
        self.p1 += try self.run(seed);
    }

    pub fn solveP1(self: *Self) !u64 {
        return self.p1;
    }
    pub fn solveP2(self: *Self) !u64 {
        var max: u64 = 0;
        var iter = self.bananasPerSeq.iterator();
        while (iter.next()) |entry| {
            max = @max(entry.value_ptr.*, max);
        }
        return max;
    }

    const TEST_SEQ: Seq = .{ -2, 1, -1, 3 };
    fn run(self: *Self, seed: u64) !u64 {
        self.seen.clearRetainingCapacity();
        var seq: Seq = undefined;
        var s = seed;
        var price: i8 = @intCast(@rem(s, 10));

        for (0..4) |i| {
            const lastPrice = price;
            s = secret(s);
            price = @intCast(@rem(s, 10));
            seq[i] = price - lastPrice;
        }

        try self.seen.add(seq);
        var prevBananas = self.bananasPerSeq.get(seq) orelse 0;
        try self.bananasPerSeq.put(seq, prevBananas + @as(u64, @intCast(price)));

        for (4..2_000) |_| {
            const lastPrice = price;
            s = secret(s);
            price = @intCast(@rem(s, 10));
            push(&seq, price - lastPrice);
            if (self.seen.has(seq))
                continue;
            try self.seen.add(seq);
            prevBananas = self.bananasPerSeq.get(seq) orelse 0;
            try self.bananasPerSeq.put(seq, prevBananas + @as(u64, @intCast(price)));
        }
        return s;
    }

    fn secret(x: u64) u64 {
        var r = prune(mix(x, x << 6));
        r = prune(mix(r, r >> 5));
        r = prune(mix(r, r << 11));
        return r;
    }

    fn mix(nm: u64, mixin: u64) u64 {
        return nm ^ mixin;
    }
    fn prune(nm: u64) u64 {
        return @rem(nm, 16777216);
    }

    fn push(seq: *Seq, val: i8) void {
        for (0..3) |i| {
            seq.*[i] = seq[i + 1];
        }
        seq.*[3] = val;
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 64);
}
