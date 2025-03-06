const std = @import("std");
const testing = std.testing;
const builtin = @import("builtin");
const global = @import("global.zig");
const errno = @import("errno.zig");

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

pub export fn strnlen(s: [*:0]const u8, max_len: usize) usize {
    var i: usize = 0;
    while (i < max_len and s[i] != 0) : (i += 1) {}
    return i;
}

/// convert Zig string to a C string
pub fn to_cstring(str: anytype) ![*:0]c_char {
    return @as([*:0]c_char, @ptrCast(@constCast(str)));
}

// pub export fn strncat(dest: [*:0]u8, src: [*:0]const u8, maxlen: usize) callconv(.C) [*:0]u8 {
//     const dest_len = std.mem.len(src);
//     const src_len = std.mem.len(dest);
//
//     const copy_len = if (src_len > maxlen) src_len else maxlen;
//     const n = @intFromPtr(dest) + dest_len;
//
//     const dest_pos: [*:0]u8 = @ptrFromInt(n);
//     @memcpy(dest_pos, src[0..copy_len]);
//
//     dest[n] = 0;
//     return @ptrCast(dest);
// }

pub export fn strncat(s1: [*:0]u8, s2: [*:0]const u8, n: usize) callconv(.C) [*:0]u8 {
    const dest = s1 + strlen(s1);
    var i: usize = 0;
    while (s2[i] != 0 and i < n) : (i += 1) {
        dest[i] = s2[i];
    }
    dest[i] = 0;
    return s1;
}

pub export fn strncmp(a: [*:0]const u8, b: [*:0]const u8, n: usize) callconv(.C) c_int {
    var i: usize = 0;
    while (a[i] == b[i] and a[0] != 0) : (i += 1) {
        if (i == n - 1) return 0;
    }
    return @as(c_int, @intCast(a[i])) -| @as(c_int, @intCast(b[i]));
}

pub export fn strchr(s: [*:0]const u8, char: c_int) callconv(.C) ?[*:0]const u8 {
    var next = s;
    while (true) : (next += 1) {
        if (next[0] == char) return next;
        if (next[0] == 0) return null;
    }
}

pub export fn strrchr(s: [*:0]const u8, char: c_int) callconv(.C) ?[*:0]const u8 {
    var next = s + strlen(s);
    while (true) {
        if (next[0] == char) return next;
        if (next == s) return null;
        next = next - 1;
    }
}

pub export fn strstr(s1: [*:0]const u8, s2: [*:0]const u8) callconv(.C) ?[*:0]const u8 {
    const s1_len = strlen(s1);
    const s2_len = strlen(s2);
    var i: usize = 0;
    while (i + s2_len <= s1_len) : (i += 1) {
        const search = s1 + i;
        if (0 == strncmp(search, s2, s2_len)) return search;
    }
    return null;
}

pub export fn strcpy(s1: [*]u8, s2: [*:0]const u8) callconv(.C) [*:0]u8 {
    @memcpy(s1[0 .. std.mem.len(s2) + 1], s2);
    return @as([*:0]u8, @ptrCast(s1)); // TODO: use std.meta.assumeSentinel if it's brought back
}

// TODO: find out which standard this function comes from
pub export fn strncpy(s1: [*]u8, s2: [*:0]const u8, n: usize) callconv(.C) [*]u8 {
    const len = strnlen(s2, n);
    @memcpy(s1[0..len], s2);
    @memset(s1[len..][0 .. n - len], 0);
    return s1;
}

// pub export fn memset(str: [*]void, c: c_int, n: usize) callconv(.C) [*]void {
// pub export fn memset(str: [*]void, c: c_int, n: usize) callconv(.C) ?*anyopaque {
// pub export fn memset(str: *anyopaque, c: c_int, n: usize) callconv(.C) ?*anyopaque {
//     @setRuntimeSafety(false);
//     const char_str: [*]u8 = @ptrCast(str);
//     const char: u8 = @intCast(c);
//     // @memset(char_str[0..n], char);
//
//     for (0..n) |i| {
//         char_str[i] = char;
//     }
//
//     return @ptrCast(char_str);
// }

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

