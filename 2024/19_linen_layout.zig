const std = @import("std");
const util = @import("util.zig");

const PartialSolution = struct {
    towelIdx: usize,
    matchedLen: usize,
};
const Solution = struct {
    const Self = @This();

    letters: std.ArrayList(u8),
    towels: std.ArrayList([2]usize),
    cache: std.StringHashMap(usize),

    p1: usize = 0,
    p2: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .letters = std.ArrayList(u8).init(allocator),
            .towels = std.ArrayList([2]usize).init(allocator),
            .cache = std.StringHashMap(usize).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.letters.deinit();
        self.towels.deinit();
        var keyIter = self.cache.keyIterator();
        while (keyIter.next()) |k| {
            self.cache.allocator.free(k.*);
        }
        self.cache.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        if (line.len == 0)
            return;
        if (self.letters.items.len == 0) {
            try self.readTowels(line);
            return;
        }
        const poss = try self.possibilities(line);
        if (poss > 0)
            self.p1 += 1;
        self.p2 += poss;
    }

    pub fn solveP1(self: *Self) !usize {
        return self.p1;
    }
    pub fn solveP2(self: *Self) !usize {
        return self.p2;
    }

    fn possibilities(self: *Self, pattern: []const u8) !usize {
        if (pattern.len == 0) {
            return 1;
        }

        if (self.cache.get(pattern)) |ans|
            return ans;

        var ans: usize = 0;
        for (0..self.towels.items.len) |i| {
            const towel = self.getTowel(i);
            if (!std.mem.startsWith(u8, pattern, towel))
                continue;
            ans += try self.possibilities(pattern[towel.len..]);
        }
        const key = try self.cache.allocator.alloc(u8, pattern.len);
        std.mem.copyForwards(u8, key, pattern);
        try self.cache.put(key, ans);
        return ans;
    }

    fn readTowels(self: *Self, line: []const u8) !void {
        var towelIter = std.mem.splitSequence(u8, line, ", ");
        while (towelIter.next()) |t| {
            const start = self.letters.items.len;
            try self.letters.appendSlice(t);
            try self.towels.append(.{ start, self.letters.items.len });
        }
    }

    fn getTowel(self: *Self, n: usize) []u8 {
        const start, const end = self.towels.items[n];
        return self.letters.items[start..end];
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 4096);
}
