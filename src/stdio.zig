const std = @import("std");

pub const stdin = 0;
pub const stdout = 1;
pub const stderr = 2;

/// default buffer size
const BUFSIZE = 8192;

/// The value returned by fgetc and similar functions to indicate the
/// end of the file.
pub const EOF = -1;

/// Seek from beginning of file.
pub const SEEK_SET = 0;
/// Seek from current position.
pub const SEEK_CUR = 1;
/// Seek from end of file.
pub const SEEK_END = 2;

pub const L_tmpnam = 20;
pub const TMP_MAX = 238328;

/// print the following string to stdout with a newline
pub export fn puts(buf: ?[*:0]const u8) callconv(.C) c_int {
    const sbuf = buf orelse return -1;
    const writer = std.io.getStdOut().writer();
    const n = std.mem.len(sbuf);
    _ = writer.write(sbuf[0..n]) catch return EOF;
    _ = writer.writeByte('\n') catch return EOF;

    return 0;
}

/// print the following string to stdout without a newline
pub export fn put(buf: [*:0]const u8) callconv(.C) c_int {
    const writer = std.io.getStdOut().writer();
    const n = std.mem.len(buf);
    _ = writer.write(buf[0..n]) catch return EOF;
    return 0;
}

/// print a single character to stdout
pub export fn putchar(char: u8) callconv(.C) c_int {
    const writer = std.io.getStdOut().writer();
    _ = writer.writeByte(char) catch return EOF;
    return 0;
}

// pub export fn fputs(buf: [*:0]const u8, file: *std.c.FILE) callconv(.C) void {
//     const writer = std.io.getStdOut().writer();
//     const n = std.mem.len(buf);
//     std.posix.write(file, );
//     _ = writer.write(buf[0..n]) catch return;
//     _ = writer.writeByte('\n') catch return;
// }
