const std = @import("std");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    std.debug.print("--- Day 7: Bridge Repair ---\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try stdout.print("{d}\n", .{try part1(allocator, input)});
    try stdout.print("{d}\n", .{try part2(allocator, input)});
}

const input = @embedFile("input07.txt");

fn part1(allocator: std.mem.Allocator, data: []const u8) !u64 {
    var total: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ':');

        const left = it.next() orelse unreachable;
        const right = it.next() orelse unreachable;

        var terms = std.ArrayList(u64).init(allocator);
        defer terms.deinit();
        var terms_iter = std.mem.tokenizeScalar(u8, right, ' ');
        while (terms_iter.next()) |term| {
            const t = try std.fmt.parseInt(u64, term, 10);
            try terms.append(t);
        }

        const target = try std.fmt.parseInt(u64, left, 10);

        if (solve(target, 0, terms.items)) total += target;
    }

    return total;
}

fn solve(target: u64, temp: u64, terms: []u64) bool {
    return switch (terms.len) {
        0 => target == temp,
        else => solve(target, temp + terms[0], terms[1..]) or
            solve(target, temp * terms[0], terms[1..]),
    };
}

fn part2(allocator: std.mem.Allocator, data: []const u8) !u64 {
    var total: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ':');

        const left = it.next() orelse unreachable;
        const right = it.next() orelse unreachable;

        var terms = std.ArrayList(u64).init(allocator);
        defer terms.deinit();
        var terms_iter = std.mem.tokenizeScalar(u8, right, ' ');
        while (terms_iter.next()) |term| {
            const t = try std.fmt.parseInt(u64, term, 10);
            try terms.append(t);
        }

        const target = try std.fmt.parseInt(u64, left, 10);

        if (solve2(target, 0, terms.items)) total += target;
    }

    return total;
}

fn solve2(target: u64, temp: u64, terms: []u64) bool {
    return switch (terms.len) {
        0 => target == temp,
        else => solve2(target, temp + terms[0], terms[1..]) or
            solve2(target, temp * terms[0], terms[1..]) or
            solve2(target, concat(temp, terms[0]), terms[1..]),
    };
}

// I have no idea what this function is doing.
//
// Copied from https://ziggit.dev/t/aoc-2024-day-7/7196/2
fn concat(a: u64, b: u64) u64 {
    const b_len = std.math.log10_int(b) + 1;
    // std.debug.print("log10_int(b) + 1 = {d}\n", .{b_len});
    const exp = std.math.powi(u64, 10, b_len) catch unreachable;
    // std.debug.print("powi({d}) = {d}\n", .{ b_len, exp });
    // std.debug.print("{d} * {d} + {d} = {d}\n", .{ a, exp, b, a * exp + b });
    return a * exp + b;
}

test "concat" {
    try std.testing.expectEqual(1024, concat(10, 24));
}

const sample =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;

test "part 1" {
    const result = try part1(std.testing.allocator, sample);
    try std.testing.expectEqual(3749, result);
}

test "part 2" {
    const result = try part2(std.testing.allocator, sample);
    try std.testing.expectEqual(11387, result);
}
