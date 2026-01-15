// CarbideKlar Standard Build Configuration
// Replace {{PROJECT_NAME}} with your project name

const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target and optimization options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ============================================================
    // Main Executable
    // ============================================================

    const exe = b.addExecutable(.{
        .name = "{{PROJECT_NAME}}",
        .root_source_file = b.path("src/main.kl"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    // Run command: zig build run
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // ============================================================
    // Library (if applicable)
    // ============================================================

    // Uncomment if building a library
    // const lib = b.addStaticLibrary(.{
    //     .name = "{{PROJECT_NAME}}",
    //     .root_source_file = b.path("src/lib.kl"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // b.installArtifact(lib);

    // ============================================================
    // Unit Tests
    // ============================================================

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.kl"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Integration tests
    const integration_tests = b.addTest(.{
        .root_source_file = b.path("tests/test_lib.kl"),
        .target = target,
        .optimize = optimize,
    });

    const run_integration_tests = b.addRunArtifact(integration_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
    test_step.dependOn(&run_integration_tests.step);

    // ============================================================
    // Documentation
    // ============================================================

    // Uncomment to enable documentation generation
    // const docs = b.addInstallDirectory(.{
    //     .source_dir = exe.getEmittedDocs(),
    //     .install_dir = .prefix,
    //     .install_subdir = "docs",
    // });
    // const docs_step = b.step("docs", "Generate documentation");
    // docs_step.dependOn(&docs.step);

    // ============================================================
    // Clean
    // ============================================================

    // Clean step handled by: zig build --clean
}
