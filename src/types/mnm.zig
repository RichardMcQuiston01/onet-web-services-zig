const std = @import("std");
const common = @import("common.zig");

// ── Career references ────────────────────────────────────────────────────────

pub const CareerTags = struct {
    bright_outlook: ?bool = null,
};

pub const CareerRef = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    tags: ?CareerTags = null,
};

pub const CareersPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    career: []const CareerRef = &.{},
};

// ── Industry / Cluster browsing ──────────────────────────────────────────────

pub const IndustryRef = struct {
    href: []const u8,
    title: []const u8,
};

pub const IndustryListing = struct {
    start: u32,
    end: u32,
    total: u32,
    industry: []const IndustryRef = &.{},
};

pub const CareerCluster = struct {
    href: ?[]const u8 = null,
    code: []const u8,
    title: []const u8,
};

pub const CareerClusterListing = struct {
    career_cluster: []const CareerCluster = &.{},
};

// ── Career root ──────────────────────────────────────────────────────────────

pub const AlsoCalled = struct {
    title: []const u8,
    summary: ?bool = null,
};

pub const ContentLink = struct {
    href: []const u8,
    title: []const u8,
};

pub const CareerRoot = struct {
    code: []const u8,
    title: []const u8,
    tags: ?CareerTags = null,
    also_called: []const AlsoCalled = &.{},
    what_they_do: ?[]const u8 = null,
    on_the_job: []const []const u8 = &.{},
    word_cloud_terms: []const []const u8 = &.{},
    career_video: ?bool = null,
    contents: []const ContentLink = &.{},
};

// ── Career knowledge/skills/abilities (bare arrays with categories) ──────────

pub const KnowledgeElement = struct {
    id: []const u8,
    name: []const u8,
};

pub const KnowledgeCategory = struct {
    id: []const u8,
    name: []const u8,
    element: []const KnowledgeElement = &.{},
};

// ── Technology tools ─────────────────────────────────────────────────────────

pub const TechnologyItem = struct {
    name: []const u8,
    hot_technology: ?bool = null,
};

pub const TechnologyCategory = struct {
    title: []const u8,
    example: []const TechnologyItem = &.{},
};

pub const TechnologyListing = struct {
    category: []const TechnologyCategory = &.{},
};

// ── Education ────────────────────────────────────────────────────────────────

pub const EducationLevel = struct {
    code: u32,
    title: []const u8,
    percentage_of_respondents: ?u32 = null,
};

pub const EducationListing = struct {
    education: []const EducationLevel = &.{},
};

// ── Job Outlook ──────────────────────────────────────────────────────────────

pub const OutlookCategory = struct {
    code: []const u8,
    title: []const u8,
};

pub const SalaryInfo = struct {
    annual_10th_percentile: ?u64 = null,
    annual_median: ?u64 = null,
    annual_90th_percentile: ?u64 = null,
    hourly_10th_percentile: ?f64 = null,
    hourly_median: ?f64 = null,
    hourly_90th_percentile: ?f64 = null,
};

pub const JobOutlook = struct {
    outlook: ?OutlookCategory = null,
    salary: ?SalaryInfo = null,
    new_jobs: ?i64 = null,
    annual_job_openings: ?i64 = null,
};

// ── Explore More ─────────────────────────────────────────────────────────────

pub const ExploreMoreListing = struct {
    career: []const CareerRef = &.{},
};

// ── Interest Profiler ────────────────────────────────────────────────────────

pub const AnswerOption = struct {
    value: u32,
    name: []const u8,
};

pub const ProfilerQuestion = struct {
    index: u32,
    area: []const u8,
    text: []const u8,
};

pub const ProfilerQuestionsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    answer_option: []const AnswerOption = &.{},
    question: []const ProfilerQuestion = &.{},
};

pub const ProfilerResult = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
    score: u32,
};

pub const ProfilerResultsResponse = struct {
    careers: ?[]const u8 = null,
    result: []const ProfilerResult = &.{},
};
