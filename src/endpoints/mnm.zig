const std = @import("std");
const http = @import("../http.zig");
const err = @import("../error.zig");
const t = @import("../types/mnm.zig");

const OnetError = err.OnetError;
const ApiErrorDetail = err.ApiErrorDetail;
const QueryParam = http.QueryParam;

pub const MnmClient = struct {
    http_client: *std.http.Client,
    api_key: []const u8,
    /// URL prefix for this client's endpoints (e.g. "/mnm" or "/mpp" or "/veterans").
    prefix: []const u8,

    // ── Search / Browse ───────────────────────────────────────────────────

    pub const SearchParams = struct {
        keyword: []const u8,
        start: ?u32 = null,
        end: ?u32 = null,
    };

    pub fn searchCareers(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        params: SearchParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareersPage) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/search", .{self.prefix}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        query.append(.{ .key = "keyword", .value = params.keyword }) catch return OnetError.NetworkError;
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareersPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub const ListParams = struct {
        start: ?u32 = null,
        end: ?u32 = null,
    };

    pub fn listCareers(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        params: ListParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareersPage) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/", .{self.prefix}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareersPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn listIndustries(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.IndustryListing) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/industries/", .{self.prefix}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.IndustryListing, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getBrightOutlook(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        params: ListParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareersPage) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/bright_outlook/", .{self.prefix}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareersPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn listCareerClusters(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareerClusterListing) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/career_clusters/", .{self.prefix}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareerClusterListing, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getCareersByInterest(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        interest_code: []const u8,
        params: ListParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareersPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/interests/{s}", .{ self.prefix, interest_code }) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareersPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getCareersByJobZone(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        zone: u32,
        params: ListParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareersPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/job_preparation/{d}", .{ self.prefix, zone }) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareersPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Career detail ─────────────────────────────────────────────────────

    pub fn getCareer(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CareerRoot) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/{s}/", .{ self.prefix, code }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CareerRoot, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    fn getCareerCategories(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        aspect: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/{s}/{s}", .{ self.prefix, code, aspect }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice([]const t.KnowledgeCategory, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getCareerKnowledge(self: *const MnmClient, allocator: std.mem.Allocator, code: []const u8, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.getCareerCategories(allocator, code, "knowledge", err_detail);
    }

    pub fn getCareerSkills(self: *const MnmClient, allocator: std.mem.Allocator, code: []const u8, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.getCareerCategories(allocator, code, "skills", err_detail);
    }

    pub fn getCareerAbilities(self: *const MnmClient, allocator: std.mem.Allocator, code: []const u8, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.getCareerCategories(allocator, code, "abilities", err_detail);
    }

    pub fn getCareerPersonality(self: *const MnmClient, allocator: std.mem.Allocator, code: []const u8, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed([]const t.KnowledgeCategory) {
        return self.getCareerCategories(allocator, code, "personality", err_detail);
    }

    pub fn getCareerTechnology(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.TechnologyListing) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/{s}/technology", .{ self.prefix, code }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.TechnologyListing, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getCareerEducation(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.EducationListing) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/{s}/education", .{ self.prefix, code }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.EducationListing, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getCareerJobOutlook(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.JobOutlook) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/{s}/job_outlook", .{ self.prefix, code }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.JobOutlook, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getCareerExploreMore(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.ExploreMoreListing) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/careers/{s}/explore_more", .{ self.prefix, code }) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.ExploreMoreListing, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Interest Profiler ─────────────────────────────────────────────────

    pub const ProfilerParams = struct {
        start: ?u32 = null,
        end: ?u32 = null,
    };

    pub fn getInterestProfilerQuestions(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        params: ProfilerParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.ProfilerQuestionsPage) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/interestprofiler/questions", .{self.prefix}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.ProfilerQuestionsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getInterestProfilerResults(
        self: *const MnmClient,
        allocator: std.mem.Allocator,
        answers: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.ProfilerResultsResponse) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "{s}/interestprofiler/results", .{self.prefix}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{
            .{ .key = "answers", .value = answers },
        }, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.ProfilerResultsResponse, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }
};

fn appendPagination(query: *std.ArrayList(QueryParam), start: ?u32, end: ?u32) !void {
    if (start) |s| {
        var buf: [16]u8 = undefined;
        const sv = try std.fmt.bufPrint(&buf, "{d}", .{s});
        try query.append(.{ .key = "start", .value = sv });
    }
    if (end) |e| {
        var buf: [16]u8 = undefined;
        const ev = try std.fmt.bufPrint(&buf, "{d}", .{e});
        try query.append(.{ .key = "end", .value = ev });
    }
}
