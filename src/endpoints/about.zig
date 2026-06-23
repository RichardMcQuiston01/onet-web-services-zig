const std = @import("std");
const http = @import("../http.zig");
const err = @import("../error.zig");

const OnetError = err.OnetError;
const ApiErrorDetail = err.ApiErrorDetail;

pub const SystemInfo = struct {
    api_version: ?[]const u8 = null,
    onet_version: ?[]const u8 = null,
    status: ?[]const u8 = null,
};

pub const AboutClient = struct {
    http_client: *std.http.Client,
    api_key: []const u8,

    pub fn getSystemInfo(
        self: *const AboutClient,
        allocator: std.mem.Allocator,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(SystemInfo) {
        const body = try http.fetch(self.http_client, allocator, self.api_key, "/about/", &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(SystemInfo, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }
};
