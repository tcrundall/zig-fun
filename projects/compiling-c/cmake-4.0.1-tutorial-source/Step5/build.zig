const std = @import("std");
const MAJOR_VERSION = 1;
const MINOR_VERSION = 0;

const test_targets = [_]std.Target.Query{
    .{}, // native
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    // .{
    //     .cpu_arch = .x86_64,
    //     .os_tag = .windows,
    // },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const use_my_math = b.option(
        bool,
        "useMyMath",
        "Use self implementation of sqrt",
    ) orelse false;
    const dynamic_lib = b.option(
        bool,
        "dynamic",
        "Link library dynamically",
    ) orelse false;

    const math_lib_name = "math_functions";

    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport(math_lib_name, lib_mod);

    try buildLibrary(b, lib_mod, math_lib_name, use_my_math, dynamic_lib);
    const exe = buildExecutable(b, exe_mod);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");

    for (test_targets) |test_target| {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("test.zig"),
            .target = b.resolveTargetQuery(test_target),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }
}

fn buildLibrary(
    b: *std.Build,
    lib_mod: *std.Build.Module,
    lib_name: []const u8,
    use_my_math: bool,
    dynamic_lib: bool,
) !void {
    const lib = b.addLibrary(.{
        .linkage = if (dynamic_lib) .dynamic else .static,
        .name = lib_name,
        .root_module = lib_mod,
    });

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    if (use_my_math) {
        try flags.append("-DUSE_MYMATH=1");
        lib.addCSourceFile(.{ .file = .{ .cwd_relative = "MathFunctions/mysqrt.cxx" } });
    }

    lib.addCSourceFile(.{
        .file = .{ .cwd_relative = "MathFunctions/MathFunctions.cxx" },
        .flags = flags.items,
    });
    lib.linkLibCpp();
    b.installArtifact(lib);
}

fn buildExecutable(b: *std.Build, exe_mod: *std.Build.Module) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "tutorial_z",
        .root_module = exe_mod,
    });

    const cmake_cfg_header_cmd = b.addConfigHeader(
        .{ .style = .{ .cmake = b.path("TutorialConfig.h.in") } },
        .{
            .Tutorial_VERSION_MAJOR = MAJOR_VERSION,
            .Tutorial_VERSION_MINOR = MINOR_VERSION,
        },
    );

    exe.addConfigHeader(cmake_cfg_header_cmd);
    exe.addCSourceFile(.{ .file = .{ .cwd_relative = "tutorial.cxx" }, .flags = &.{} });
    exe.addIncludePath(.{ .cwd_relative = "MathFunctions" });
    exe.linkLibCpp();
    b.installArtifact(exe);

    return exe;
}
