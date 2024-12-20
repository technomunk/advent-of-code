const std = @import("std");
const util = @import("util.zig");

fn Computer(comptime T: type) type {
    return struct {
        const Self = @This();
        const Op = fn (self: *Self, operand: u3) void;

        output: std.ArrayList(u3),

        a: T = undefined,
        b: T = undefined,
        c: T = undefined,

        ip: usize = 0,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .output = std.ArrayList(u3).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.output.deinit();
        }

        pub fn reset(self: *Self, a: T, b: T, c: T) void {
            self.a = a;
            self.b = b;
            self.c = c;
            self.ip = 0;
            self.output.clearRetainingCapacity();
        }

        pub fn exec(self: *Self, program: []u3) void {
            while (self.ip < program.len) {
                const op: *const Op = decodeOp(program[self.ip]);
                op(self, program[self.ip + 1]);
                if (op != &jnz) {
                    self.ip += 2;
                }
            }
        }

        pub fn execUpTo(self: *Self, program: []u3, maxOutput: usize) void {
            while (self.ip < program.len) {
                const op: *const Op = decodeOp(program[self.ip]);
                op(self, program[self.ip + 1]);
                if (op != &jnz) {
                    self.ip += 2;
                }
                if (self.output.items.len >= maxOutput) {
                    return;
                }
            }
        }

        fn combo(self: *const Self, operand: u3) T {
            return switch (operand) {
                0...3 => @intCast(operand),
                4 => self.a,
                5 => self.b,
                6 => self.c,
                else => @panic("Invalid combo operand"),
            };
        }
        fn literal(operand: u3) T {
            return @intCast(operand);
        }

        fn adv(self: *Self, operand: u3) void {
            self.a = self.a / twoTo(self.combo(operand));
        }
        fn bxl(self: *Self, operand: u3) void {
            self.b = self.b ^ literal(operand);
        }
        fn bst(self: *Self, operand: u3) void {
            self.b = self.combo(operand) & 0b111;
        }
        fn jnz(self: *Self, operand: u3) void {
            if (self.a == 0) {
                self.ip += 2;
                return;
            }
            self.ip = literal(operand);
        }
        fn bxc(self: *Self, operand: u3) void {
            _ = operand;
            self.b = self.b ^ self.c;
        }
        fn out(self: *Self, operand: u3) void {
            const val = self.combo(operand) & 0b111;
            self.output.append(@intCast(val)) catch @panic("OOM");
        }
        fn bdv(self: *Self, operand: u3) void {
            self.b = self.a / twoTo(self.combo(operand));
        }
        fn cdv(self: *Self, operand: u3) void {
            self.c = self.a / twoTo(self.combo(operand));
        }

        const OPS: [8]*const Op = .{ &adv, &bxl, &bst, &jnz, &bxc, &out, &bdv, &cdv };
        fn decodeOp(opcode: u3) *const Op {
            return OPS[opcode];
        }

        pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            try writer.print("Computer{{a: {[a]}, b: {[b]}, c: {[c]}}}", self);
        }

        fn twoTo(value: T) T {
            return @as(T, 1) << @as(u5, @intCast(value));
        }
    };
}

fn Solution(comptime T: type) type {
    return struct {
        const Self = @This();

        computer: Computer(T),
        program: std.ArrayList(u3),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .computer = Computer(T).init(allocator),
                .program = std.ArrayList(u3).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.computer.deinit();
            self.program.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            if (std.mem.startsWith(u8, line, "Register ")) {
                try self.parseRegister(line);
            } else if (std.mem.startsWith(u8, line, "Program: ")) {
                try self.parseProgram(line);
            }
        }

        pub fn solveP1(self: *Self) !usize {
            self.computer.exec(self.program.items);
            var includeSep = false;
            for (self.computer.output.items) |o| {
                if (includeSep) {
                    std.debug.print(",{}", .{o});
                } else {
                    std.debug.print("{}", .{o});
                    includeSep = true;
                }
            }
            std.debug.print("\n", .{});
            return 1;
        }
        pub fn solveP2(self: *Self) !usize {
            return @intCast(try self.searchForRegisterVal());
        }

        fn searchForRegisterVal(self: *Self) !u64 {
            const SEARCH_BIT_COUNT: u6 = 3;
            const Hit = struct {
                pos: usize,
                bits: u3,
                result: u64,
            };
            var stack = std.ArrayList(Hit).init(self.program.allocator);
            defer stack.deinit();

            try stack.append(.{ .pos = self.program.items.len, .bits = 0, .result = 0 });
            while (stack.popOrNull()) |lastHit| {
                if (lastHit.pos == 0) {
                    return lastHit.result;
                }
                var bits: u64 = (1 << SEARCH_BIT_COUNT) - 1;
                while (bits < (1 << SEARCH_BIT_COUNT)) : (bits -%= 1) {
                    const searchIdx = lastHit.pos - 1;
                    const shift: u6 = @intCast(searchIdx * SEARCH_BIT_COUNT);
                    const a: u64 = (bits << shift) | lastHit.result;
                    self.computer.reset(a, 0, 0);
                    self.computer.exec(self.program.items);
                    if (self.computer.output.items.len < searchIdx)
                        continue;
                    if (std.mem.eql(u3, self.program.items[searchIdx..], self.computer.output.items[searchIdx..])) {
                        try stack.append(.{ .pos = searchIdx, .bits = @intCast(bits), .result = a });
                    }
                }
            }
            std.debug.panic("Could not find the A register", .{});
        }

        fn parseRegister(self: *Self, line: []const u8) !void {
            const register = line[9];
            const val = try std.fmt.parseInt(T, line[12..], 10);
            switch (register) {
                'A' => self.computer.a = val,
                'B' => self.computer.b = val,
                'C' => self.computer.c = val,
                else => @panic("Unknown register"),
            }
        }

        fn parseProgram(self: *Self, line: []const u8) !void {
            var opcodeIter = std.mem.splitScalar(u8, line[9..], ',');
            while (opcodeIter.next()) |c| {
                if (c.len > 1)
                    @panic("Unexpected opcode");
                try self.program.append(@intCast(c[0] - '0'));
            }
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u64), 64);
}
