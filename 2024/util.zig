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
    const startTs = std.time.milliTimestamp();
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
    const setupTs = std.time.milliTimestamp();
    while (try readLine(stdin, &buffer)) |line| {
        try solution.processLine(line);
    }

    if (@hasDecl(Solution, "finalizeInput")) {
        solution.finalizeInput();
    }

    const inputTs = std.time.milliTimestamp();
    const p1 = solution.solveP1();
    const p1Ts = std.time.milliTimestamp();
    const p2 = solution.solveP2();

    const finalTs = std.time.milliTimestamp();
    try stdout.print(
        "Setup  : {}ms\nInput  : {}ms\nP1 time: {}ms\nP2 time: {}ms\nTotal  : {}ms\n\n",
        .{
            setupTs - startTs,
            inputTs - setupTs,
            p1Ts - inputTs,
            finalTs - p1Ts,
            finalTs - startTs,
        },
    );

    try stdout.print("P1: {}\nP2: {}\n", .{ p1, p2 });
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
        backing: std.AutoHashMap(T, void),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .backing = std.AutoHashMap(T, void).init(allocator),
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
