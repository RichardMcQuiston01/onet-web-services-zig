const std = @import("std");

pub const TableRef = struct {
    info: []const u8,
    rows: []const u8,
    table_id: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
};

pub const ColumnType = enum {
    text,
    number,
    date,
    unknown,

    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !ColumnType {
        const s = try std.json.innerParse([]const u8, allocator, source, options);
        if (std.mem.eql(u8, s, "text")) return .text;
        if (std.mem.eql(u8, s, "number")) return .number;
        if (std.mem.eql(u8, s, "date")) return .date;
        return .unknown;
    }
};

pub const Column = struct {
    column_id: []const u8,
    optional: bool,
    title: []const u8,
    description: ?[]const u8 = null,
    type: ?ColumnType = null,
    format: ?[]const u8 = null,
};

pub const DownloadFormats = struct {
    excel: ?[]const u8 = null,
    text: ?[]const u8 = null,
    mysql: ?[]const u8 = null,
    sql_server: ?[]const u8 = null,
    oracle: ?[]const u8 = null,
};

pub const TableInfo = struct {
    rows: []const u8,
    table_id: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
    data_dictionary: ?[]const u8 = null,
    download: ?DownloadFormats = null,
    column: []const Column = &.{},
};

/// Database rows use `std.json.Value` because column schemas vary per table.
pub const RowsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    row: []const std.json.Value = &.{},
};
