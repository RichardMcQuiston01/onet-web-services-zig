const std = @import("std");
const onet = @import("onet");

const mnm_t = onet.types.mnm;

test "parse search careers" {
    const fixture = @embedFile("fixtures/mnm/search_careers.json");
    const result = try std.json.parseFromSlice(mnm_t.CareersPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 1), result.value.start);
    try std.testing.expectEqual(@as(u32, 12), result.value.total);
    try std.testing.expectEqual(@as(usize, 3), result.value.career.len);
    try std.testing.expectEqualStrings("17-2051.00", result.value.career[0].code);
    try std.testing.expectEqualStrings("Civil Engineers", result.value.career[0].title);
    try std.testing.expect(result.value.career[1].tags.?.bright_outlook.? == true);
}

test "parse career root" {
    const fixture = @embedFile("fixtures/mnm/career_root.json");
    const result = try std.json.parseFromSlice(mnm_t.CareerRoot, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqualStrings("17-2061.00", result.value.code);
    try std.testing.expectEqualStrings("Computer Hardware Engineers", result.value.title);
    try std.testing.expectEqual(@as(usize, 2), result.value.also_called.len);
    try std.testing.expectEqualStrings("Hardware Design Engineer", result.value.also_called[0].title);
    try std.testing.expectEqual(@as(usize, 2), result.value.on_the_job.len);
    try std.testing.expectEqual(@as(usize, 2), result.value.contents.len);
    try std.testing.expectEqualStrings("Knowledge", result.value.contents[0].title);
}

test "parse career knowledge categories" {
    const fixture = @embedFile("fixtures/mnm/career_knowledge.json");
    const result = try std.json.parseFromSlice([]const mnm_t.KnowledgeCategory, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 2), result.value.len);
    try std.testing.expectEqualStrings("engineering_technology", result.value[0].id);
    try std.testing.expectEqualStrings("Engineering and Technology", result.value[0].name);
    try std.testing.expectEqual(@as(usize, 2), result.value[0].element.len);
    try std.testing.expectEqualStrings("2.C.3.a", result.value[0].element[0].id);
    try std.testing.expectEqualStrings("Computers and Electronics", result.value[0].element[0].name);
}

test "parse interest profiler questions" {
    const fixture = @embedFile("fixtures/mnm/profiler_questions.json");
    const result = try std.json.parseFromSlice(mnm_t.ProfilerQuestionsPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 60), result.value.total);
    try std.testing.expectEqual(@as(usize, 5), result.value.answer_option.len);
    try std.testing.expectEqual(@as(u32, 1), result.value.answer_option[0].value);
    try std.testing.expectEqualStrings("Strongly Dislike", result.value.answer_option[0].name);
    try std.testing.expectEqual(@as(usize, 2), result.value.question.len);
    try std.testing.expectEqualStrings("Realistic", result.value.question[0].area);
    try std.testing.expectEqualStrings("Build kitchen cabinets", result.value.question[0].text);
}

test "parse interest profiler results" {
    const fixture = @embedFile("fixtures/mnm/profiler_results.json");
    const result = try std.json.parseFromSlice(mnm_t.ProfilerResultsResponse, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 2), result.value.result.len);
    try std.testing.expectEqualStrings("17-2061.00", result.value.result[0].code);
    try std.testing.expectEqual(@as(u32, 42), result.value.result[0].score);
    try std.testing.expect(result.value.result[0].description != null);
    try std.testing.expect(result.value.result[1].description == null);
}
