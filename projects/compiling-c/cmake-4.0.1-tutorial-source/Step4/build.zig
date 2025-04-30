const std = @import("std");

pub fn build(b: *std.Build) void {
    const major_version = 1;
    const minor_version = 0;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const windows = b.option(bool, "windows", "Target Microsoft Windows") orelse false;

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "math_functions",
        .root_module = lib_mod,
    });

    const use_my_math = b.option(bool, "USE_MYMATH", "Use self implementation of sqrt") orelse true;
    var use_my_math_flag: []const u8 = "";
    if (use_my_math) {
        use_my_math_flag = "-DUSE_MYMATH=1";
    }
    lib.addCSourceFile(.{ .file = .{ .cwd_relative = "MathFunctions/MathFunctions.cxx" }, .flags = &.{use_my_math_flag} });
    lib.addCSourceFile(.{ .file = .{ .cwd_relative = "MathFunctions/mysqrt.cxx" } });
    lib.linkLibCpp();

    b.installArtifact(lib);

    const exe_mod = b.createModule(.{
        .target = b.resolveTargetQuery(.{
            .os_tag = if (windows) .windows else null,
        }),
        .optimize = optimize,
    });
    exe_mod.addImport("math_functions", lib_mod);

    const exe = b.addExecutable(.{
        .name = "tutorial_z",
        .root_module = exe_mod,
    });

    // substitute cmake values
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

    const install_artifact = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
    });
    b.getInstallStep().dependOn(&install_artifact.step);
    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
