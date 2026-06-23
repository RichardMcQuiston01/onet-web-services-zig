const std = @import("std");
const common = @import("common.zig");

// ── Search / Browse ─────────────────────────────────────────────────────────

pub const SearchResponse = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    occupation: []const common.OccupationRef = &.{},
};

pub const BrowseOccupationRef = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    tags: ?common.Tags = null,
    datalevel: ?bool = null,
    zone: ?JobZoneRef = null,
};

pub const JobZoneRef = struct {
    code: u32,
    title: []const u8,
};

pub const BrowseResponse = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    occupation: []const BrowseOccupationRef = &.{},
};

// ── Occupation root ──────────────────────────────────────────────────────────

pub const ContentLink = struct {
    href: []const u8,
    title: []const u8,
};

pub const BrightOutlookCategory = struct {
    code: []const u8,
    title: []const u8,
};

pub const UpdatedContent = struct {
    title: []const u8,
    source: ?[]const u8 = null,
    year: ?u32 = null,
};

pub const UpdatedInfo = struct {
    year: u32,
    contents: []const UpdatedContent = &.{},
};

pub const OccupationRoot = struct {
    code: []const u8,
    title: []const u8,
    tags: ?common.Tags = null,
    description: ?[]const u8 = null,
    sample_of_reported_titles: []const []const u8 = &.{},
    also_see: []const common.OccupationRef = &.{},
    bright_outlook: []const BrightOutlookCategory = &.{},
    updated: ?UpdatedInfo = null,
    summary_contents: []const ContentLink = &.{},
    details_contents: []const ContentLink = &.{},
    custom_contents: []const ContentLink = &.{},
};

// ── Summary endpoints ────────────────────────────────────────────────────────

pub const ElementsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    element: []const common.Element = &.{},
};

pub const TasksPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    task: []const common.TaskRef = &.{},
};

pub const EducationLevel = struct {
    code: u32,
    title: []const u8,
    description: ?[]const u8 = null,
    percentage_of_respondents: ?u32 = null,
};

pub const EducationResponse = struct {
    response: []const EducationLevel = &.{},
};

pub const JobZone = struct {
    code: u32,
    title: []const u8,
    education: ?[]const u8 = null,
    related_experience: ?[]const u8 = null,
    job_training: ?[]const u8 = null,
    job_zone_examples: ?[]const u8 = null,
    svp_range: ?[]const u8 = null,
};

pub const RelatedOccupationsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    occupation: []const common.OccupationRef = &.{},
};

// ── Details endpoints ────────────────────────────────────────────────────────

pub const ScoredElementsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    element: []const common.ScoredElement = &.{},
};

pub const ScoredTasksPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    task: []const common.ScoredTask = &.{},
};

pub const WorkContextResponse = struct {
    percentage_of_respondents: ?u32 = null,
    description: []const u8,
};

pub const WorkContextElement = struct {
    id: []const u8,
    related: ?[]const u8 = null,
    name: []const u8,
    description: ?[]const u8 = null,
    context: ?u32 = null,
    response: []const WorkContextResponse = &.{},
};

pub const WorkContextPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    element: []const WorkContextElement = &.{},
};

// ── O*NET Data tree ──────────────────────────────────────────────────────────

pub const DataNode = struct {
    id: []const u8,
    name: []const u8,
    description: ?[]const u8 = null,
    href: ?[]const u8 = null,
    child: []const DataNode = &.{},
};

// ── Crosswalk ────────────────────────────────────────────────────────────────

pub const CrosswalkMatch = struct {
    code: []const u8,
    title: []const u8,
    occupation: []const common.OccupationRef = &.{},
};

pub const CrosswalkPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    match: []const CrosswalkMatch = &.{},
};

// ── Job Duties ───────────────────────────────────────────────────────────────

pub const JobDutyTask = struct {
    id: []const u8,
    title: []const u8,
};

pub const JobDutyTaskSets = struct {
    closely_related: []const JobDutyTask = &.{},
    less_related: []const JobDutyTask = &.{},
    full: []const JobDutyTask = &.{},
};

pub const OccupationWithTasks = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    tags: ?common.Tags = null,
    tasks: ?JobDutyTaskSets = null,
};

pub const JobDutyResultsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    occupation: []const OccupationWithTasks = &.{},
};

// ── Soft Skills ──────────────────────────────────────────────────────────────

pub const SoftSkillExample = struct {
    level: u32,
    description: []const u8,
};

pub const SoftSkill = struct {
    code: []const u8,
    title: []const u8,
    description: []const u8,
    example: []const SoftSkillExample = &.{},
};

pub const SoftSkillListing = struct {
    social: []const SoftSkill = &.{},
    thinking: []const SoftSkill = &.{},
};

pub const SoftSkillRef = struct {
    code: []const u8,
    title: []const u8,
    level: ?u32 = null,
    importance: ?u32 = null,
};

pub const OccupationWithSkills = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    tags: ?common.Tags = null,
    skills_matched: []const SoftSkillRef = &.{},
    skills_other: []const SoftSkillRef = &.{},
};

pub const SoftSkillResultsPage = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
    occupation: []const OccupationWithSkills = &.{},
};
