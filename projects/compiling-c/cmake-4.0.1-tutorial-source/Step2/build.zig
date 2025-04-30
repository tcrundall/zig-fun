const std = @import("std");

pub fn build(b: *std.Build) void {
    const major_version = 1;
    const minor_version = 0;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib_name = "math_functions";

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport(lib_name, lib_mod);

    buildLibrary(b, lib_name, lib_mod);
    const exe = buildExecutable(b, exe_mod, major_version, minor_version);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn buildLibrary(b: *std.Build, lib_name: []const u8, lib_mod: *std.Build.Module) void {
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = lib_name,
        .root_module = lib_mod,
    });

    const use_my_math = b.option(
        bool,
        "USE_MYMATH",
        "Use self implementation of sqrt",
    ) orelse false;
    if (use_my_math) {
        lib.addCSourceFile(.{
            .file = .{ .cwd_relative = "MathFunctions/MathFunctions.cxx" },
            .flags = &.{"-DUSE_MYMATH=1"},
        });
    } else {
        lib.addCSourceFile(.{
            .file = .{ .cwd_relative = "MathFunctions/MathFunctions.cxx" },
            .flags = &.{"-DUSE_MYMATH=0"},
        });
    }
    lib.addCSourceFile(.{ .file = .{ .cwd_relative = "MathFunctions/mysqrt.cxx" } });
    lib.linkLibCpp();

    b.installArtifact(lib);
}

fn buildExecutable(
    b: *std.Build,
    exe_mod: *std.Build.Module,
    major_version: u16,
    minor_version: u16,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "tutorial_z",
        .root_module = exe_mod,
    });
    const cmake_cfg_header_cmd = b.addConfigHeader(
        .{ .style = .{ .cmake = b.path("TutorialConfig.h.in") } },
        .{
            .Tutorial_VERSION_MAJOR = major_version,
            .Tutorial_VERSION_MINOR = minor_version,
        },
    );
    exe.addConfigHeader(cmake_cfg_header_cmd);
    exe.addCSourceFile(.{ .file = .{ .cwd_relative = "tutorial.cxx" }, .flags = &.{} });
    exe.addIncludePath(.{ .cwd_relative = "MathFunctions" });
    exe.linkLibCpp();

    b.installArtifact(exe);

    return exe;
}
