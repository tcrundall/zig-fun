const std = @import("std");

const MAJOR_VERSION = 1;
const MINOR_VERSION = 0;

const MATH_LIB_NAME = "math_functions";

pub fn build(b: *std.Build) !void {
    // Set up standard module options
    const standard_opts = std.Build.Module.CreateOptions{
        .optimize = b.standardOptimizeOption(.{}),
        .target = b.standardTargetOptions(.{}),
    };
    const use_my_math = b.option(
        bool,
        "useMyMath",
        "Use self implementation of sqrt",
    ) orelse false;

    // Compile and install modules
    const lib = try compileAndInstallLibrary(b, standard_opts, use_my_math);
    const exe = compileAndInstallExecutable(b, standard_opts, lib);
    const tests = try compileAndInstallTests(b, standard_opts, lib, use_my_math);

    // Configure steps
    setupRunStep(b, exe);
    setupTestStep(b, tests);
}

fn compileAndInstallLibrary(
    b: *std.Build,
    standard_opts: std.Build.Module.CreateOptions,
    use_my_math: bool,
) !*std.Build.Step.Compile {
    // Set up library specific options
    const dynamic_lib = b.option(
        bool,
        "dynamic",
        "Link library dynamically",
    ) orelse false;

    // Initialize library
    const lib_mod = b.createModule(standard_opts);
    const lib = b.addLibrary(.{
        .linkage = if (dynamic_lib) .dynamic else .static,
        .name = MATH_LIB_NAME,
        .root_module = lib_mod,
    });

    // Handle conditional compilation
    if (use_my_math) {
        lib_mod.addCMacro("USE_MYMATH", "");
        lib.addCSourceFile(.{ .file = .{ .cwd_relative = "MathFunctions/mysqrt.cxx" } });
    }

    // Link soure files and dependencies
    lib.addCSourceFile(.{
        .file = .{ .cwd_relative = "MathFunctions/MathFunctions.cxx" },
    });
    lib.linkLibCpp();

    // Identify as install target
    b.installArtifact(lib);

    return lib;
}

fn compileAndInstallExecutable(
    b: *std.Build,
    standard_opts: std.Build.Module.CreateOptions,
    lib: *std.Build.Step.Compile,
) *std.Build.Step.Compile {
    // Initialize executable, importing previously compiled library
    const exe_mod = b.createModule(standard_opts);
    exe_mod.addImport(MATH_LIB_NAME, lib.root_module);
    const exe = b.addExecutable(.{
        .name = "tutorial_z",
        .root_module = exe_mod,
    });

    // Add preformatted header
    const cmake_cfg_header_cmd = b.addConfigHeader(
        .{ .style = .{ .cmake = b.path("TutorialConfig.h.in") } },
        .{
            .Tutorial_VERSION_MAJOR = MAJOR_VERSION,
            .Tutorial_VERSION_MINOR = MINOR_VERSION,
        },
    );
    exe.addConfigHeader(cmake_cfg_header_cmd);

    // Add source files, include headers and link dependencies
    exe.addCSourceFile(.{ .file = .{ .cwd_relative = "tutorial.cxx" } });
    exe.addIncludePath(.{ .cwd_relative = "MathFunctions" });
    exe.linkLibCpp();

    // Identify as install target
    b.installArtifact(exe);

    return exe;
}

fn compileAndInstallTests(
    b: *std.Build,
    standard_opts: std.Build.Module.CreateOptions,
    lib: *std.Build.Step.Compile,
    use_my_math: bool,
) !*std.Build.Step.Compile {
    // Initialize tests
    const test_mod = b.createModule(standard_opts);
    test_mod.addImport(MATH_LIB_NAME, lib.root_module);
    const tests = b.addExecutable(.{ .name = "tests", .root_module = test_mod });

    // Handle conditional compilation
    if (use_my_math) {
        test_mod.addCMacro("USE_MYMATH", "");
    }

    // Add source files, link dependencies
    tests.addCSourceFile(.{
        .file = b.path("tests/main.cpp"),
    });
    const googletest_dep = b.dependency("googletest", .{ // Does not accept nullable fields, so cannot directly pass standard_opts
        .target = standard_opts.target.?,
        .optimize = standard_opts.optimize.?,
    });
    tests.addIncludePath(.{ .cwd_relative = "MathFunctions" });
    tests.linkLibrary(googletest_dep.artifact("gtest"));
    tests.linkLibrary(googletest_dep.artifact("gtest_main"));

    // Identify as install target
    // b.installArtifact(unit_test);

    return tests;
}

fn setupRunStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);
}

fn setupTestStep(b: *std.Build, tests: *std.Build.Step.Compile) void {
    const test_on_install = b.option(bool, "testOnInstall", "Run tests when installing") orelse false;
    const test_step = b.step("test", "Run unit tests");
    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);

    // Make tests run as part of install step
    if (test_on_install) {
        b.getInstallStep().dependOn(test_step);
    }
}
