const std = @import("std");
const onet = @import("onet");

const db_t = onet.types.database;

test "parse tables list" {
    const fixture = @embedFile("fixtures/database/tables.json");
    const result = try std.json.parseFromSlice([]const db_t.TableRef, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 2), result.value.len);
    try std.testing.expectEqualStrings("abilities", result.value[0].table_id);
    try std.testing.expectEqualStrings("Abilities", result.value[0].title);
    try std.testing.expect(result.value[0].description != null);
    try std.testing.expect(result.value[1].description == null);
}

test "parse table info" {
    const fixture = @embedFile("fixtures/database/table_info.json");
    const result = try std.json.parseFromSlice(db_t.TableInfo, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqualStrings("abilities", result.value.table_id);
    try std.testing.expectEqualStrings("Abilities", result.value.title);
    try std.testing.expect(result.value.data_dictionary != null);
    try std.testing.expectEqual(@as(usize, 3), result.value.column.len);
    try std.testing.expectEqualStrings("onetsoc_code", result.value.column[0].column_id);
    try std.testing.expect(!result.value.column[0].optional);
    try std.testing.expect(result.value.column[2].optional);
    try std.testing.expectEqual(db_t.ColumnType.number, result.value.column[2].type.?);
}

test "parse table rows" {
    const fixture =
        \\{
        \\  "start": 1,
        \\  "end": 2,
        \\  "total": 100,
        \\  "row": [
        \\    { "onetsoc_code": "11-1011.00", "element_id": "1.A.1.a.1", "data_value": 4.5 },
        \\    { "onetsoc_code": "11-1011.00", "element_id": "1.A.1.a.2", "data_value": 3.0 }
        \\  ]
        \\}
    ;
    const result = try std.json.parseFromSlice(db_t.RowsPage, std.testing.allocator, fixture, .{ .ignore_unknown_fields = true });
    defer result.deinit();

    try std.testing.expectEqual(@as(u32, 100), result.value.total);
    try std.testing.expectEqual(@as(usize, 2), result.value.row.len);
    const first_row = result.value.row[0].object;
    try std.testing.expect(first_row.get("onetsoc_code") != null);
}
