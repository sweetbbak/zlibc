//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

// pub usingnamespace string;
pub const string = @import("string.zig");
pub const cstd = @import("cstd.zig");
pub const global = @import("global.zig");
pub const stdlib = @import("stdlib.zig");
pub const errno = @import("errno.zig");
pub const math = @import("math.zig");
pub const ctype = @import("ctype.zig");
pub const malloc = @import("alloc.zig");
pub const printf = @import("printf.zig");

comptime {
    // TODO: figure out a method to not export unused stuff
    if (builtin.output_mode == .Lib) {
        _ = string;
        _ = cstd;
        _ = global;
        _ = stdlib;
        _ = errno;
        _ = math;
        _ = ctype;
        _ = malloc;
        _ = printf.printf;
    }
}
