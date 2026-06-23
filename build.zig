const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "onet-web-services",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    const test_step = b.step("test", "Run all tests");

    const test_sources = [_][]const u8{
        "tests/online_test.zig",
        "tests/mnm_test.zig",
        "tests/mpp_test.zig",
        "tests/veterans_test.zig",
        "tests/taxonomy_test.zig",
        "tests/database_test.zig",
        "tests/about_test.zig",
    };

    for (test_sources) |src| {
        const test_mod = b.createModule(.{
            .root_source_file = b.path(src),
            .target = target,
            .optimize = optimize,
        });
        test_mod.addImport("onet", lib_mod);

        const t = b.addTest(.{ .root_module = test_mod });
        const run = b.addRunArtifact(t);
        test_step.dependOn(&run.step);
    }
}
