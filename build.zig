const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const t = target.result;

    const upstream = b.dependency("upstream", .{});

    const lib = b.addLibrary(.{
        .name = "glfw",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    lib.root_module.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &glfw_src,
    });
    switch (t.os.tag) {
        .linux => {
            lib.root_module.addCSourceFiles(.{
                .root = upstream.path("src"),
                .files = &.{
                    "posix_time.c",
                    "posix_thread.c",
                    "posix_module.c",

                    "xkb_unicode.c",
                    "linux_joystick.c",
                    "posix_poll.c",

                    "x11_init.c",
                    "x11_monitor.c",
                    "x11_window.c",
                    "glx_context.c",

                    "wl_init.c",
                    "wl_monitor.c",
                    "wl_window.c",
                },
            });
            lib.root_module.addCMacro("_GLFW_X11", "1");
            lib.root_module.addCMacro("_GLFW_WAYLAND", "1");
            lib.root_module.addIncludePath(b.path("wayland"));
        },
        .windows => {
            lib.root_module.addCSourceFiles(.{
                .root = upstream.path("src"),
                .files = &.{
                    "wgl_context.c",
                    "win32_thread.c",
                    "win32_init.c",
                    "win32_monitor.c",
                    "win32_time.c",
                    "win32_joystick.c",
                    "win32_window.c",
                    "win32_module.c",
                },
            });
            lib.root_module.addCMacro("_GLFW_WIN32", "1");
            lib.root_module.linkSystemLibrary("gdi32", .{});
            lib.root_module.linkSystemLibrary("user32", .{});
            lib.root_module.linkSystemLibrary("shell32", .{});
        },
        else => {},
    }
    lib.installHeadersDirectory(upstream.path("include"), "", .{});
    b.installArtifact(lib);
}

const glfw_src = [_][]const u8{
    "platform.c",
    "monitor.c",
    "init.c",
    "vulkan.c",
    "input.c",
    "context.c",
    "window.c",
    "osmesa_context.c",
    "egl_context.c",
    "null_init.c",
    "null_monitor.c",
    "null_window.c",
    "null_joystick.c",
};
