const std = @import("std");

pub const TaxonomyOccupation = struct {
    code: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
};

pub const TaxonomyResult = struct {
    code: []const u8,
    title: []const u8,
    description: ?[]const u8 = null,
    occupation: []const TaxonomyOccupation = &.{},
};
