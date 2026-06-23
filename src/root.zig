/// O*NET Web Services Zig client library.
///
/// Entry point: `OnetClient`. Create with `OnetClient.init(allocator, io, api_key)`.
pub const OnetClient = @import("client.zig").OnetClient;

pub const OnetError = @import("error.zig").OnetError;
pub const ApiErrorDetail = @import("error.zig").ApiErrorDetail;
pub const SystemInfo = @import("endpoints/about.zig").SystemInfo;

pub const types = struct {
    pub const common = @import("types/common.zig");
    pub const online = @import("types/online.zig");
    pub const mnm = @import("types/mnm.zig");
    pub const mpp = @import("types/mpp.zig");
    pub const veterans = @import("types/veterans.zig");
    pub const taxonomy = @import("types/taxonomy.zig");
    pub const database = @import("types/database.zig");
};

pub const OnlineClient = @import("endpoints/online.zig").OnlineClient;
pub const MnmClient = @import("endpoints/mnm.zig").MnmClient;
pub const MppClient = @import("endpoints/mpp.zig").MppClient;
pub const VeteransClient = @import("endpoints/veterans.zig").VeteransClient;
pub const TaxonomyClient = @import("endpoints/taxonomy.zig").TaxonomyClient;
pub const DatabaseClient = @import("endpoints/database.zig").DatabaseClient;
pub const AboutClient = @import("endpoints/about.zig").AboutClient;
