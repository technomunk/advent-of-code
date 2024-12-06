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

pub fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    return std.mem.indexOfScalar(T, haystack, needle) != null;
}

pub fn DenseGrid(comptime T: type) type {
    return struct {
        const Self = @This();

        values: std.ArrayList(T),
        width: usize,
        height: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .values = std.ArrayList(T).init(allocator),
                .width = 1,
                .height = 0,
            };
        }
        pub fn deinit(self: *Self) void {
            self.values.deinit();
        }

        pub fn clone(self: *Self) !Self {
            var values = std.ArrayList(T).init(self.values.allocator);
            try values.appendSlice(self.values.items);
            return Self{
                .values = values,
                .width = self.width,
                .height = self.height,
            };
        }

        pub fn append(self: *Self, item: T) !void {
            try self.values.append(item);
        }
        pub fn appendRow(self: *Self, row: []const T) !void {
            try self.values.appendSlice(row);
            self.height += 1;
        }

        pub fn get(self: *Self, x: usize, y: usize) T {
            return self.values.items[x + y * self.width];
        }
        pub fn set(self: *Self, x: usize, y: usize, value: T) void {
            self.values.items[x + y * self.width] = value;
        }

        pub fn getRow(self: *Self, y: usize) []T {
            const start = y * self.width;
            const end = start + self.width;
            return self.values.items[start..end];
        }

        pub fn count(self: *Self, value: T) usize {
            var result: usize = 0;
            for (self.values.items) |item| {
                if (item == value) {
                    result += 1;
                }
            }
            return result;
        }
        pub fn countAnyOf(self: *Self, values: []const T) usize {
            var result: usize = 0;
            for (self.values.items) |item| {
                if (contains(T, values, item)) {
                    result += 1;
                }
            }
            return result;
        }
    };
}
