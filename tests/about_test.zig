const std = @import("std");
const onet = @import("onet");

const AboutSystemInfo = onet.SystemInfo;

test "parse system info" {
    const fixture = @embedFile("fixtures/about/system_info.json");
    const result = try std.json.parseFromSlice(AboutSystemInfo, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqualStrings("29.3", result.value.onet_version.?);
    try std.testing.expectEqualStrings("1.9", result.value.api_version.?);
}
