const std = @import("std");

pub fn build(b: *std.Build) void {
    const major_version = 1;
    const minor_version = 0;

    const tool_run1 = b.addSystemCommand(&.{"sed"});
    tool_run1.addArgs(&.{b.fmt("s/@Tutorial_VERSION_MAJOR@/{d}/", .{major_version})});
    tool_run1.addFileArg(b.path("TutorialConfig.h.in"));
    const output1 = tool_run1.captureStdOut();

    const tool_run2 = b.addSystemCommand(&.{"sed"});
    tool_run2.addArgs(&.{b.fmt("s/@Tutorial_VERSION_MINOR@/{d}/", .{minor_version})});
    tool_run2.addFileArg(output1);
    const output2 = tool_run2.captureStdOut();

    b.getInstallStep().dependOn(&b.addInstallFileWithDir(output2, .prefix, "TutorialConfig.h").step);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("math_functions", lib_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "math_functions",
        .root_module = lib_mod,
    });
    lib.addCSourceFiles(.{ .files = &.{ "MathFunctions/MathFunctions.cxx", "MathFunctions/mysqrt.cxx" } });
    lib.linkLibCpp();

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "tutorial_z",
        .root_module = exe_mod,
    });
    exe.addCSourceFile(.{ .file = .{ .cwd_relative = "tutorial.cxx" }, .flags = &.{} });
    exe.addIncludePath(.{ .cwd_relative = "zig-out" });
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
