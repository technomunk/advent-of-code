const std = @import("std");

pub fn Matrix(comptime T: type, comptime width: usize, comptime height: usize) type {
    return struct {
        const Self = @This();
        vals: [width * height]T = undefined,

        pub fn zeroed() Self {
            const result = Self{};
            for (result.vals) |*v| {
                v.* = 0;
            }
            return result;
        }
        pub fn clone(self: *const Self) Self {
            const result = Self{};
            for (self.vals, 0..) |v, i| {
                result.vals[i] = v;
            }
            return result;
        }

        pub fn row(self: *Self, y: usize) [width]T {
            return &self.vals[y * width .. (y * width + 1)];
        }
        pub fn col(self: *Self, x: usize) [height]*T {
            var result: [height]*T = undefined;
            for (0..height) |y| {
                result[y] = &self.vals[y * width + x];
            }
            return result;
        }
        pub fn colCopy(self: *Self, x: usize) [height]T {
            var result: [height]T = undefined;
            for (0..height) |y| {
                result[y] = self.vals[y * width + x];
            }
            return result;
        }

        pub fn get(self: *const Self, x: usize, y: usize) T {
            return self.vals[x + y * width];
        }
        pub fn set(self: *Self, x: usize, y: usize, val: T) void {
            self.vals[x + y * width] = val;
        }

        pub fn gaussianElimination(self: *Self) void {
            var x: usize = 0;
            var y: usize = 0;
            while (x < width and y < width) {
                const pivot = std.mem.indexOfMax(T, self.row(y));
            }
        }

        fn exportIfSquare(comptime functions: type) type {
            return if (width == height) functions else struct {};
        }

        pub usingnamespace exportIfSquare(struct {
            pub fn identity() Self {
                const result = zeroed();
                for (0..width) |i| {
                    result.set(i, i, 1);
                }
                return result;
            }
        });
    };
}
