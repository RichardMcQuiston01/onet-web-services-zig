const std = @import("std");
const onet = @import("onet");

const vet_t = onet.types.veterans;

test "veterans careers page uses mnm shape" {
    const fixture = @embedFile("fixtures/mnm/search_careers.json");
    const result = try std.json.parseFromSlice(vet_t.CareersPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 12), result.value.total);
    try std.testing.expectEqualStrings("Civil Engineers", result.value.career[0].title);
}

test "military jobs page shape" {
    const fixture =
        \\{
        \\  "start": 1,
        \\  "end": 2,
        \\  "total": 10,
        \\  "match": [
        \\    {
        \\      "code": "11X",
        \\      "title": "Infantry Officer",
        \\      "branch": "Army",
        \\      "active": true,
        \\      "occupation": [
        \\        {
        \\          "href": "https://services.onetcenter.org/ws/online/occupations/11-1011.00/",
        \\          "code": "11-1011.00",
        \\          "title": "Chief Executives"
        \\        }
        \\      ]
        \\    }
        \\  ]
        \\}
    ;
    const result = try std.json.parseFromSlice(vet_t.MilitaryJobsPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 10), result.value.total);
    try std.testing.expectEqual(@as(usize, 1), result.value.match.len);
    try std.testing.expectEqualStrings("11X", result.value.match[0].code);
    try std.testing.expectEqualStrings("Army", result.value.match[0].branch.?);
    try std.testing.expect(result.value.match[0].active.? == true);
    try std.testing.expectEqual(@as(usize, 1), result.value.match[0].occupation.len);
}
