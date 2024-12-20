const std = @import("std");
const util = @import("util.zig");

fn Solution(comptime TId: type) type {
    return struct {
        const Self = @This();
        const EMPTY_ID: TId = std.math.maxInt(TId);

        nextId: TId = 0,
        disk: std.ArrayList(TId),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .disk = std.ArrayList(TId).init(allocator),
            };
        }
        pub fn deinit(self: *Self) void {
            self.disk.deinit();
        }

        pub fn processLine(self: *Self, line: []const u8) !void {
            var isFile = true;
            for (line) |c| {
                var id = EMPTY_ID;
                if (isFile) {
                    id = self.nextId;
                    self.nextId += 1;
                }
                if (c - '0' > 0) {
                    for (try self.disk.addManyAsSlice(c - '0')) |*new| {
                        new.* = id;
                    }
                }
                isFile = !isFile;
            }
        }

        pub fn solveP1(self: *Self) !usize {
            const disk = try util.clone(TId, self.disk.allocator, self.disk.items);
            defer self.disk.allocator.free(disk);
            refrag(disk);
            return checksum(disk);
        }
        pub fn solveP2(self: *Self) !usize {
            defrag(self.disk.items);
            return checksum(self.disk.items);
        }

        fn refrag(disk: []TId) void {
            var emptyIdx = std.mem.indexOfScalar(TId, disk, EMPTY_ID).?;
            var filledIdx = emptyIdx - 1;
            var activeIdx = disk.len - 1;
            while (activeIdx > emptyIdx) {
                disk[emptyIdx] = disk[activeIdx];
                disk[activeIdx] = EMPTY_ID;
                filledIdx = emptyIdx;
                emptyIdx = findNextEmptyIdx(disk, filledIdx);
                activeIdx = findPrevActiveIdx(disk, activeIdx);
            }
        }

        fn defrag(disk: []TId) void {
            var maxId = EMPTY_ID;
            var lastPos = disk.len;
            while (findPrevActiveSegment(disk, lastPos)) |activeSeg| {
                if (activeSeg.id < maxId) {
                    if (findEmptySegmentToFit(disk, activeSeg)) |empty| {
                        swap(disk, empty, activeSeg);
                    }
                    maxId = activeSeg.id;
                }
                lastPos = activeSeg.pos;
            }
        }

        fn checksum(disk: []TId) usize {
            var result: usize = 0;
            for (disk, 0..) |id, idx| {
                if (id == EMPTY_ID)
                    continue;
                result += id * idx;
            }
            return result;
        }

        fn findNextEmptyIdx(disk: []TId, filled: usize) usize {
            return std.mem.indexOfScalarPos(TId, disk, filled, EMPTY_ID).?;
        }
        fn findPrevActiveIdx(disk: []TId, active: usize) usize {
            var activeIdx = active - 1;
            while (disk[activeIdx] == EMPTY_ID) {
                activeIdx -= 1;
            }
            return activeIdx;
        }

        const Segment = struct {
            pos: usize,
            len: usize,
            id: TId,
        };

        fn findEmptySegmentToFit(disk: []const TId, segment: Segment) ?Segment {
            const PROTO_SEGMENT: [10]TId = .{
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
                EMPTY_ID,
            };

            if (std.mem.indexOf(TId, disk[0..segment.pos], PROTO_SEGMENT[0..segment.len])) |pos| {
                return Segment{
                    .pos = pos,
                    .len = segment.len,
                    .id = EMPTY_ID,
                };
            }
            return null;
        }
        fn findPrevActiveSegment(disk: []const TId, idx: usize) ?Segment {
            var pos = idx - 1;
            while (disk[pos] == EMPTY_ID) {
                pos -= 1;
            }
            const id = disk[pos];
            var len: usize = 0;
            while (pos > 0 and disk[pos] == id) {
                pos -= 1;
                len += 1;
            }
            if (len > 0)
                return Segment{ .id = id, .len = len, .pos = pos + 1 };
            return null;
        }
        fn swap(disk: []TId, a: Segment, b: Segment) void {
            for (0..a.len) |offset| {
                disk[a.pos + offset] = b.id;
                disk[b.pos + offset] = a.id;
            }
        }

        fn printDisk(disk: []const TId) void {
            for (disk) |id| {
                var c: u8 = undefined;
                if (id == EMPTY_ID) {
                    c = '.';
                } else if (id < 10) {
                    c = '0' + @as(u8, @intCast(id));
                } else {
                    c = 'x';
                }
                std.debug.print("{c}", .{c});
            }
            std.debug.print("\n", .{});
        }
    };
}

pub fn main() !void {
    try util.execSolution(Solution(u16), 20_001);
}
