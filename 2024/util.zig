const std = @import("std");

pub fn readLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

pub fn execSolution(comptime Solution: type, comptime buffer_len: usize) !void {
    var timer = try std.time.Timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    var solution = Solution.init(allocator);
    defer solution.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buffer: [buffer_len]u8 = undefined;

    const setupT = timer.read();

    while (try readLine(stdin, &buffer)) |line| {
        try solution.processLine(line);
    }

    if (std.meta.hasMethod(Solution, "finalizeInput")) {
        try solution.finalizeInput();
    }
    const inputT = timer.read();

    const p1 = try solution.solveP1();
    const p1T = timer.read();

    const p2 = try solution.solveP2();
    const finalT = timer.read();
    try printTime(stdout, "Setup", setupT);
    try printTime(stdout, "Input", inputT - setupT);
    try printTime(stdout, "Part 1", p1T - inputT);
    try printTime(stdout, "Part 2", finalT - p1T);
    try printTime(stdout, "Total", finalT);

    try stdout.print("\nP1: {}\nP2: {}\n", .{ p1, p2 });
}

fn printTime(out: anytype, label: []const u8, nanos: u64) !void {
    const unit, const time = readableTime(nanos);
    try out.print("{s:<6}: {d:.2} {s}\n", .{ label, time, unit });
}
fn readableTime(nanos: u64) struct { []const u8, f64 } {
    var time: f64 = @floatFromInt(nanos);
    if (time > 1e4) {
        time /= 1e6;
        if (time > 1e3) {
            time /= 1e3;
            if (time > 100) {
                time /= 60;
                return .{ "m", time };
            }
            return .{ "s", time };
        }
        return .{ "ms", time };
    }
    return .{ "ns", time };
}

pub fn indexOfFirst(comptime T: type, haystack: []const T, start_index: usize, values: []const []const T) ?struct { pos: usize, idx: usize } {
    var min_pos: ?usize = null;
    var needle_idx: ?usize = null;
    for (values, 0..) |val, needle_i| {
        if (std.mem.indexOfPos(T, haystack[0 .. min_pos orelse haystack.len], start_index, val)) |pos| {
            if (min_pos == null or min_pos.? > pos) {
                min_pos = pos;
                needle_idx = needle_i;
            }
        }
    }
    if (min_pos != null and needle_idx != null) {
        return .{ .pos = min_pos.?, .idx = needle_idx.? };
    }
    return null;
}

pub fn Set(comptime T: type) type {
    return struct {
        const Self = @This();
        const BackingT = std.AutoHashMap(T, void);
        const IteratorT = BackingT.KeyIterator;
        backing: BackingT,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .backing = BackingT.init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.backing.deinit();
        }

        pub fn add(self: *Self, value: T) !void {
            try self.backing.put(value, void{});
        }
        pub fn has(self: *Self, value: T) bool {
            return self.backing.get(value) != null;
        }
        pub fn count(self: *Self) u32 {
            return self.backing.count();
        }

        pub fn clearRetainingCapacity(self: *Self) void {
            self.backing.clearRetainingCapacity();
        }

        pub fn iterator(self: *Self) IteratorT {
            return self.backing.keyIterator();
        }
    };
}

pub fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |straw| {
        if (std.meta.eql(straw, needle)) {
            return true;
        }
    }
    return false;
}

pub fn clone(comptime T: type, allocator: std.mem.Allocator, slice: []const T) ![]T {
    const result = try allocator.alloc(T, slice.len);
    std.mem.copyForwards(T, result, slice);
    return result;
}

// Concatenate 2 integers using provided base
pub fn numconcat(comptime T: type, lhs: T, rhs: T, base: u8) T {
    var shifted_lhs = lhs;
    var shifted_rhs = rhs;
    while (shifted_rhs > 0) {
        shifted_rhs /= base;
        shifted_lhs *= base;
    }
    return shifted_lhs + rhs;
}

/// A* pathfinder
///
/// The context needs to have the following methods:
/// - `fn getNeighbors(self: TCtx, node: TNode) []TNode`
/// - `fn heuristic(self: TCtx, from: TNode, to: TNode) usize`
/// - `fn calcDist(self: TCtx, from: TNode, to: TNode) usize`
/// - `fn eq(self: TCtx, a: TNode, b: TNode) bool`
pub fn PathFinder(comptime TNode: type, comptime TCtx: type) type {
    const CostMap = std.AutoHashMap(TNode, usize);
    const PrioCtx = struct {
        const Self = @This();

        costs: *CostMap,
        ctx: *TCtx,
        to: TNode,

        pub fn cmp(self: Self, a: TNode, b: TNode) std.math.Order {
            return std.math.order(self.costOf(a), self.costOf(b));
        }

        fn costOf(self: *const Self, node: TNode) usize {
            if (self.costs.get(node)) |cost| {
                return std.math.add(usize, cost, self.ctx.heuristic(node, self.to)) catch return std.math.maxInt(usize);
            }
            return std.math.maxInt(usize);
        }
    };
    const PrioQueue = std.PriorityQueue(TNode, PrioCtx, PrioCtx.cmp);

    return struct {
        pub const PathError = error{NoPathExists};
        const Self = @This();

        prev: std.AutoHashMap(TNode, TNode),
        dist: CostMap,
        ctx: TCtx,

        lastFrom: ?TNode = null,
        lastTo: ?TNode = null,

        pub fn init(allocator: std.mem.Allocator, context: TCtx) Self {
            return Self{
                .prev = std.AutoHashMap(TNode, TNode).init(allocator),
                .dist = CostMap.init(allocator),
                .ctx = context,
            };
        }
        pub fn deinit(self: *Self) void {
            self.prev.deinit();
            self.dist.deinit();
        }

        pub fn lowestPathScore(self: *Self, from: TNode, to: TNode) !usize {
            if (self.lastFrom == null or !self.ctx.eq(from, self.lastFrom.?) or !self.ctx.eq(to, self.lastTo.?))
                try self.pathfind(from, to);
            return self.dist.get(to).?;
        }

        pub fn pathfind(self: *Self, from: TNode, to: TNode) !void {
            var queue = PrioQueue.init(self.prev.allocator, .{
                .costs = &self.dist,
                .to = to,
                .ctx = &self.ctx,
            });
            defer queue.deinit();

            self.reset();
            try queue.add(from);
            try self.dist.put(from, 0);

            while (queue.removeOrNull()) |current| {
                if (self.ctx.eq(current, to))
                    return;

                const currentDist = self.dist.get(current).?;
                for (self.ctx.getNeighbors(current)) |n| {
                    const dist = currentDist + self.ctx.calcDist(current, n);
                    const knownDist = self.dist.get(n) orelse std.math.maxInt(usize);
                    if (dist < knownDist) {
                        try self.prev.put(n, current);
                        try self.dist.put(n, dist);
                        if (!contains(TNode, queue.items, n))
                            try queue.add(n);
                    }
                }
            }

            return error.NoPathExists;
        }

        pub fn reset(self: *Self) void {
            self.lastFrom = null;
            self.lastTo = null;
            self.prev.clearRetainingCapacity();
            self.dist.clearRetainingCapacity();
        }
    };
}

fn trivialEq(a: anytype, b: anytype) bool {
    return a == b;
}

pub fn reverse(comptime T: type, slice: []T) void {
    var left: usize = 0;
    var right: usize = slice.len - 1;
    while (left < right) {
        std.mem.swap(T, &slice[left], &slice[right]);
        left += 1;
        right -= 1;
    }
}
