const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();

        p1: T,
        p2: T,

        _enable: bool,

        pub fn init(_: anytype) Self {
            return Self{
                .p1 = 0,
                .p2 = 0,
                ._enable = true,
            };
        }
        pub fn deinit(_: *Self) void {}

        pub fn processLine(self: *Self, line: []const u8) !void {
            var pos: usize = 0;
            const SYMBOLS: [3][]const u8 = .{ "mul(", "do()", "don't()" };
            while (util.indexOfFirst(u8, line, pos, &SYMBOLS)) |hit| {
                if (hit.idx == 0) {
                    if (try _grabValues(line[hit.pos + 4 ..])) |vals| {
                        self.p1 += vals.a * vals.b;
                        if (self._enable) {
                            self.p2 += vals.a * vals.b;
                        }
                        pos = hit.pos + 4 + vals.end;
                    } else {
                        pos = hit.pos + 4;
                    }
                } else {
                    pos = hit.pos + SYMBOLS[hit.idx].len;
                    self._enable = hit.idx == 1;
                }
            }
        }

        pub fn solveP1(self: *Self) T {
            return self.p1;
        }

        pub fn solveP2(self: *Self) T {
            return self.p2;
        }

        const GrabbedValues = struct {
            a: T,
            b: T,
            end: usize,
        };
        fn _grabValues(slice: []const u8) !?GrabbedValues {
            const State = enum { a, b };

            var state = State.a;
            var start: usize = 0;
            var expectedEnd: u8 = ',';
            var result = GrabbedValues{
                .a = undefined,
                .b = undefined,
                .end = undefined,
            };
            for (slice, 0..) |ch, i| {
                if (std.ascii.isDigit(ch)) {
                    continue;
                }
                if (ch != expectedEnd) {
                    return null;
                }

                switch (state) {
                    State.a => {
                        result.a = try std.fmt.parseInt(T, slice[start..i], 10);
                        expectedEnd = ')';
                        start = i + 1;
                        state = State.b;
                    },
                    State.b => {
                        result.b = try std.fmt.parseInt(T, slice[start..i], 10);
                        result.end = i + 1;
                        return result;
                    },
                }
            }
            return null;
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u32), 4096);
}
