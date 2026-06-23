const std = @import("std");

/// Pagination envelope fields present on all list endpoints.
pub const PageMeta = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
};

/// Generic paginated result pairing metadata with a typed item slice.
/// Note: because the JSON result array key name varies per endpoint
/// (`occupation`, `career`, `element`, etc.), `Page(T)` is not parsed
/// directly from JSON. It is constructed by each endpoint method after
/// parsing the raw response struct.
pub fn Page(comptime T: type) type {
    return struct {
        meta: PageMeta,
        items: []const T,
    };
}

/// Optional tags present on occupation and career objects.
pub const Tags = struct {
    bright_outlook: ?bool = null,
    green: ?bool = null,
    apprenticeship: ?bool = null,
};

/// Lightweight occupation reference used throughout responses.
pub const OccupationRef = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    tags: ?Tags = null,
};

/// An O*NET Content Model element (skill, ability, knowledge, etc.).
pub const Element = struct {
    id: []const u8,
    related: ?[]const u8 = null,
    name: []const u8,
    description: ?[]const u8 = null,
};

/// An O*NET Content Model element with an importance score (0–100).
pub const ScoredElement = struct {
    id: []const u8,
    related: ?[]const u8 = null,
    name: []const u8,
    description: ?[]const u8 = null,
    importance: ?u32 = null,
};

/// A task associated with an occupation.
pub const TaskRef = struct {
    id: []const u8,
    related: ?[]const u8 = null,
    title: []const u8,
};

/// A task with an importance score and optional category.
pub const ScoredTask = struct {
    id: []const u8,
    related: ?[]const u8 = null,
    title: []const u8,
    importance: ?u32 = null,
    category: ?[]const u8 = null,
};
