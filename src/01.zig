const std = @import("std");

const input = @embedFile("input01.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var left = std.ArrayList(u32).init(allocator);
    var right = std.ArrayList(u32).init(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        // std.debug.print("LINE: {s}\n", .{line});

        var row = std.mem.tokenizeScalar(u8, line, ' ');
        const left_value = try std.fmt.parseInt(u32, row.next().?, 10);
        const right_value = try std.fmt.parseInt(u32, row.next().?, 10);

        try left.append(left_value);
        try right.append(right_value);
    }

    std.mem.sort(u32, left.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, comptime std.sort.asc(u32));

    var total_distance: usize = 0;
    for (left.items, right.items) |a, b| {
        total_distance += if (a > b) a - b else b - a;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total_distance});

    var similarity: usize = 0;
    for (left.items) |l| {
        var occurrences: usize = 0;
        for (right.items) |r| {
            if (l == r) occurrences += 1;
        }
        similarity += l * occurrences;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{similarity});
}
