const std = @import("std");

const test_targets = [_]std.Target.Query{
    .{}, // native
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("powder", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_ttf");
    exe.linkSystemLibrary("c");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // const test_step = b.step("test", "Run unit tests");

    // for (test_targets) |test_target| {
    //     const unit_tests = b.addTest(.{
    //         .root_source_file = .{ .path = "main.zig" },
    //         .target = b.resolveTargetQuery(test_target),
    //     });

    //     const run_unit_tests = b.addRunArtifact(unit_tests);
    //     test_step.dependOn(&run_unit_tests.step);
    // }
}
