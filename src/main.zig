const std = @import("std");
const lib = @import("zlibc_lib");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const s = "hello!";
    const str = try allocator.dupe(u8, s);

    const len = lib.strlen(@ptrCast(str));
    std.debug.print("strlen: {d}\n", .{len});
}
