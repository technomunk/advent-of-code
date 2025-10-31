const std = @import("std");
const util = @import("util.zig");
const geom = @import("geom.zig");

const Pt2 = geom.Point2(i32);

const Numpad = struct {
    pub const trap = Pt2{ .x = 0, .y = 3 };
    pub const startPos = pos('A');

    pub fn pos(ch: u8) Pt2 {
        return switch (ch) {
            '0' => .{ .x = 1, .y = 3 },
            '1' => .{ .x = 0, .y = 2 },
            '2' => .{ .x = 1, .y = 2 },
            '3' => .{ .x = 2, .y = 2 },
            '4' => .{ .x = 0, .y = 1 },
            '5' => .{ .x = 1, .y = 1 },
            '6' => .{ .x = 2, .y = 1 },
            '7' => .{ .x = 0, .y = 0 },
            '8' => .{ .x = 1, .y = 0 },
            '9' => .{ .x = 2, .y = 0 },
            'A' => .{ .x = 2, .y = 3 },
            else => std.debug.panic("Unknown numeric key: {c}", .{ch}),
        };
    }
};

const Dirpad = struct {
    pub const trap = Pt2{ .x = 0, .y = 0 };
    pub const startPos = pos('A');

    pub fn pos(ch: u8) Pt2 {
        return switch (ch) {
            '^' => .{ .x = 1, .y = 0 },
            'A' => .{ .x = 2, .y = 0 },
            '<' => .{ .x = 0, .y = 1 },
            'v' => .{ .x = 1, .y = 1 },
            '>' => .{ .x = 2, .y = 1 },
            else => std.debug.panic("Unknown directional key: {c}", .{ch}),
        };
    }
};

const Solution = struct {
    const Self = @This();
    const TransitionMap = std.AutoHashMap([2]u8, usize);

    transitions: TransitionMap,
    buffer: TransitionMap,

    p1: usize = 0,
    p2: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .transitions = TransitionMap.init(allocator),
            .buffer = TransitionMap.init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.transitions.deinit();
        self.buffer.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        try self.navNumeric(line);
        for (0..2) |_| {
            try self.navDirectional();
        }

        self.p1 += try calcComplexity(line);

        for (2..25) |_| {
            try self.navDirectional();
        }

        self.p2 += try calcComplexity(line);
    }

    pub fn solveP1(self: *Self) !usize {
        return self.p1;
    }
    pub fn solveP2(self: *Self) !usize {
        return self.p2;
    }

    fn calcComplexity(self: *const Self, line: []const u8) !usize {
        return keys.len * try std.fmt.parseInt(usize, line[0 .. line.len - 1], 10);
    }

    fn navNumeric(self: *Self, combination: []const u8) !void {
        return self.navGeneric(u8, combination);
    }

    fn navDirectional(self: *Self) !void {
        return self.navGeneric(Key, combination);
    }

    fn navGeneric(
        self: *Self,
        comptime T: type,
        combination: []const T,
    ) ![]const Key {
        const Spec = struct {
            getPos: fn (T) Pt2,
            safePath: fn (*Self, Pt2) std.mem.Allocator.Error!void,
            startPos: Pt2,
            trap: Pt2,
        };
        const spec: Spec = comptime switch (T) {
            u8 => .{
                .getPos = getNumericPos,
                .safePath = safePathNumeric,
                .startPos = .{ .x = 2, .y = 3 },
                .trap = .{ .x = 0, .y = 3 },
            },
            Key => .{
                .getPos = Key.pos,
                .safePath = safePathDirectional,
                .startPos = .{ .x = 2, .y = 0 },
                .trap = .{ .x = 0, .y = 0 },
            },
            else => @compileError("Unknown combination type"),
        };

        const seqStart = self.seq.items.len;

        var pos = spec.startPos;
        for (combination) |c| {
            const cPos = spec.getPos(c);
            try self.findPath(pos, cPos, spec.trap, spec.safePath);
            pos = cPos;
            try self.seq.append(.a);
        }
        return self.seq.items[seqStart..];
    }

    fn findPath(
        self: *Self,
        from: Pt2,
        to: Pt2,
        trap: Pt2,
        comptime safePath: fn (*Self, Pt2) std.mem.Allocator.Error!void,
    ) !void {
        const delta = to.sub(from);
        if ((from.x == trap.x and to.y == trap.y) or (from.y == trap.y and to.x == trap.x)) {
            try safePath(self, delta);
        } else {
            try self.optimalPath(delta);
        }
    }

    fn optimalPath(self: *Self, delta: Pt2) !void {
        try self.left(delta);
        try self.down(delta);
        try self.right(delta);
        try self.up(delta);
    }

    fn safePathNumeric(self: *Self, delta: Pt2) std.mem.Allocator.Error!void {
        try self.up(delta);
        try self.right(delta);
        try self.down(delta);
        try self.left(delta);
    }

    fn safePathDirectional(self: *Self, delta: Pt2) std.mem.Allocator.Error!void {
        try self.down(delta);
        try self.left(delta);
        try self.up(delta);
        try self.right(delta);
    }

    fn left(self: *Self, delta: Pt2) !void {
        var t = delta.x;
        while (t < 0) : (t += 1) {
            try self.seq.append(.left);
        }
    }
    fn right(self: *Self, delta: Pt2) !void {
        var t = delta.x;
        while (t > 0) : (t -= 1) {
            try self.seq.append(.right);
        }
    }
    fn up(self: *Self, delta: Pt2) !void {
        var t = delta.y;
        while (t < 0) : (t += 1) {
            try self.seq.append(.up);
        }
    }
    fn down(self: *Self, delta: Pt2) !void {
        var t = delta.y;
        while (t > 0) : (t -= 1) {
            try self.seq.append(.down);
        }
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 64);
}
