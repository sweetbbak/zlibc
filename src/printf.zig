const std = @import("std");

pub export fn printf(list_ptr: *std.ArrayList(u8), format: [*:0]const u8, ...) callconv(.C) void {
    var ap = @cVaStart();
    defer @cVaEnd(&ap);
    vprintf(list_ptr, format, &ap);
}

pub export fn vprintf(
    list: *std.ArrayList(u8),
    format: [*:0]const u8,
    ap: *std.builtin.VaList,
) callconv(.C) void {
    for (std.mem.span(format)) |c| switch (c) {
        's' => {
            const arg = @cVaArg(ap, [*:0]const u8);
            list.writer().print("{s}", .{arg}) catch return;
        },
        'd' => {
            const arg = @cVaArg(ap, c_int);
            list.writer().print("{d}", .{arg}) catch return;
        },
        else => unreachable,
    };
}

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
