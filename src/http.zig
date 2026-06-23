const std = @import("std");
const OnetError = @import("error.zig").OnetError;
const ApiErrorDetail = @import("error.zig").ApiErrorDetail;

pub const BASE_URL = "https://services.onetcenter.org/ws";

pub const QueryParam = struct {
    key: []const u8,
    value: []const u8,
};

/// Fetches a JSON response from the O*NET API.
///
/// Builds the full URL, injects the API key header, captures the response
/// body, and maps HTTP status codes to `OnetError` values. On `ApiError`
/// (HTTP 422), populates `err_detail` if non-null.
///
/// Returns an owned `[]const u8` (caller must free with `allocator.free`).
pub fn fetch(
    http_client: *std.http.Client,
    allocator: std.mem.Allocator,
    api_key: []const u8,
    path: []const u8,
    query: []const QueryParam,
    err_detail: ?*ApiErrorDetail,
) OnetError![]const u8 {
    var url_buf = std.ArrayList(u8).init(allocator);
    defer url_buf.deinit();

    url_buf.appendSlice(BASE_URL) catch return OnetError.NetworkError;
    url_buf.appendSlice(path) catch return OnetError.NetworkError;

    if (query.len > 0) {
        url_buf.append('?') catch return OnetError.NetworkError;
        for (query, 0..) |param, i| {
            if (i > 0) url_buf.append('&') catch return OnetError.NetworkError;
            url_buf.appendSlice(param.key) catch return OnetError.NetworkError;
            url_buf.append('=') catch return OnetError.NetworkError;
            appendUrlEncoded(&url_buf, param.value) catch return OnetError.NetworkError;
        }
    }

    var aw = std.Io.Writer.Allocating.init(allocator);
    defer aw.deinit();

    const result = http_client.fetch(.{
        .location = .{ .url = url_buf.items },
        .extra_headers = &.{
            .{ .name = "X-API-Key", .value = api_key },
            .{ .name = "Accept", .value = "application/json" },
        },
        .response_writer = &aw.writer,
    }) catch return OnetError.NetworkError;

    const body = aw.writer.buffer[0..aw.writer.end];

    switch (result.status) {
        .ok => {},
        .unauthorized => return OnetError.Unauthorized,
        .forbidden => return OnetError.Forbidden,
        .not_found => return OnetError.NotFound,
        .unprocessable_entity => {
            if (err_detail) |d| populateApiError(allocator, body, d);
            return OnetError.ApiError;
        },
        .too_many_requests => return OnetError.RateLimited,
        else => {
            const code: u16 = @intFromEnum(result.status);
            if (code >= 500) return OnetError.ServerError;
            return OnetError.HttpError;
        },
    }

    return allocator.dupe(u8, body) catch return OnetError.NetworkError;
}

fn appendUrlEncoded(buf: *std.ArrayList(u8), s: []const u8) !void {
    for (s) |c| {
        switch (c) {
            'A'...'Z', 'a'...'z', '0'...'9', '-', '_', '.', '~' => try buf.append(c),
            else => try buf.writer().print("%{X:0>2}", .{c}),
        }
    }
}

fn populateApiError(allocator: std.mem.Allocator, body: []const u8, detail: *ApiErrorDetail) void {
    const Envelope = struct { @"error": []const u8 };
    const parsed = std.json.parseFromSlice(Envelope, allocator, body, .{
        .ignore_unknown_fields = true,
    }) catch return;
    defer parsed.deinit();
    detail.message = allocator.dupe(u8, parsed.value.@"error") catch return;
}
