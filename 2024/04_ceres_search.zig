const std = @import("std");
const util = @import("util.zig");

const Solution = struct {
    const Self = @This();

    width: usize,
    chars: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .width = 0,
            .chars = std.ArrayList(u8).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.chars.deinit();
    }

    pub fn processLine(self: *Self, line: []const u8) !void {
        self.width = line.len;
        try self.chars.appendSlice(line);
    }

    pub fn solveP1(self: *Self) !usize {
        var result: usize = 0;
        for (self.chars.items, 0..) |c, i| {
            if (c == 'X')
                result += self._countXmas(i % self.width, i / self.width);
        }
        return result;
    }

    pub fn solveP2(self: *Self) !usize {
        var result: usize = 0;
        for (self.chars.items, 0..) |c, i| {
            if (c == 'A' and self._isCrossMas(i % self.width, i / self.width))
                result += 1;
        }
        return result;
    }

    fn _charAt(self: *Self, x: usize, y: usize) u8 {
        return self.chars.items[self.width * y + x];
    }
    fn _countXmas(self: *Self, x: usize, y: usize) usize {
        var result = self._countXmasInDir(x, y, -1, -1);
        result += self._countXmasInDir(x, y, -1, 0);
        result += self._countXmasInDir(x, y, -1, 1);
        result += self._countXmasInDir(x, y, 0, -1);
        result += self._countXmasInDir(x, y, 0, 1);
        result += self._countXmasInDir(x, y, 1, -1);
        result += self._countXmasInDir(x, y, 1, 0);
        result += self._countXmasInDir(x, y, 1, 1);
        return result;
    }
    fn _countXmasInDir(self: *Self, x: usize, y: usize, dx: isize, dy: isize) usize {
        const height = self.chars.items.len / self.width;
        if ((dy < 0 and y < 3) or (dy > 0 and y > height - 4) or (dx < 0 and x < 3) or (dx > 0 and x > self.width - 4)) {
            return 0;
        }

        const CHARS: []const u8 = "MAS";
        var cx: usize = x;
        var cy: usize = y;
        for (CHARS) |c| {
            cx = @intCast(@as(isize, @intCast(cx)) + dx);
            cy = @intCast(@as(isize, @intCast(cy)) + dy);
            if (c != self._charAt(cx, cy)) {
                return 0;
            }
        }
        return 1;
    }

    fn _isCrossMas(self: *Self, x: usize, y: usize) bool {
        const height = self.chars.items.len / self.width;
        if (x < 1 or x > self.width - 2 or y < 1 or y > height - 2)
            return false;

        return self._isPosDiagAt(x, y) and self._isNegDiagAt(x, y);
    }

    fn _isPosDiagAt(self: *Self, x: usize, y: usize) bool {
        return self._charAt(x - 1, y - 1) + self._charAt(x + 1, y + 1) == 'M' + 'S';
    }
    fn _isNegDiagAt(self: *Self, x: usize, y: usize) bool {
        return self._charAt(x - 1, y + 1) + self._charAt(x + 1, y - 1) == 'M' + 'S';
    }
};

pub fn main() !void {
    try util.execSolution(Solution, 256);
}
