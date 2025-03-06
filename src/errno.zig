const std = @import("std");
const builtin = @import("builtin");
const global = @import("global.zig");

pub const E = std.c.E;
pub usingnamespace std.c.E;

/// global errno
const storage = if (builtin.single_threaded)
    struct {
        var errno: c_int = 0; // regular variable on single-threaded systems
    }
else
    struct {
        threadlocal var errno: c_int = 0; // thread-local variable on multi-threaded systems
    };

pub fn set_errno(err: E) void {
    storage.errno = @intFromEnum(err);
}

pub export fn __errno_location() *c_int {
    return &storage.errno;
}

pub export fn __errno() *c_int {
    return &storage.errno;
}

pub export fn _errno() *c_int {
    return &storage.errno;
}

