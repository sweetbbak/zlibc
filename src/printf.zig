const std = @import("std");
const stdio = @import("stdio.zig");
const linux = std.os.linux;
const posix = std.posix;
const fd_t = posix.fd_t;
const File = std.fs.File;

const stdout = stdio.stdout;

pub fn getFile(fd: fd_t) File {
    return .{ .handle = fd };
}

pub export fn printf(format: [*:0]const u8, ...) callconv(.C) c_int {
    var ap = @cVaStart();
    defer @cVaEnd(&ap);
    const ret = vfprintf(stdout, format, &ap);
    return ret;
}

// pub export fn dprintf(
//     fd: fd_t,
//     format: [*:0]const u8,
//     ...
// ) callconv(.C) void {
// }

pub export fn vprintf(
    format: [*:0]const u8,
    ap: *std.builtin.VaList,
) callconv(.C) c_int {
    return vfprintf(stdout, format, ap);
}

pub export fn vfprintf(
    fd: fd_t,
    format: [*:0]const u8,
    app: *std.builtin.VaList,
) callconv(.C) c_int {
    const file = getFile(fd);
    const writer = file.writer();

    var is_percent: bool = false;
    var ap = @cVaCopy(app);
    // var ap = &_ap;
    // _ = &ap;

    for (std.mem.span(format)) |c| switch (c) {
        's' => {
            if (!is_percent) continue;
            defer is_percent = false;

            const arg = @cVaArg(&ap, [*:0]const u8);
            writer.print("{s}", .{arg}) catch return -1;
        },
        'd', 'f' => {
            if (!is_percent) continue;
            defer is_percent = false;

            const arg = @cVaArg(&ap, c_int);
            writer.print("{d}", .{arg}) catch return -1;
        },
        'x' => {
            if (!is_percent) continue;
            defer is_percent = false;

            const arg = @cVaArg(&ap, c_int);
            writer.print("{x}", .{arg}) catch return -1;
        },
        'e' => {
            if (!is_percent) continue;
            defer is_percent = false;

            const arg = @cVaArg(&ap, f32);
            writer.print("{e}", .{arg}) catch return -1;
        },
        'v' => {
            if (!is_percent) continue;
            defer is_percent = false;

            const arg = @cVaArg(&ap, u64);
            writer.print("{}", .{std.fmt.fmtIntSizeDec(arg)}) catch return -1;
        },
        '*' => {
            if (!is_percent) continue;
            defer is_percent = false;

            const arg = @cVaArg(&ap, ?*anyopaque);
            writer.print("{*}", .{arg}) catch return -1;
        },
        '%' => is_percent = true,
        else => {
            writer.writeByte(c) catch return -1;
        },
    };
    return 0;
}


// pub export fn xprintf(list_ptr: *std.ArrayList(u8), format: [*:0]const u8, ...) callconv(.C) void {
//     var ap = @cVaStart();
//     defer @cVaEnd(&ap);
//     vprintf(list_ptr, format, &ap);
// }

// pub export fn vprintf(
//     list: *std.ArrayList(u8),
//     format: [*:0]const u8,
//     ap: *std.builtin.VaList,
// ) callconv(.C) void {
//     for (std.mem.span(format)) |c| switch (c) {
//         's' => {
//             const arg = @cVaArg(ap, [*:0]const u8);
//             list.writer().print("{s}", .{arg}) catch return;
//         },
//         'd' => {
//             const arg = @cVaArg(ap, c_int);
//             list.writer().print("{d}", .{arg}) catch return;
//         },
//         else => unreachable,
//     };
// }

// pub export fn printf(
//     format: [*:0]const u8,
//     ap: *std.builtin.VaList,
// ) callconv(.C) void {
//     const fmt = std.mem.span(format);
//     _ = fmt;
//     const args = @cVaArg(ap, @TypeOf(format));
//
//     // var buf: [512]u8 = undefined;
//     // const buf_slice = std.fmt.bufPrint(&buf, fmt, .{args}) catch {
//     //     std.log.debug("couldnt format string", .{});
//     //     @panic("*** format_string1 error: buf too small");
//     // };
//
//     const w = std.io.getStdErr().writer();
//     w.print("{s}", .{args}) catch return;
//     // std.debug.print(fmt, .{args});
// }

// pub export fn vprintf(
//     list: *std.ArrayList(u8),
//     format: [*:0]const u8,
//     ap: *std.builtin.VaList,
// ) callconv(.C) void {
//     for (std.mem.span(format)) |c| switch (c) {
//         's' => {
//             const arg = @cVaArg(ap, [*:0]const u8);
//             list.writer().print("{s}", .{arg}) catch return;
//         },
//         'd' => {
//             const arg = @cVaArg(ap, c_int);
//             list.writer().print("{d}", .{arg}) catch return;
//         },
//         else => unreachable,
//     };
// }
