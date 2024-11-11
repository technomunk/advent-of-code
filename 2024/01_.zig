const std = @import("std");

pub fn main() !void {
    const dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    var it = dir.iterate();
    while (try it.next()) |file| {
        if (std.ascii.endsWithIgnoreCase(file.name, ".zig")) {
            std.debug.print("Found Zig file: {s}\n", .{file.name});
        }
    }
}
