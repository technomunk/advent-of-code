const std = @import("std");

pub fn build(b: *std.Build) !void {
    const day = b.option(u32, "day", "Day to build") orelse {
        std.log.err("Please specify a day to build with --day", .{});
        return;
    };

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root = try find_source_for_day(day);
    const exe = b.addExecutable(.{
        .name = "solution",
        .root_source_file = b.path(root),
        .target = target,
        .optimize = optimize,
    });

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}

fn find_source_for_day(day: u32) ![]const u8 {
    var buf: [8]u8 = undefined;
    const prefix = try std.fmt.bufPrint(&buf, "{d:0>2}_", .{day});

    const dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    var it = dir.iterate();
    while (try it.next()) |file| {
        if (std.ascii.startsWithIgnoreCase(file.name, prefix)) {
            return file.name;
        }
    }
    return error.DayNotFound;
}
