const std = @import("std");
const http = @import("../http.zig");
const err = @import("../error.zig");
const t = @import("../types/veterans.zig");
const mnm_ep = @import("mnm.zig");

const OnetError = err.OnetError;
const ApiErrorDetail = err.ApiErrorDetail;
const QueryParam = http.QueryParam;

pub const VeteransClient = struct {
    /// Shared MNM-compatible sub-client pointed at "/veterans".
    mnm: mnm_ep.MnmClient,

    // ── Forwarded MNM methods ─────────────────────────────────────────────

    pub fn searchCareers(self: *const VeteransClient, a: std.mem.Allocator, p: mnm_ep.MnmClient.SearchParams, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareersPage) {
        return self.mnm.searchCareers(a, p, d);
    }
    pub fn listCareers(self: *const VeteransClient, a: std.mem.Allocator, p: mnm_ep.MnmClient.ListParams, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareersPage) {
        return self.mnm.listCareers(a, p, d);
    }
    pub fn listIndustries(self: *const VeteransClient, a: std.mem.Allocator, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.IndustryListing) {
        return self.mnm.listIndustries(a, d);
    }
    pub fn getBrightOutlook(self: *const VeteransClient, a: std.mem.Allocator, p: mnm_ep.MnmClient.ListParams, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareersPage) {
        return self.mnm.getBrightOutlook(a, p, d);
    }
    pub fn listCareerClusters(self: *const VeteransClient, a: std.mem.Allocator, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareerClusterListing) {
        return self.mnm.listCareerClusters(a, d);
    }
    pub fn getCareersByInterest(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, p: mnm_ep.MnmClient.ListParams, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareersPage) {
        return self.mnm.getCareersByInterest(a, code, p, d);
    }
    pub fn getCareersByJobZone(self: *const VeteransClient, a: std.mem.Allocator, zone: u32, p: mnm_ep.MnmClient.ListParams, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareersPage) {
        return self.mnm.getCareersByJobZone(a, zone, p, d);
    }
    pub fn getCareer(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.CareerRoot) {
        return self.mnm.getCareer(a, code, d);
    }
    pub fn getCareerKnowledge(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.mnm.getCareerKnowledge(a, code, d);
    }
    pub fn getCareerSkills(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.mnm.getCareerSkills(a, code, d);
    }
    pub fn getCareerAbilities(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.mnm.getCareerAbilities(a, code, d);
    }
    pub fn getCareerPersonality(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.mnm.getCareerPersonality(a, code, d);
    }
    pub fn getCareerTechnology(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.TechnologyListing) {
        return self.mnm.getCareerTechnology(a, code, d);
    }
    pub fn getCareerEducation(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.EducationListing) {
        return self.mnm.getCareerEducation(a, code, d);
    }
    pub fn getCareerJobOutlook(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.JobOutlook) {
        return self.mnm.getCareerJobOutlook(a, code, d);
    }
    pub fn getCareerExploreMore(self: *const VeteransClient, a: std.mem.Allocator, code: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ExploreMoreListing) {
        return self.mnm.getCareerExploreMore(a, code, d);
    }
    pub fn getInterestProfilerQuestions(self: *const VeteransClient, a: std.mem.Allocator, p: mnm_ep.MnmClient.ProfilerParams, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ProfilerQuestionsPage) {
        return self.mnm.getInterestProfilerQuestions(a, p, d);
    }
    pub fn getInterestProfilerResults(self: *const VeteransClient, a: std.mem.Allocator, answers: []const u8, d: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ProfilerResultsResponse) {
        return self.mnm.getInterestProfilerResults(a, answers, d);
    }

    // ── Military-specific ─────────────────────────────────────────────────

    pub const MilitarySearchParams = struct {
        keyword: []const u8,
        branch: ?[]const u8 = null,
        active: ?bool = null,
        start: ?u32 = null,
        end_: ?u32 = null,
    };

    pub fn searchMilitaryJobs(
        self: *const VeteransClient,
        allocator: std.mem.Allocator,
        params: MilitarySearchParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.MilitaryJobsPage) {
        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();

        query.append(.{ .key = "keyword", .value = params.keyword }) catch return OnetError.NetworkError;
        if (params.branch) |b| query.append(.{ .key = "branch", .value = b }) catch return OnetError.NetworkError;
        if (params.active) |a| query.append(.{ .key = "active", .value = if (a) "true" else "false" }) catch return OnetError.NetworkError;
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

        const body = try http.fetch(self.mnm.http_client, allocator, self.mnm.api_key, "/veterans/military", query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.MilitaryJobsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }
};
