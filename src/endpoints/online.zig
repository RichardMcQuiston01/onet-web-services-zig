const std = @import("std");
const http = @import("../http.zig");
const err = @import("../error.zig");
const t = @import("../types/online.zig");
const common = @import("../types/common.zig");

const OnetError = err.OnetError;
const ApiErrorDetail = err.ApiErrorDetail;
const QueryParam = http.QueryParam;

pub const OnlineClient = struct {
    http_client: *std.http.Client,
    api_key: []const u8,

    // ── Search / Browse ───────────────────────────────────────────────────

    pub const SearchParams = struct {
        keyword: []const u8,
        start: ?u32 = null,
        end: ?u32 = null,
    };

    pub fn searchOccupations(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        params: SearchParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.SearchResponse) {
        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();

        query.append(.{ .key = "keyword", .value = params.keyword }) catch return OnetError.NetworkError;
        if (params.start) |s| {
            var buf: [16]u8 = undefined;
            const sv = std.fmt.bufPrint(&buf, "{d}", .{s}) catch return OnetError.NetworkError;
            query.append(.{ .key = "start", .value = sv }) catch return OnetError.NetworkError;
        }
        if (params.end) |e| {
            var buf: [16]u8 = undefined;
            const ev = std.fmt.bufPrint(&buf, "{d}", .{e}) catch return OnetError.NetworkError;
            query.append(.{ .key = "end", .value = ev }) catch return OnetError.NetworkError;
        }

        const body = try http.fetch(self.http_client, allocator, self.api_key, "/online/search", query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.SearchResponse, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub const BrowseParams = struct {
        start: ?u32 = null,
        end: ?u32 = null,
    };

    pub fn browseOccupations(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.BrowseResponse) {
        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, "/online/browse/occupations", query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.BrowseResponse, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Occupation root ───────────────────────────────────────────────────

    pub fn getOccupation(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.OccupationRoot) {
        var path_buf: [64]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/", .{code}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.OccupationRoot, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Summary endpoints ─────────────────────────────────────────────────

    fn getSummaryElements(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        aspect: []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.ElementsPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/summary/{s}", .{ code, aspect }) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.ElementsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getSummarySkills(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ElementsPage) {
        return self.getSummaryElements(allocator, code, "skills", params, err_detail);
    }

    pub fn getSummaryAbilities(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ElementsPage) {
        return self.getSummaryElements(allocator, code, "abilities", params, err_detail);
    }

    pub fn getSummaryKnowledge(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ElementsPage) {
        return self.getSummaryElements(allocator, code, "knowledge", params, err_detail);
    }

    pub fn getSummaryWorkActivities(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ElementsPage) {
        return self.getSummaryElements(allocator, code, "work_activities", params, err_detail);
    }

    pub fn getSummaryWorkStyles(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ElementsPage) {
        return self.getSummaryElements(allocator, code, "work_styles", params, err_detail);
    }

    pub fn getSummaryInterests(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ElementsPage) {
        return self.getSummaryElements(allocator, code, "interests", params, err_detail);
    }

    pub fn getSummaryTasks(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.TasksPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/summary/tasks", .{code}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.TasksPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getSummaryEducation(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.EducationResponse) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/summary/education", .{code}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.EducationResponse, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getSummaryJobZone(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.JobZone) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/summary/job_zone", .{code}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.JobZone, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getSummaryRelatedOccupations(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.RelatedOccupationsPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/summary/related_occupations", .{code}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.RelatedOccupationsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Details endpoints ─────────────────────────────────────────────────

    fn getDetailsScoredElements(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        aspect: []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.ScoredElementsPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/details/{s}", .{ code, aspect }) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.ScoredElementsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getDetailsSkills(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ScoredElementsPage) {
        return self.getDetailsScoredElements(allocator, code, "skills", params, err_detail);
    }

    pub fn getDetailsAbilities(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ScoredElementsPage) {
        return self.getDetailsScoredElements(allocator, code, "abilities", params, err_detail);
    }

    pub fn getDetailsKnowledge(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ScoredElementsPage) {
        return self.getDetailsScoredElements(allocator, code, "knowledge", params, err_detail);
    }

    pub fn getDetailsWorkActivities(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ScoredElementsPage) {
        return self.getDetailsScoredElements(allocator, code, "work_activities", params, err_detail);
    }

    pub fn getDetailsWorkStyles(self: *const OnlineClient, allocator: std.mem.Allocator, code: []const u8, params: BrowseParams, err_detail: ?*ApiErrorDetail) OnetError!std.json.Parsed(t.ScoredElementsPage) {
        return self.getDetailsScoredElements(allocator, code, "work_styles", params, err_detail);
    }

    pub const TaskSort = enum { category, importance, title };

    pub fn getDetailsTasks(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        sort: ?TaskSort,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.ScoredTasksPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/details/tasks", .{code}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        if (sort) |s| query.append(.{ .key = "sort", .value = @tagName(s) }) catch return OnetError.NetworkError;
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.ScoredTasksPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getDetailsWorkContext(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        code: []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.WorkContextPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/occupations/{s}/details/work_context", .{code}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.WorkContextPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── O*NET Data tree ───────────────────────────────────────────────────

    pub fn listOnetData(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        data_type: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed([]const t.DataNode) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/onet_data/{s}/", .{data_type}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice([]const t.DataNode, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Crosswalk ─────────────────────────────────────────────────────────

    pub const CrosswalkParams = struct {
        keyword: ?[]const u8 = null,
        branch: ?[]const u8 = null,
        active: ?bool = null,
        start: ?u32 = null,
        end: ?u32 = null,
    };

    pub fn searchCrosswalk(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        system: []const u8,
        params: CrosswalkParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.CrosswalkPage) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/crosswalks/{s}", .{system}) catch return OnetError.NetworkError;

        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        if (params.keyword) |k| query.append(.{ .key = "keyword", .value = k }) catch return OnetError.NetworkError;
        if (params.branch) |b| query.append(.{ .key = "branch", .value = b }) catch return OnetError.NetworkError;
        if (params.active) |a| query.append(.{ .key = "active", .value = if (a) "true" else "false" }) catch return OnetError.NetworkError;
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.CrosswalkPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Job Duties ────────────────────────────────────────────────────────

    pub fn searchJobDuties(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        keyword: []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.SearchResponse) {
        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();
        query.append(.{ .key = "keyword", .value = keyword }) catch return OnetError.NetworkError;
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, "/online/job_duties/", query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.SearchResponse, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getJobDutyTasks(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        occupation_code: []const u8,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed([]const t.JobDutyTask) {
        var path_buf: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "/online/job_duties/{s}/", .{occupation_code}) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, path, &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice([]const t.JobDutyTask, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getJobDutyResults(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        task_ids: []const []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.JobDutyResultsPage) {
        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();

        var ids_buf = std.ArrayList(u8).init(allocator);
        defer ids_buf.deinit();
        for (task_ids, 0..) |id, i| {
            if (i > 0) ids_buf.append(',') catch return OnetError.NetworkError;
            ids_buf.appendSlice(id) catch return OnetError.NetworkError;
        }
        query.append(.{ .key = "tasks", .value = ids_buf.items }) catch return OnetError.NetworkError;
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, "/online/job_duties/results/", query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.JobDutyResultsPage, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    // ── Soft Skills ───────────────────────────────────────────────────────

    pub fn listSoftSkills(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.SoftSkillListing) {
        const body = try http.fetch(self.http_client, allocator, self.api_key, "/online/soft_skills/", &.{}, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.SoftSkillListing, allocator, body, .{
            .ignore_unknown_fields = true,
        }) catch return OnetError.InvalidResponse;
    }

    pub fn getSoftSkillResults(
        self: *const OnlineClient,
        allocator: std.mem.Allocator,
        skill_codes: []const []const u8,
        params: BrowseParams,
        err_detail: ?*ApiErrorDetail,
    ) OnetError!std.json.Parsed(t.SoftSkillResultsPage) {
        var query = std.ArrayList(QueryParam).init(allocator);
        defer query.deinit();

        var codes_buf = std.ArrayList(u8).init(allocator);
        defer codes_buf.deinit();
        for (skill_codes, 0..) |code, i| {
            if (i > 0) codes_buf.append(',') catch return OnetError.NetworkError;
            codes_buf.appendSlice(code) catch return OnetError.NetworkError;
        }
        query.append(.{ .key = "skills", .value = codes_buf.items }) catch return OnetError.NetworkError;
        appendPagination(&query, params.start, params.end) catch return OnetError.NetworkError;

        const body = try http.fetch(self.http_client, allocator, self.api_key, "/online/soft_skills/results/", query.items, err_detail);
        defer allocator.free(body);

        return std.json.parseFromSlice(t.SoftSkillResultsPage, allocator, body, .{
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
