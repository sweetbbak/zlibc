const std = @import("std");
const testing = std.testing;

pub export fn strlen1(cstr: [*:0]const c_char) usize {
    var i: usize = 0;
    while (cstr[i] != 0)
        i += 1;
    return i;
}

pub export fn strlen2(cstr: [*:0]u8) usize {
    var i: usize = 0;
    while (cstr[i] != 0)
        i += 1;
    return i;
}

pub export fn strlen(cstr: [*:0]u8) usize {
    return std.mem.len(cstr);
}

pub export fn memset(str: [*]void, c: c_int, n: usize) [*]void {
    const char_str: [*]u8 = @ptrCast(str);
    const char: u8 = @intCast(c);

    for (0..n) |i| {
        char_str[i] = char;
    }

    return @ptrCast(char_str);
}

pub export fn memmove(dest_raw: [*]u8, src_raw: [*]const u8, n: usize) [*]u8 {
    const dest = dest_raw[0..n];
    const src = src_raw[0..n];

    if (@intFromPtr(dest.ptr) <= @intFromPtr(src.ptr)) {
        std.mem.copyForwards(u8, dest, src);
    } else {
        std.mem.copyBackwards(u8, dest, src);
    }

    return dest.ptr;
}

pub export fn memcmp(s1: [*]const void, s2: [*]const void, n: usize) c_int {
    const byte_s1: [*]const u8 = @ptrCast(s1);
    const byte_s2: [*]const u8 = @ptrCast(s2);

    var i: usize = 0;
    while (i < n) : (i += 1) {
        if (byte_s1[i] < byte_s2[i]) {
            return -1;
        } else if (byte_s1[i] > byte_s2[i]) {
            return 1;
        }
    }
    return 0;
}

pub fn incrementPointer(comptime T: type, pointer: [*]void, offset: usize) T {
    if (offset >= 0) {
        return @ptrCast(@alignCast(pointer + offset));
    } else {
        return @ptrCast(@alignCast(pointer - offset));
        // return @ptrCast(@alignCast(pointer - @as(usize, @intCast(-offset))));
    }
}

pub export fn memchr(src: [*]const void, c: u8, n: usize) ?[*]void {
    const s: [*]const u8 = @ptrCast(src);
    const str: []const u8 = s[0..n];

    if (std.mem.indexOfScalar(u8, str, c)) |loc| {
        var val = @intFromPtr(src);
        val += loc;
        return @ptrFromInt(val);
    }
    return null;
}

pub fn zmemcpy(comptime T: type, dest: []T, src: []const T) void {
    _ = @memcpy(dest, src);
}

comptime {
    std.testing.refAllDecls(@This());
}
