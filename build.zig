const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const server_object = b.addObject(.{
        .name = "server",
        .root_source_file = .{ .path = "src/server.zig" },
        .target = target,
        .optimize = optimize,
        .strip = optimize != .Debug,
    });

    const swiftc_command = b.addSystemCommand(&.{
        "swiftc",
        if (optimize == .Debug) "-Onone" else "-O",
        "-import-objc-header",
        "src/server.h",
        "-target",

        b.fmt("{s}-apple-macosx{}", .{
            @tagName(target.result.cpu.arch),
            target.result.os.version_range.semver.min,
        }),
    });

    if (optimize == .Debug) {
        swiftc_command.addArgs(&.{ "-D", "DEBUG" });
    }

    swiftc_command.addArg("-o");

    const app_output_path = swiftc_command.addOutputFileArg("app");

    swiftc_command.addArg("-Xlinker");
    swiftc_command.addFileArg(server_object.getEmittedBin());
    swiftc_command.addFileArg(.{ .path = "src/app.swift" });
    swiftc_command.addFileArg(.{ .path = "src/webview.swift" });
    swiftc_command.step.dependOn(&server_object.step);

    const sdk = std.zig.system.darwin.getSdk(
        b.allocator,
        target.result,
    ) orelse return error.UnknownSdk;

    server_object.addSystemIncludePath(
        .{ .path = b.fmt("{s}/usr/include", .{sdk}) },
    );

    server_object.addFrameworkPath(
        .{ .path = b.fmt("{s}/System/Library/Frameworks", .{sdk}) },
    );

    server_object.addLibraryPath(.{ .path = b.fmt("{s}/usr/lib", .{sdk}) });

    const app_bin = b.addInstallBinFile(app_output_path, "app");

    b.getInstallStep().dependOn(&app_bin.step);
}
