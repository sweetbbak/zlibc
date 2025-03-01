//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

pub const string = @import("string.zig");
pub usingnamespace string;

comptime {
    // TODO: figure out a method to not export unused stuff
    if (builtin.output_mode == .Lib) {
        _ = string;
    }
}

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub export fn __strlen(cstr: [*:0]u8) usize {
    return std.mem.len(cstr);
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
