const std = @import("std");
const onet = @import("onet");

const tax_t = onet.types.taxonomy;

test "parse taxonomy convert result" {
    const fixture = @embedFile("fixtures/taxonomy/convert.json");
    const result = try std.json.parseFromSlice(tax_t.TaxonomyResult, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqualStrings("15-1141.00", result.value.code);
    try std.testing.expectEqualStrings("Database Administrators and Architects", result.value.title);
    try std.testing.expect(result.value.description != null);
    try std.testing.expectEqual(@as(usize, 3), result.value.occupation.len);
    try std.testing.expectEqualStrings("15-1141.01", result.value.occupation[1].code);
    try std.testing.expectEqualStrings("Database Administrators", result.value.occupation[1].title);
}
