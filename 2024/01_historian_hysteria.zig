const std = @import("std");

const ValSeq = std.ArrayList(i32);

fn readLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(buffer, '\n')) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

const SeqPair = struct {
    left: ValSeq,
    right: ValSeq,
    counts: std.AutoHashMap(i32, i32),

    fn init(allocator: anytype) SeqPair {
        return SeqPair{
            .left = ValSeq.init(allocator),
            .right = ValSeq.init(allocator),
            .counts = std.AutoHashMap(i32, i32).init(allocator),
        };
    }

    fn deinit(self: *SeqPair) void {
        self.left.deinit();
        self.right.deinit();
        self.counts.deinit();
    }

    fn parseLine(self: *SeqPair, line: []const u8) !void {
        const spaceIndex = std.mem.indexOf(u8, line, "   ").?;
        const l = try std.fmt.parseInt(i32, line[0..spaceIndex], 10);
        const r = try std.fmt.parseInt(i32, line[spaceIndex + 3 ..], 10);
        try self.left.append(l);
        try self.right.append(r);
    }

    fn solveP1(self: *SeqPair) i32 {
        std.mem.sort(i32, self.left.items, {}, std.sort.asc(i32));
        std.mem.sort(i32, self.right.items, {}, std.sort.asc(i32));
        var total: i32 = 0;
        for (self.left.items, self.right.items) |l, r| {
            var d = l - r;
            if (d < 0) {
                d *= -1;
            }
            total += d;
        }
        return total;
    }

    fn solveP2(self: *SeqPair) !i32 {
        for (self.right.items) |r| {
            const entry = try self.counts.getOrPutValue(r, 0);
            entry.value_ptr.* += 1;
        }
        var result: i32 = 0;
        for (self.left.items) |l| {
            result += l * (self.counts.get(l) orelse 0);
        }
        return result;
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    var pair = SeqPair.init(allocator);
    defer pair.deinit();

    var buffer: [64]u8 = undefined;
    var line = try readLine(stdin, &buffer);
    while (line != null) {
        try pair.parseLine(line.?);
        line = try readLine(stdin, &buffer);
    }

    try stdout.print("P1: {}\nP2: {}\n", .{ pair.solveP1(), try pair.solveP2() });
}
