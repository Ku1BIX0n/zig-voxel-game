const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "game",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zalgebra_dep = b.dependency("zalgebra", .{
        .target = target,
        .optimize = optimize,
    });

    const zalgebra_module = zalgebra_dep.module("zalgebra");
    exe.root_module.addImport("zalgebra", zalgebra_module);
    // exe.linkLibrary(zalgebra_module);

    exe.linkLibC();
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("GL");

    b.installArtifact(exe);

    exe.addIncludePath(b.path("libs/glad/"));
    exe.addIncludePath(b.path("libs/stb/"));
    exe.addIncludePath(b.path("libs/glad/include/"));

    exe.addCSourceFile(.{
        .file = b.path("libs/glad/glad.c"),
    });

    exe.addCSourceFile(.{
        .file = b.path("libs/stb/stb_image.c"),
        .flags = &.{"-DSTB_IMAGE_IMPLEMENTATION"}
    });

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
