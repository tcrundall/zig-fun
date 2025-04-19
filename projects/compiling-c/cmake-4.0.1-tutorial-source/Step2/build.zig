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
    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "tutorial_z",
        .root_module = exe_mod,
    });
    exe.addCSourceFile(.{ .file = .{ .cwd_relative = "tutorial.cxx" }, .flags = &.{} });
    exe.addIncludePath(.{ .cwd_relative = "zig-out" });
    exe.linkLibCpp(); // only need cpp libraries, it seems

    const install_artifact = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
    });
    b.getInstallStep().dependOn(&install_artifact.step);
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
