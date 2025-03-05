const std = @import("std");

pub export fn isalnum(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isAlphanumeric(std.math.cast(u8, char) orelse return 0));
}

pub export fn toupper(char: c_int) callconv(.C) c_int {
    return std.ascii.toUpper(std.math.cast(u8, char) orelse return char);
}

pub export fn tolower(char: c_int) callconv(.C) c_int {
    return std.ascii.toLower(std.math.cast(u8, char) orelse return char);
}

pub export fn isspace(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isWhitespace(std.math.cast(u8, char) orelse return 0));
}

pub export fn isxdigit(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isHex(std.math.cast(u8, char) orelse return 0));
}

pub export fn iscntrl(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isControl(std.math.cast(u8, char) orelse return 0));
}

pub export fn isdigit(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isDigit(std.math.cast(u8, char) orelse return 0));
}

pub export fn isalpha(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isAlphabetic(std.math.cast(u8, char) orelse return 0));
}

pub export fn isgraph(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isPrint(std.math.cast(u8, char) orelse return 0));
}

pub export fn islower(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isLower(std.math.cast(u8, char) orelse return 0));
}

pub export fn isupper(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isUpper(std.math.cast(u8, char) orelse return 0));
}

pub export fn ispunct(char: c_int) callconv(.C) c_int {
    const c_u8 = std.math.cast(u8, char) orelse return 0;
    return @intFromBool(std.ascii.isPrint(c_u8) and !std.ascii.isAlphanumeric(c_u8));
}

pub export fn isprint(char: c_int) callconv(.C) c_int {
    return @intFromBool(std.ascii.isPrint(std.math.cast(u8, char) orelse return 0));
}
