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
    while (try readLine(stdin, &buffer)) |line| {
        try solution.processLine(line);
    }

    if (@hasDecl(Solution, "finalizeInput")) {
        solution.finalizeInput();
    }

    try stdout.print("P1: {}\nP2: {}\n", .{ solution.solveP1(), solution.solveP2() });
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