pub export fn memset(dest: ?[*]u8, c2: u8, len: usize) callconv(.C) ?[*]u8 {
    @setRuntimeSafety(false);

    if (len != 0) {
        var d = dest.?;
        var n = len;
        while (true) {
            d[0] = c2;
            n -= 1;
            if (n == 0) break;
            d += 1;
        }
    }

    return dest;
}

pub export fn memcpy(noalias dest: ?[*]u8, noalias src: ?[*]const u8, len: usize) callconv(.C) ?[*]u8 {
    @setRuntimeSafety(false);

    if (len != 0) {
        var d = dest.?;
        var s = src.?;
        var n = len;
        while (true) {
            d[0] = s[0];
            n -= 1;
            if (n == 0) break;
            d += 1;
            s += 1;
        }
    }

    return dest;
}

pub export fn strcmp(a: [*:0]const u8, b: [*:0]const u8) callconv(.C) c_int {
    var a_next = a;
    var b_next = b;
    while (a_next[0] == b_next[0] and a_next[0] != 0) {
        a_next += 1;
        b_next += 1;
    }
    const result = @as(c_int, @intCast(a_next[0])) -| @as(c_int, @intCast(b_next[0]));
    return result;
}

pub export fn strtoull(nptr: [*:0]const u8, endptr: ?*[*:0]const u8, base: c_int) callconv(.C) c_ulonglong {
    return strto(c_ulonglong, nptr, endptr, base);
}

pub fn strto(comptime T: type, str: [*:0]const u8, optional_endptr: ?*[*:0]const u8, optional_base: c_int) T {
    var next = str;

    // skip whitespace
    while (std.ascii.isWhitespace(next[0])) : (next += 1) {}
    // const start = next;
    // _ = start; // autofix

    const sign: enum { pos, neg } = blk: {
        if (next[0] == '-') {
            next += 1;
            break :blk .neg;
        }
        if (next[0] == '+') next += 1;
        break :blk .pos;
    };

    const base = blk: {
        if (optional_base != 0) {
            if (optional_base > 36) {
                if (optional_endptr) |endptr| endptr.* = next;
                errno.set_errno(errno.E.INVAL);
                return 0;
            }
            if (optional_base == 16 and next[0] == '0' and (next[1] == 'x' or next[1] == 'X')) {
                next += 2;
            }
            break :blk @as(u8, @intCast(optional_base));
        }
        if (next[0] == '0') {
            if (next[1] == 'x' or next[1] == 'X') {
                next += 2;
                break :blk 16;
            }
            next += 1;
            break :blk 8;
        }
        break :blk 10;
    };

    const digit_start = next;
    var x: T = 0;

    while (true) : (next += 1) {
        const ch = next[0];
        if (ch == 0) break;
        const digit = std.math.cast(T, std.fmt.charToDigit(ch, base) catch break) orelse {
            if (optional_endptr) |endptr| endptr.* = next;
            errno.set_errno(errno.E.RANGE);
            return 0;
        };
        if (x != 0) x = std.math.mul(T, x, std.math.cast(T, base) orelse {
            errno.set_errno(errno.E.INVAL);
            return 0;
        }) catch {
            if (optional_endptr) |endptr| endptr.* = next;
            errno.set_errno(errno.E.RANGE);
            return switch (sign) {
                .neg => std.math.minInt(T),
                .pos => std.math.maxInt(T),
            };
        };
        x = switch (sign) {
            .pos => std.math.add(T, x, digit) catch {
                if (optional_endptr) |endptr| endptr.* = next + 1;
                errno.set_errno(errno.E.RANGE);
                return switch (sign) {
                    .neg => std.math.minInt(T),
                    .pos => std.math.maxInt(T),
                };
            },
            .neg => std.math.sub(T, x, digit) catch {
                if (optional_endptr) |endptr| endptr.* = next + 1;
                errno.set_errno(errno.E.RANGE);
                return switch (sign) {
                    .neg => std.math.minInt(T),
                    .pos => std.math.maxInt(T),
                };
            },
        };
    }

    if (optional_endptr) |endptr| endptr.* = next;

    if (next == digit_start) {
        errno.set_errno(errno.E.INVAL);
    }

    return x;
}
