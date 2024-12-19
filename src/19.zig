const std = @import("std");

const stdout = std.io.getStdOut().writer();

const input = @embedFile("input19.txt");

pub fn main() !void {
    std.debug.print("--- Day 19: Linen Layout ---\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try countDesigns(allocator, input);
    try stdout.print("{d}\n{d}\n", .{
        result.valid_designs,
        result.valid_arrangements,
    });
}

const Result = struct {
    valid_designs: u16,
    valid_arrangements: u16,
};

fn countDesigns(allocator: std.mem.Allocator, data: []const u8) !Result {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    // The first line is the list of available towel patterns.
    var patterns = std.ArrayList([]const u8).init(allocator);
    defer patterns.deinit();
    if (lines.next()) |line| {
        var pattern_it = std.mem.tokenizeSequence(u8, line, ", ");
        while (pattern_it.next()) |p| {
            try patterns.append(p);
        }
    } else {
        return error.MissingAvailableTowelPatterns;
    }

    // The remaining lines are all of the desired designs.
    //
    // Note that because we are using `std.mem.tokenizeScalar`, the blank line
    // separating the available towel patterns from the desired patterns is
    // automatically skipped.
    var designs: u16 = 0;
    var arrangements: u16 = 0;
    while (lines.next()) |design| {
        if (isValid(design, patterns.items)) designs += 1;
        arrangements += validArrangements(design, patterns.items);
    }

    return Result{
        .valid_designs = designs,
        .valid_arrangements = arrangements,
    };
}

fn validArrangements(design: []const u8, patterns: [][]const u8) u16 {
    var count: u16 = 0;
    for (patterns) |p| {
        if (std.mem.startsWith(u8, design, p) and isValid(design, patterns)) {
            count += validArrangements(design[p.len..], patterns);
        }
    }
    return count;
}

fn isValid(design: []const u8, patterns: [][]const u8) bool {
    for (patterns) |p| {
        // std.debug.print("\tDESIGN {s}\tPATTERN {s}\n", .{ design, p });

        // Skip to the next pattern.
        if (!std.mem.startsWith(u8, design, p)) continue;

        // Return true if we are at the end of the design.
        if (design.len == p.len) return true;

        if (!isValid(design[p.len..], patterns)) {
            // Keep going in case there is another potential pattern that
            // could be used.
            continue;
        }

        return true;
    }
    return false;
}

const example =
    \\r, wr, b, g, bwu, rb, gb, br
    \\
    \\brwrr
    \\bggr
    \\gbbr
    \\rrbgbr
    \\ubwu
    \\bwurrg
    \\brgr
    \\bbrgwb
;

test {
    const result = try countDesigns(std.testing.allocator, example);
    try std.testing.expectEqual(6, result.valid_designs);
    try std.testing.expectEqual(16, result.valid_arrangements);
}
