# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A Zig library (module) for interacting with the [O*NET Web Services API](https://services.onetcenter.org/reference/apis). The target is a clean, idiomatic Zig package — not a CLI tool or binary.

## Build & Test

```sh
zig build              # build the library
zig build test         # run all tests
zig build test -- -f "filter"  # run tests matching a pattern
```

## Design Constraints (from README)

- All inputs must be in a **consistent format** across API endpoints
- All outputs must be in a **consistent format** across API endpoints
- All errors must be **consistent** across API endpoints
- JSON parsing via **Zig standard library only** (`std.json`)
- HTTP requests via **Zig standard library only** (`std.http`)
- HTTP status codes and error messages must match the **O*NET API specification**
- The package must be **thread-safe**

## Code Style

- Follow standard Zig conventions: `camelCase` for functions and variables, `PascalCase` for types and structs
- Prefer explicit error handling with `!T` return types and `try` / `catch`
- Use `std.testing` for all tests; keep test functions in the same file as the code under test
- Allocators should be accepted as parameters (caller controls memory); never use a global allocator
- Public API surface should be minimal and well-documented with doc comments (`///`)

## API Reference

- [Overview](https://services.onetcenter.org/reference/start/overview)
- [Endpoints](https://services.onetcenter.org/reference/apis)
- [Authorization](https://services.onetcenter.org/reference/start/authorization)
