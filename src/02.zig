const std = @import("std");

// const input = @embedFile("test02.txt");
const input = @embedFile("input02.txt");

pub fn main() !void {
    try std.io.getStdOut().writer().print("{d}\n", .{try part1()});
    try std.io.getStdOut().writer().print("{d}\n", .{try part2()});
}

fn part1() !usize {
    var safe_reports: usize = 0;

    var reports_iter = std.mem.tokenizeScalar(u8, input, '\n');
    reports: while (reports_iter.next()) |report| {
        // Parse the first number to get the current level.
        var level_iter = std.mem.tokenizeScalar(u8, report, ' ');
        var current_level = try std.fmt.parseInt(i16, level_iter.next().?, 10);
        var current_difference: i16 = 0;

        // Parse each of the successive levels, and make sure it is increasing
        // or decreasing by 1, 2, or 3.
        while (level_iter.next()) |level| {
            const v = try std.fmt.parseInt(i16, level, 10);
            const difference = v - current_level;

            if (difference == 0) continue :reports;
            if (difference > 3) continue :reports;
            if (difference < -3) continue :reports;

            // We also need to make sure the levels are steadily decreasing,
            // or increasing.
            if (difference < 0 and current_difference > 0) continue :reports;
            if (difference > 0 and current_difference < 0) continue :reports;

            current_level = v;
            current_difference = difference;
        }

        safe_reports += 1;
    }

    return safe_reports;
}

// Part 2 is the same as part 1, but allows a single bad level in the report.
fn part2() !usize {
    var safe_reports: usize = 0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var reports_iter = std.mem.tokenizeScalar(u8, input, '\n');
    while (reports_iter.next()) |report| {
        var levels = std.ArrayList(i16).init(allocator);
        defer levels.deinit();

        var level_iter = std.mem.tokenizeScalar(u8, report, ' ');
        while (level_iter.next()) |level| {
            const v = try std.fmt.parseInt(i16, level, 10);
            try levels.append(v);
        }

        if (isValidReport(levels.items) or try canBecomeValidReport(allocator, levels.items)) safe_reports += 1;

        levels.deinit();
    }

    return safe_reports;
}

fn isValidReport(levels: []i16) bool {
    if (levels.len < 2) return true;

    const increasing: bool = levels[1] > levels[0];

    const initial_difference = @abs(levels[1] - levels[0]);
    if (initial_difference < 1 or initial_difference > 3) return false;

    for (1..levels.len - 1) |i| {
        const current = levels[i];
        const next = levels[i + 1];

        const diff = next - current;
        if ((diff > 0) != increasing) return false;

        if (@abs(diff) < 1 or @abs(diff) > 3) return false;
    }

    return true;
}

// Progressively removes an element from `levels` to see if excluding that
// element would result in a valid report.
fn canBecomeValidReport(allocator: std.mem.Allocator, levels: []i16) !bool {
    for (0..levels.len) |i| {
        var list = std.ArrayList(i16).init(allocator);

        for (0..levels.len) |j| {
            if (j == i) continue;
            try list.append(levels[j]);
        }

        if (isValidReport(list.items)) return true;

        list.deinit();
    }
    return false;
}
