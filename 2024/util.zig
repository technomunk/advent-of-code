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

pub fn execSolution(comptime Solution: type) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    var solution = Solution.init(allocator);
    defer solution.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buffer: [128]u8 = undefined;
    while (try readLine(stdin, &buffer)) |line| {
        try solution.processLine(line);
    }

    if (@hasDecl(Solution, "finalizeInput")) {
        solution.finalizeInput();
    }

    try stdout.print("P1: {}\nP2: {}\n", .{ solution.solveP1(), solution.solveP2() });
}
