const std = @import("std");
const onet = @import("onet");

const online_t = onet.types.online;
const common_t = onet.types.common;

test "parse search occupations" {
    const fixture = @embedFile("fixtures/online/search_occupations.json");
    const result = try std.json.parseFromSlice(online_t.SearchResponse, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 1), result.value.start);
    try std.testing.expectEqual(@as(u32, 3), result.value.end);
    try std.testing.expectEqual(@as(u32, 63), result.value.total);
    try std.testing.expectEqual(@as(usize, 3), result.value.occupation.len);
    try std.testing.expectEqualStrings("17-2051.00", result.value.occupation[0].code);
    try std.testing.expectEqualStrings("Civil Engineers", result.value.occupation[0].title);
    try std.testing.expect(result.value.occupation[2].tags.?.bright_outlook.? == true);
}

test "parse occupation root" {
    const fixture = @embedFile("fixtures/online/occupation_root.json");
    const result = try std.json.parseFromSlice(online_t.OccupationRoot, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqualStrings("17-2051.00", result.value.code);
    try std.testing.expectEqualStrings("Civil Engineers", result.value.title);
    try std.testing.expectEqual(@as(usize, 4), result.value.sample_of_reported_titles.len);
    try std.testing.expectEqualStrings("Civil Engineer", result.value.sample_of_reported_titles[1]);
    try std.testing.expectEqual(@as(usize, 2), result.value.summary_contents.len);
}

test "parse occupation skills summary" {
    const fixture = @embedFile("fixtures/online/occupation_skills_summary.json");
    const result = try std.json.parseFromSlice(online_t.ElementsPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 35), result.value.total);
    try std.testing.expectEqual(@as(usize, 2), result.value.element.len);
    try std.testing.expectEqualStrings("2.B.1.a", result.value.element[0].id);
    try std.testing.expectEqualStrings("Reading Comprehension", result.value.element[0].name);
}

test "parse occupation tasks summary" {
    const fixture = @embedFile("fixtures/online/occupation_tasks_summary.json");
    const result = try std.json.parseFromSlice(online_t.TasksPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 40), result.value.total);
    try std.testing.expectEqual(@as(usize, 2), result.value.task.len);
    try std.testing.expectEqualStrings("17947", result.value.task[0].id);
}

test "parse occupation education summary" {
    const fixture = @embedFile("fixtures/online/occupation_education_summary.json");
    const result = try std.json.parseFromSlice(online_t.EducationResponse, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 3), result.value.response.len);
    try std.testing.expectEqual(@as(u32, 6), result.value.response[0].code);
    try std.testing.expectEqualStrings("Bachelor's degree", result.value.response[0].title);
    try std.testing.expectEqual(@as(u32, 59), result.value.response[0].percentage_of_respondents.?);
}

test "parse occupation job zone summary" {
    const fixture = @embedFile("fixtures/online/occupation_job_zone_summary.json");
    const result = try std.json.parseFromSlice(online_t.JobZone, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 4), result.value.code);
    try std.testing.expectEqualStrings("Job Zone Four: Considerable Preparation Needed", result.value.title);
    try std.testing.expectEqualStrings("(7.0 to < 8.0)", result.value.svp_range.?);
}

test "parse occupation tasks details" {
    const fixture = @embedFile("fixtures/online/occupation_tasks_details.json");
    const result = try std.json.parseFromSlice(online_t.ScoredTasksPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 40), result.value.total);
    try std.testing.expectEqual(@as(usize, 3), result.value.task.len);
    try std.testing.expectEqualStrings("17947", result.value.task[0].id);
    try std.testing.expectEqual(@as(?u32, 85), result.value.task[0].importance);
}

test "parse crosswalk" {
    const fixture = @embedFile("fixtures/online/crosswalk.json");
    const result = try std.json.parseFromSlice(online_t.CrosswalkPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 5), result.value.total);
    try std.testing.expectEqual(@as(usize, 1), result.value.match.len);
    try std.testing.expectEqualStrings("0963", result.value.match[0].code);
    try std.testing.expectEqual(@as(usize, 1), result.value.match[0].occupation.len);
    try std.testing.expectEqualStrings("29-1171.00", result.value.match[0].occupation[0].code);
}

test "parse soft skills listing" {
    const fixture = @embedFile("fixtures/online/soft_skills.json");
    const result = try std.json.parseFromSlice(online_t.SoftSkillListing, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 1), result.value.social.len);
    try std.testing.expectEqual(@as(usize, 1), result.value.thinking.len);
    try std.testing.expectEqualStrings("social_perceptiveness", result.value.social[0].code);
    try std.testing.expectEqual(@as(usize, 2), result.value.social[0].example.len);
}
