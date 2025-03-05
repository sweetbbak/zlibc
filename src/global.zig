const std = @import("std");
const builtin = @import("builtin");

/// default rand
pub var rand: std.rand.DefaultPrng = undefined;

/// a global allocator
pub var gpa = std.heap.GeneralPurposeAllocator(.{
    .MutexType = std.Thread.Mutex,
}){};

pub var strtok_ptr: ?[*:0]u8 = undefined;

pub var atexit_mutex = std.Thread.Mutex{};
pub var atexit_started = false;
pub var atexit_funcs: std.ArrayListUnmanaged(ExitFunc) = .{};

pub const ExitFunc = switch (builtin.zig_backend) {
    .stage1 => fn () callconv(.C) void,
    else => *const fn () callconv(.C) void,
};

/// emulate C loops like:
/// int i = 100; while (i) { i-- };
pub fn cBool(number: anytype) bool {
    switch (@TypeOf(number)) {
        u8,
        u16,
        u32,
        usize,
        i8,
        i16,
        i32,
        isize,
        c_int,
        c_char,
        c_long,
        c_longdouble,
        c_longlong,
        c_ulong,
        c_uint,
        c_ulonglong,
        c_ushort,
        c_short,
        comptime_int,
        => {
            return number != 0;
        },
        else => @compileError("expected type to be any integer (u8 -> usize, i8 -> isize, c_char -> c_ulonglong, comptime_int, etc)"),
    }
}

test "c boolean" {
    {
        var i: i32 = 33;
        while (cBool(i)) {
            std.debug.print("{d}\n", .{i});
            i -= 1;
        }
    }
    {
        var i: i32 = -33;
        while (cBool(i)) {
            std.debug.print("{d}\n", .{i});
            i += 1;
        }
    }
    {
        var i: c_char = -33;
        while (cBool(i)) {
            std.debug.print("{d}\n", .{i});
            i += 1;
        }
    }
}
