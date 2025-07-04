pub fn main() !void {
    var arena_state: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = try std.process.argsAlloc(arena);

    if (args.len != 3) return error.BadUsage;
    const actual_path = args[1];
    const expected_path = args[2];

    const actual = try std.fs.cwd().readFileAlloc(arena, actual_path, 1024 * 1024);
    const expected = try std.fs.cwd().readFileAlloc(arena, expected_path, 1024 * 1024);

    // The actual output starts with a comment which we should strip out before comparing.
    const comment_str = "/* This file was generated by ConfigHeader using the Zig Build System. */\n";
    if (!std.mem.startsWith(u8, actual, comment_str)) {
        return error.MissingOrMalformedComment;
    }
    const actual_without_comment = actual[comment_str.len..];

    if (!std.mem.eql(u8, actual_without_comment, expected)) {
        return error.DoesNotMatch;
    }
}
const std = @import("std");
