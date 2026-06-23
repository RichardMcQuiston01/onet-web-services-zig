# O*NET Web Services Zig Client — Design Spec

**Date:** 2026-06-23  
**Status:** Approved

---

## Overview

A Zig 0.14.x library (`onet-web-services-zig`) providing typed, idiomatic access to all 7 O*NET Web Services API endpoint categories. Stdlib only — no third-party packages. Thread-safe.

---

## Constraints

| Constraint | Decision |
|---|---|
| Zig version | 0.14.x stable |
| HTTP | `std.http.Client` only |
| JSON | `std.json` only |
| Authentication | `X-API-Key` request header |
| Endpoint coverage | All 7 categories |
| API style | High-level typed methods |
| Client organization | Namespaced sub-clients |
| Allocator | Passed at call time (not init) |
| Testing | Fixture-based (`@embedFile`, no live network) |

---

## Architecture

`OnetClient` is the single entry point. It owns a `std.http.Client` (thread-safe, connection-pooled) and the API key. Seven sub-clients are embedded directly as fields — no heap allocation:

```
OnetClient
  ├── online  → OnlineClient  (/online/)
  ├── mnm     → MnmClient     (/mnm/)
  ├── mpp     → MppClient     (/mpp/)
  ├── veterans→ VeteransClient(/veterans/)
  ├── taxonomy→ TaxonomyClient(/taxonomy/)
  ├── database→ DatabaseClient(/database/)
  └── about   → AboutClient   (/about/)
```

Each sub-client holds a `*OnetClient` back-pointer. Usage:

```zig
const client = try OnetClient.init(allocator, "your-api-key");
defer client.deinit();

var err_detail: OnetError.ApiErrorDetail = undefined;
const result = try client.online.searchOccupations(allocator, .{ .keyword = "engineer" }, &err_detail);
defer result.deinit();
```

---

## File Structure

```
src/
  root.zig              — public entry point
  client.zig            — OnetClient struct
  http.zig              — internal fetch helper
  error.zig             — OnetError, ApiErrorDetail
  types/
    common.zig          — PageMeta, Page(T), Tags, OccupationRef, Element
    online.zig          — /online/ response structs
    mnm.zig             — /mnm/ response structs
    mpp.zig             — re-exports mnm.zig (identical shapes, Spanish)
    veterans.zig        — /veterans/ response structs
    taxonomy.zig        — /taxonomy/ response structs
    database.zig        — /database/ response structs
  endpoints/
    online.zig          — OnlineClient methods
    mnm.zig             — MnmClient methods
    mpp.zig             — MppClient methods
    veterans.zig        — VeteransClient methods
    taxonomy.zig        — TaxonomyClient methods
    database.zig        — DatabaseClient methods
    about.zig           — AboutClient methods
tests/
  fixtures/{category}/  — real JSON responses, one file per endpoint
  {category}_test.zig   — fixture-based parse tests
build.zig
```

---

## Core Shared Types (`src/types/common.zig`)

```zig
pub const PageMeta = struct {
    start: u32,
    end: u32,
    total: u32,
    prev: ?[]const u8 = null,
    next: ?[]const u8 = null,
};

pub fn Page(comptime T: type) type {
    return struct { meta: PageMeta, items: []const T };
}

pub const Tags = struct {
    bright_outlook: ?bool = null,
    green: ?bool = null,
    apprenticeship: ?bool = null,
};

pub const OccupationRef = struct {
    href: []const u8,
    code: []const u8,
    title: []const u8,
    tags: ?Tags = null,
};

pub const Element = struct {
    id: []const u8,
    related: ?[]const u8 = null,
    name: []const u8,
    description: ?[]const u8 = null,
};
```

All `parseFromSlice` calls use `ignore_unknown_fields: true`.

---

## Error Handling (`src/error.zig`)

```zig
pub const OnetError = error{
    Unauthorized, Forbidden, NotFound,
    ApiError,       // 422 — structured body available via ?*ApiErrorDetail out-param
    RateLimited,    // 429
    ServerError,    // 5xx
    HttpError,      // other non-2xx
    InvalidResponse,
    NetworkError,
};

pub const ApiErrorDetail = struct { message: []const u8 };
```

Methods that can return a structured 422 body accept `?*ApiErrorDetail` as an out-parameter. Callers that don't need the detail pass `null`.

---

## HTTP Layer (`src/http.zig`)

Internal `fetch` function:
1. Builds full URL: `https://services.onetcenter.org/ws/{path}?{query}`
2. Injects `X-API-Key` via `extra_headers`
3. Writes response body into an `ArrayList(u8)` passed as `response_storage`
4. Maps HTTP status → `OnetError` before returning bytes
5. On 422: parses `{ "error": "..." }` and populates the `?*ApiErrorDetail` out-param

---

## Endpoint Coverage

### OnlineClient (`/online/`)
Search: `searchOccupations`, `browseOccupations`  
Occupation root: `getOccupation`  
Summary (per-aspect methods): `getSummarySkills`, `getSummaryAbilities`, `getSummaryKnowledge`, `getSummaryWorkActivities`, `getSummaryWorkStyles`, `getSummaryInterests`, `getSummaryTasks`, `getSummaryEducation`, `getSummaryJobZone`, `getSummaryRelatedOccupations`  
Details (per-aspect methods): `getDetailsSkills`, `getDetailsAbilities`, `getDetailsKnowledge`, `getDetailsWorkActivities`, `getDetailsWorkStyles`, `getDetailsTasks`, `getDetailsWorkContext`  
Data: `listOnetData`  
Crosswalk: `searchCrosswalk`  
Job duties: `searchJobDuties`, `getJobDutyTasks`, `getJobDutyResults`  
Soft skills: `listSoftSkills`, `getSoftSkillResults`

### MnmClient (`/mnm/`)
`searchCareers`, `listCareers`, `listIndustries`, `getBrightOutlook`, `listCareerClusters`, `getCareersByInterest`, `getCareersByJobZone`, `getCareer`, `getCareerKnowledge`, `getCareerSkills`, `getCareerAbilities`, `getCareerPersonality`, `getCareerTechnology`, `getCareerEducation`, `getCareerJobOutlook`, `getCareerExploreMore`, `getInterestProfilerQuestions`, `getInterestProfilerResults`

### MppClient (`/mpp/`)
Same methods as MnmClient. `src/types/mpp.zig` re-exports `types/mnm.zig`.

### VeteransClient (`/veterans/`)
All MnmClient methods + `searchMilitaryJobs(keyword, branch, active, opts)`

### TaxonomyClient (`/taxonomy/`)
`convert(from_version, to_version, code)` → `TaxonomyResult`

### DatabaseClient (`/database/`)
`listTables`, `getTableInfo`, `getTableRows` (rows use `std.json.Value` — schema varies per table)

### AboutClient (`/about/`)
`getSystemInfo`

---

## Testing Strategy

Each `*_test.zig` uses `@embedFile` to load committed JSON fixtures, calls the internal parse function directly (no HTTP), and asserts field values. No live API calls in `zig build test`.

A `zig build fetch-fixtures` step (requires `ONET_API_KEY` env var) refreshes the fixture files manually.

---

## Implementation Order

1. `build.zig`
2. `src/error.zig`
3. `src/types/common.zig`
4. `src/http.zig`
5. `src/client.zig` skeleton
6. OnlineClient (types + endpoints + fixtures + tests)
7. MnmClient, MppClient, VeteransClient (types + endpoints + fixtures + tests)
8. TaxonomyClient, DatabaseClient, AboutClient
9. `src/root.zig`
10. `zig build fetch-fixtures` step
