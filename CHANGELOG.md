# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project does not yet follow semantic versioning.

---

## [Unreleased]

## [0.1.0] — 2026-06-23

### Added

- `OnetClient` — heap-allocated root client with `init(allocator, io, api_key)` / `deinit()`
- Seven namespaced sub-clients: `online`, `mnm`, `mpp`, `veterans`, `taxonomy`, `database`, `about`
- **Online** (`client.online`): search/browse occupations, occupation root, summary and detail endpoints for skills, abilities, knowledge, work activities, work styles, interests, tasks, education, job zone, related occupations, work context; O\*NET data tree, crosswalk search, job duties, and soft skills
- **MNM / MPP / Veterans** (`client.mnm`, `client.mpp`, `client.veterans`): career search and listing, industry/cluster/interest/job-zone browsing, career detail (knowledge, skills, abilities, personality, technology, education, job outlook, explore more), interest profiler questions and results; veterans client additionally exposes military job search
- **Taxonomy** (`client.taxonomy`): occupation code conversion between O\*NET taxonomy versions
- **Database** (`client.database`): table listing, table metadata, and paginated row retrieval
- **About** (`client.about`): system/version information
- `OnetError` error set covering all HTTP and parse failure modes
- `ApiErrorDetail` out-parameter for structured 422 error bodies
- Fixture-based test suite (19 tests, no live network calls)
- `.gitignore`, `CLAUDE.md`, `build.zig`
