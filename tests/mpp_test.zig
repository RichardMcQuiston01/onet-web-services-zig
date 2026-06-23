const std = @import("std");
const onet = @import("onet");

const mpp_t = onet.types.mpp;

test "mpp types match mnm shapes" {
    const fixture = @embedFile("fixtures/mnm/search_careers.json");
    const result = try std.json.parseFromSlice(mpp_t.CareersPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 12), result.value.total);
    try std.testing.expectEqual(@as(usize, 3), result.value.career.len);
    try std.testing.expectEqualStrings("17-2051.00", result.value.career[0].code);
}

test "mpp career root type" {
    const fixture = @embedFile("fixtures/mnm/career_root.json");
    const result = try std.json.parseFromSlice(mpp_t.CareerRoot, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqualStrings("17-2061.00", result.value.code);
    try std.testing.expectEqualStrings("Computer Hardware Engineers", result.value.title);
}
