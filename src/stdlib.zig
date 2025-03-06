const std = @import("std");
const builtin = @import("builtin");
const global = @import("global.zig");
const errno = @import("errno.zig");

const posix = std.posix;

const malloc = @import("alloc.zig").malloc;
const free = @import("alloc.zig").free;

pub export fn exit(status: c_int) callconv(.C) noreturn {
    {
        global.atexit_mutex.lock();
        defer global.atexit_mutex.unlock();
        global.atexit_started = true;
    }
    {
        var i = global.atexit_funcs.items.len;
        while (i != 0) : (i -= 1) {
            global.atexit_funcs.items[i - 1]();
        }
    }
    std.process.exit(@intCast(status));
}

const ExitFunc = switch (builtin.zig_backend) {
    .stage1 => fn () callconv(.C) void,
    else => *const fn () callconv(.C) void,
};

pub export fn atexit(func: global.ExitFunc) c_int {
    global.atexit_mutex.lock();
    defer global.atexit_mutex.unlock();

    if (global.atexit_started) {
        // storage.errno = std.c.E.PERM;
        errno.set_errno(errno.E.PERM);
        return -1;
    }

    global.atexit_funcs.append(global.gpa.allocator(), func) catch |e| switch (e) {
        error.OutOfMemory => {
            // storage.errno = std.c.E.NOMEM;
            errno.set_errno(errno.E.NOMEM);
            return -1;
        },
    };
    return 0;
}

pub export fn abort() callconv(.C) noreturn {
    @panic("abort");
}

// pub export fn setenv(name: [*:0]const u8, value: [*:0]const u8, overwrite: c_int) callconv(.C) c_int {
// }
//
// pub export fn unsetenv(name: [*:0]const u8) callconv(.C) c_int {
// }

pub export fn getenv(name: ?[*:0]const u8) callconv(.C) ?[*:0]u8 {
    const ename = name orelse return null;
    const slice_key = std.mem.sliceTo(ename, 0);

    for (std.os.environ) |line| {
        var line_i: usize = 0;
        while (line[line_i] != 0 and line[line_i] != '=') : (line_i += 1) {}
        const key = line[0..line_i];

        var end_i: usize = line_i;
        while (line[end_i] != 0) : (end_i += 1) {}
        const value = line[line_i + 1 .. end_i];

        if (std.mem.eql(u8, key, slice_key)) {
            // return value;
            return @ptrCast(value);
        }
    }
    return null;
}

pub const cstr = [*:0]u8;
pub const const_cstr = [*:0]const u8;

// pub export fn mktemp(name: [*:0]u8) callconv(.C) ?cstr {
// }
//
// pub export fn mkstemp(name: [*:0]u8) callconv(.C) c_int {
// }
//
// pub export fn mkostemp(name: [*:0]u8, n: c_int) callconv(.C) c_int {
// }
//
// pub export fn mkdtemp(name: [*:0]const u8) callconv(.C) ?cstr {
// }
//
// pub export fn rand_r(name: c_uint) callconv(.C) c_int {
// }

// pub export fn system(string: ?[*:0]const u8) callconv(.C) c_int {
//     if (string) |command| {
//         const cmd = std.mem.sliceTo(command, 0);
//         const argv = [3][:0]const u8{ "sh", "-c", cmd };
//         const alloc = global.gpa.allocator();
//
//         var child = std.process.Child.init(&argv, alloc);
//         child.spawn() catch return -1;
//         const exit_code = child.wait() catch return -1;
//
//         switch (exit_code) {
//             .Exited => return exit_code.Exited,
//             else => return -1,
//         }
//     } else {
//         return -1;
//     }
// }

pub export fn system(string: ?[*:0]const u8) callconv(.C) c_int {
    const shell: [:0]const u8 = switch (builtin.os.tag) {
        .windows => "pwsh.exe",
        else => "sh",
    };

    if (string) |command| {
        const pid_result = posix.fork() catch return -1;
        if (pid_result == 0) {
            const cmd = std.mem.sliceTo(command, 0);
            const argv = [3][:0]const u8{ shell, "-c", cmd };

            const allocator = global.gpa.allocator();
            var arena_allocator = std.heap.ArenaAllocator.init(allocator);
            defer arena_allocator.deinit();
            const arena = arena_allocator.allocator();

            const argv_buf = arena.allocSentinel(?[*:0]const u8, 3, null) catch return 3;
            for (argv, 0..) |arg, i| argv_buf[i] = (arena.dupeZ(u8, arg) catch return 1).ptr;

            const envp = @as([*:null]const ?[*:0]const u8, @ptrCast(std.os.environ.ptr));
            posix.execvpeZ_expandArg0(.expand, argv_buf.ptr[0].?, argv_buf.ptr, envp) catch return -1;
        }

        return 0;
    } else {
        return 1;
    }
}
