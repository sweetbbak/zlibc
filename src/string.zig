const std = @import("std");
const testing = std.testing;

pub export fn strlen2(cstr: [*:0]u8) callconv(.C) usize {
    var i: usize = 0;
    while (cstr[i] != 0)
        i += 1;
    return i;
}

pub export fn strlen(cstr: [*:0]const u8) callconv(.C) usize {
    return std.mem.len(cstr);
}

pub export fn _strlen(cstr: [*:0]const c_char) callconv(.C) usize {
    return std.mem.len(cstr);
}

fn strnlen(s: [*:0]const u8, max_len: usize) usize {
    var i: usize = 0;
    while (i < max_len and s[i] != 0) : (i += 1) {}
    return i;
}

/// convert Zig string to a C string
pub fn to_cstring(str: anytype) ![*:0]c_char {
    return @as([*:0]c_char, @ptrCast(@constCast(str)));
}

pub export fn strncat(dest: [*:0]u8, src: [*:0]const u8, maxlen: usize) callconv(.C) [*:0]u8 {
    const dest_len = std.mem.len(src);
    const src_len = std.mem.len(dest);

    const copy_len = if (src_len > maxlen) src_len else maxlen;
    const n = @intFromPtr(dest) + dest_len;

    const dest_pos: [*:0]u8 = @ptrFromInt(n);
    @memcpy(dest_pos, src[0..copy_len]);

    dest[n] = 0;
    return @ptrCast(dest);
}

pub export fn strncmp(a: [*:0]const u8, b: [*:0]const u8, n: usize) callconv(.C) c_int {
    var i: usize = 0;
    while (a[i] == b[i] and a[0] != 0) : (i += 1) {
        if (i == n - 1) return 0;
    }
    return @as(c_int, @intCast(a[i])) -| @as(c_int, @intCast(b[i]));
}

export fn strchr(s: [*:0]const u8, char: c_int) callconv(.C) ?[*:0]const u8 {
    var next = s;
    while (true) : (next += 1) {
        if (next[0] == char) return next;
        if (next[0] == 0) return null;
    }
}

export fn strrchr(s: [*:0]const u8, char: c_int) callconv(.C) ?[*:0]const u8 {
    var next = s + strlen(s);
    while (true) {
        if (next[0] == char) return next;
        if (next == s) return null;
        next = next - 1;
    }
}

export fn strstr(s1: [*:0]const u8, s2: [*:0]const u8) callconv(.C) ?[*:0]const u8 {
    const s1_len = strlen(s1);
    const s2_len = strlen(s2);
    var i: usize = 0;
    while (i + s2_len <= s1_len) : (i += 1) {
        const search = s1 + i;
        if (0 == strncmp(search, s2, s2_len)) return search;
    }
    return null;
}

export fn strcpy(s1: [*]u8, s2: [*:0]const u8) callconv(.C) [*:0]u8 {
    @memcpy(s1[0 .. std.mem.len(s2) + 1], s2);
    return @as([*:0]u8, @ptrCast(s1)); // TODO: use std.meta.assumeSentinel if it's brought back
}

// TODO: find out which standard this function comes from
export fn strncpy(s1: [*]u8, s2: [*:0]const u8, n: usize) callconv(.C) [*]u8 {
    const len = strnlen(s2, n);
    @memcpy(s1[0..len], s2);
    @memset(s1[len..][0 .. n - len], 0);
    return s1;
}

pub export fn memset(str: [*]void, c: c_int, n: usize) callconv(.C) [*]void {
    const char_str: [*]u8 = @ptrCast(str);
    const char: u8 = @intCast(c);
    // @memset(char_str[0..n], char);

    for (0..n) |i| {
        char_str[i] = char;
    }

    return @ptrCast(char_str);
}

pub export fn memmove(dest_raw: [*]u8, src_raw: [*]const u8, n: usize) callconv(.C) [*]u8 {
    const dest = dest_raw[0..n];
    const src = src_raw[0..n];

    if (@intFromPtr(dest.ptr) <= @intFromPtr(src.ptr)) {
        std.mem.copyForwards(u8, dest, src);
    } else {
        std.mem.copyBackwards(u8, dest, src);
    }

    return dest.ptr;
}

pub export fn memcmp(s1: [*]const void, s2: [*]const void, n: usize) callconv(.C) c_int {
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

pub export fn memchr(src: [*]const void, c: u8, n: usize) callconv(.C) ?[*]void {
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

// comptime {
//     std.testing.refAllDecls(@This());
// }
