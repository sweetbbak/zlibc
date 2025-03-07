const std = @import("std");
const builtin = @import("builtin");
const global = @import("global.zig");
const errno = @import("errno.zig");

const size_t = usize;
const FILE = opaque {};

pub export fn atoi(str: ?[*:0]const c_char) c_int {
    const s = str orelse return 0;

    var i: usize = 0;
    while (std.ascii.isWhitespace(@bitCast(s[i]))) {
        i += 1;
    }

    const slice = std.mem.sliceTo(s + i, 0);

    return std.fmt.parseInt(c_int, @ptrCast(slice), 10) catch return 0;
}

pub export fn reverse(buffer: [*]u8, len: usize) [*]u8 {
    var start: usize = 0;
    var end = len - 1;

    while (start < end) {
        const tmp = buffer[start];
        buffer[start] = buffer[end];
        buffer[end] = tmp;
        start += 1;
        end -= 1;
    }

    return buffer;
}

pub export fn sprintf(integer: usize, buffer: [*]u8, len: usize) c_int {
    const slice: []u8 = buffer[0..len];
    _ = std.fmt.bufPrint(slice, "{d}", .{integer}) catch return -1;
    return 0;
}

pub export fn itoa(integer: usize, buffer: [*]u8, radix: u8) c_int {
    var val = integer;
    var i: usize = 0;
    if (radix < 2 or radix > 34) return -1;

    if (val == 0) {
        buffer[i] = '0';
        buffer[i + 1] = 0;
        return 0;
    }

    while (val != 0) {
        const rem = val % radix;
        buffer[i] = @intCast(if (rem > 9) rem - 10 + 'a' else rem + '0');

        val /= radix;
        i += 1;
    }

    buffer[i] = 0;
    _ = reverse(buffer, i);
    return 0;
}

pub fn eql(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    for (a, 0..) |item, i| {
        if (item != b[i]) return false;
    }
    return true;
}

export fn zlibc_assert(
    assertion: ?[*:0]const u8,
    file: ?[*:0]const u8,
    line: c_uint,
) noreturn {
    switch (builtin.mode) {
        .Debug, .ReleaseSafe => {
            var buf: [256]u8 = undefined;
            const str = std.fmt.bufPrint(&buf, "assertion failed: '{?s}' in file {?s} line {}", .{ assertion, file, line }) catch {
                @panic("assertion failed");
            };
            @panic(str);
        },
        .ReleaseSmall => @panic("assertion failed"),
        .ReleaseFast => unreachable,
    }
}
