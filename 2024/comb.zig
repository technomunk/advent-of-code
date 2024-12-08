pub fn Combinations(comptime T: type) type {
    return struct {
        const Self = @This();
        a: usize = 0,
        b: usize = 0,
        values: []T,

        pub fn of(values: []T) Self {
            return Self{
                .values = values,
            };
        }

        pub fn next(self: *Self) ?[2]*T {
            if (self.b + 1 >= self.values.len) {
                if (self.a + 2 >= self.values.len) {
                    return null;
                }
                self.a += 1;
                self.b = self.a; // +1 will happen on next line
            }
            self.b += 1;
            return .{ &self.values[self.a], &self.values[self.b] };
        }
    };
}
