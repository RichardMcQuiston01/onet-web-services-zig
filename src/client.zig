const std = @import("std");
const ep_online = @import("endpoints/online.zig");
const ep_mnm = @import("endpoints/mnm.zig");
const ep_mpp = @import("endpoints/mpp.zig");
const ep_veterans = @import("endpoints/veterans.zig");
const ep_taxonomy = @import("endpoints/taxonomy.zig");
const ep_database = @import("endpoints/database.zig");
const ep_about = @import("endpoints/about.zig");

/// The O*NET Web Services client.
///
/// Heap-allocated via `init`; freed with `deinit`.  The caller is
/// responsible for keeping the `std.Io` instance (and its underlying
/// `Threaded`) alive for the entire lifetime of this client.
///
/// Usage:
/// ```zig
/// var threaded: std.Io.Threaded = .init(gpa, .{});
/// defer threaded.deinit();
///
/// const client = try OnetClient.init(gpa, threaded.io(), "YOUR_API_KEY");
/// defer client.deinit();
///
/// const result = try client.online.searchOccupations(arena, .{ .keyword = "engineer" }, null);
/// defer result.deinit();
/// ```
pub const OnetClient = struct {
    allocator: std.mem.Allocator,
    api_key: []const u8,
    http_client: std.http.Client,

    online: ep_online.OnlineClient,
    mnm: ep_mnm.MnmClient,
    mpp: ep_mpp.MppClient,
    veterans: ep_veterans.VeteransClient,
    taxonomy: ep_taxonomy.TaxonomyClient,
    database: ep_database.DatabaseClient,
    about: ep_about.AboutClient,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, api_key: []const u8) !*OnetClient {
        const client = try allocator.create(OnetClient);
        errdefer allocator.destroy(client);

        const owned_key = try allocator.dupe(u8, api_key);
        errdefer allocator.free(owned_key);

        client.* = .{
            .allocator = allocator,
            .api_key = owned_key,
            .http_client = .{ .allocator = allocator, .io = io },
            // Sub-clients are wired after the struct is stable in heap memory.
            .online = undefined,
            .mnm = undefined,
            .mpp = undefined,
            .veterans = undefined,
            .taxonomy = undefined,
            .database = undefined,
            .about = undefined,
        };

        client.online = .{
            .http_client = &client.http_client,
            .api_key = client.api_key,
        };
        client.mnm = .{
            .http_client = &client.http_client,
            .api_key = client.api_key,
            .prefix = "/mnm",
        };
        client.mpp = .{
            .http_client = &client.http_client,
            .api_key = client.api_key,
            .prefix = "/mpp",
        };
        client.veterans = .{
            .mnm = .{
                .http_client = &client.http_client,
                .api_key = client.api_key,
                .prefix = "/veterans",
            },
        };
        client.taxonomy = .{
            .http_client = &client.http_client,
            .api_key = client.api_key,
        };
        client.database = .{
            .http_client = &client.http_client,
            .api_key = client.api_key,
        };
        client.about = .{
            .http_client = &client.http_client,
            .api_key = client.api_key,
        };

        return client;
    }

    pub fn deinit(self: *OnetClient) void {
        self.http_client.deinit();
        const allocator = self.allocator;
        allocator.free(self.api_key);
        allocator.destroy(self);
    }
};
