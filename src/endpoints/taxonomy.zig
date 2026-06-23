const std = @import("std");
const http = @import("../http.zig");
const err = @import("../error.zig");
const t = @import("../types/taxonomy.zig");

const OnetError = err.OnetError;
const ApiErrorDetail = err.ApiErrorDetail;

pub const TaxonomyClient = struct {
    http_client: *std.http.Client,
    api_key: []const u8,

    /// Convert an occupation code between O*NET taxonomy versions.
    ///
    /// `from_version` and `to_version` are one of: `"2010"`, `"2019"`, `"active"`.
    pub fn convert(
        self: *const TaxonomyClient,
        allocator: std.mem.Allocator,
        from_version: []const u8,
        to_version: []const u8,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.TaxonomyResult) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/taxonomy/{s}/{s}/{s}", .{ from_version, to_version, code }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.TaxonomyResult, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }
};
