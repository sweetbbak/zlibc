const std = @import("std");
const lib = @import("zlibc_lib");
const string = lib.string;
const cstd = lib.cstd;
const global = lib.global;
const stdlib = lib.stdlib;
const errno = lib.errno;
const math = lib.math;
const ctype = lib.ctype;
const malloc = lib.malloc;

const strlen = lib.string.strlen;
const strncat = lib.string.strncat;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const s = "hello!";
    const _str = try allocator.dupeZ(u8, s);
    defer allocator.free(_str);

    const str: [*:0]const u8 = @ptrCast(_str);
    const len = strlen(str);

    std.debug.print("strlen: {d}\n", .{len});
    std.debug.print("strlen: {d}\n", .{strlen(@as([*:0]const u8, @ptrCast(@constCast(str))))});
    std.debug.print("strlen: {d}\n", .{strlen(@as([*:0]const u8, @ptrCast(@constCast("hello world!"))))});

    const _src = "world!";
    const _dest = "hello ";

    const src = try allocator.dupeZ(u8, _src);
    defer allocator.free(src);

    const dest = try allocator.dupeZ(u8, _dest);
    defer allocator.free(dest);

    const output = strncat(dest, src, strlen(dest));

    // const output = strncat(&dest, &src, strlen(dest));
    std.debug.print("strncat: {s}\n", .{std.mem.span(output)});

    var mem = malloc.malloc(10);
    defer malloc.free(mem);
    var block: []u8 = @ptrCast(mem.?[0..10]);

    const fd = try std.posix.open("/dev/urandom", .{}, 0o644);
    const n = try std.posix.read(fd, block);
    std.debug.print("read: {d} - {any}\n", .{n, block[0..n]});


    // run a command
    // _ = stdlib.system("ls -lah");
}
