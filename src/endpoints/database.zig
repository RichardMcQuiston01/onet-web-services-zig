const std = @import("std");
const http = @import("../http.zig");
const err = @import("../error.zig");
const t = @import("../types/database.zig");

const OnetError = err.OnetError;
const ApiErrorDetail = err.ApiErrorDetail;
const QueryParam = http.QueryParam;

pub const DatabaseClient = struct {
    http_client: *std.http.Client,
    api_key: []const u8,

    pub fn listTables(
        self: *const DatabaseClient,
        allocator: std.mem.Allocator,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed([]const t.TableRef) {
        const body = try http.fetch(self.http_client, allocator, self.api_key, "/database/", &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice([]const t.TableRef, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getTableInfo(
        self: *const DatabaseClient,
        allocator: std.mem.Allocator,
        table_id: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.TableInfo) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/database/info/{s}", .{table_id}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.TableInfo, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub const RowsParams = struct {
        filter: ?[]const u8 = null,
        sort: ?[]const u8 = null,
        start: ?u32 = null,
        end_: ?u32 = null,
    };

    pub fn getTableRows(
        self: *const DatabaseClient,
        allocator: std.mem.Allocator,
        table_id: []const u8,
        params: RowsParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.RowsPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/database/rows/{s}", .{table_id}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        if (params.filter) |f| query.append(.{ .key = "filter", .value = f }) catch return OnetError.NetworkError;
        if (params.sort) |s| query.append(.{ .key = "sort", .value = s }) catch return OnetError.NetworkError;
        if (params.start) |s| {
            var buf: [16]u8 = undefined;
            const sv = std.fmt.bufPrint(&buf, "{d}", .{s}) catch return OnetError.NetworkError;
            query.append(.{ .key = "start", .value = sv }) catch return OnetError.NetworkError;
        }
        if (params.end_) |e| {
            var buf: [16]u8 = undefined;
            const ev = std.fmt.bufPrint(&buf, "{d}", .{e}) catch return OnetError.NetworkError;
            query.append(.{ .key = "end", .value = ev }) catch return OnetError.NetworkError;
        }

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.RowsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }
};
