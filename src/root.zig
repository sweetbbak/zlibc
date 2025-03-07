const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

// pub usingnamespace string;
// pub const start = @import("_start.zig");
pub const libc = @import("glibc-start.zig");
pub const string = @import("string.zig");
pub const cstd = @import("cstd.zig");
pub const global = @import("global.zig");
pub const stdlib = @import("stdlib.zig");
pub const errno = @import("errno.zig");
pub const math = @import("math.zig");
pub const ctype = @import("ctype.zig");
pub const malloc = @import("alloc.zig");
pub const printf = @import("printf.zig");

pub var elf_aux_maybe: ?[*]std.elf.Auxv = null;
pub fn getauxval(index: usize) callconv(.C) usize {
    const auxv = elf_aux_maybe orelse return 0;
    var i: usize = 0;
    while (auxv[i].a_type != std.elf.AT_NULL) : (i += 1) {
        if (auxv[i].a_type == index)
            return auxv[i].a_un.a_val;
    }
    return 0;
}


comptime {
    @export(&getauxval, .{ .linkage = .strong, .name = "getauxval" });

    // TODO: figure out a method to not export unused stuff
    if (builtin.output_mode == .Lib) {
        _ = std.os.linux.getauxval;
        // _ = start;
        _ = libc;
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
