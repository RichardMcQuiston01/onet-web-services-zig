const std = @import("std");
const mnm = @import("mnm.zig");

pub const CareerTags = mnm.CareerTags;
pub const CareerRef = mnm.CareerRef;
pub const CareersPage = mnm.CareersPage;
pub const IndustryRef = mnm.IndustryRef;
pub const IndustryListing = mnm.IndustryListing;
pub const CareerCluster = mnm.CareerCluster;
pub const CareerClusterListing = mnm.CareerClusterListing;
pub const AlsoCalled = mnm.AlsoCalled;
pub const ContentLink = mnm.ContentLink;
pub const CareerRoot = mnm.CareerRoot;
pub const KnowledgeElement = mnm.KnowledgeElement;
pub const KnowledgeCategory = mnm.KnowledgeCategory;
pub const TechnologyItem = mnm.TechnologyItem;
pub const TechnologyCategory = mnm.TechnologyCategory;
pub const TechnologyListing = mnm.TechnologyListing;
pub const EducationLevel = mnm.EducationLevel;
pub const EducationListing = mnm.EducationListing;
pub const OutlookCategory = mnm.OutlookCategory;
pub const SalaryInfo = mnm.SalaryInfo;
pub const JobOutlook = mnm.JobOutlook;
pub const ExploreMoreListing = mnm.ExploreMoreListing;
pub const AnswerOption = mnm.AnswerOption;
pub const ProfilerQuestion = mnm.ProfilerQuestion;
pub const ProfilerQuestionsPage = mnm.ProfilerQuestionsPage;
pub const ProfilerResult = mnm.ProfilerResult;
pub const ProfilerResultsResponse = mnm.ProfilerResultsResponse;

// ── Military-specific types ──────────────────────────────────────────────────

pub const MilitaryJobRef = struct {
    code: []const u8,
    title: []const u8,
    branch: ?[]const u8 = null,
    active: ?bool = null,
    occupation: []const mnm.CareerRef = &.{},
};

pub const MilitaryJobsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    match: []const MilitaryJobRef = &.{},
};
