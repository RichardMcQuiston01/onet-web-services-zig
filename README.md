# onet-web-services-zig

A Zig library for the [O\*NET Web Services API](https://services.onetcenter.org/reference/start/overview).

Covers all seven API categories (Online, MNM, MPP, Veterans, Taxonomy, Database, About) through namespaced sub-clients with typed request/response structs. Uses only the Zig standard library — no third-party dependencies.

## Requirements

- Zig 0.16.0
- An O\*NET Web Services API key — [register here](https://services.onetcenter.org/developer/)

## Installation

Add the package to your `build.zig.zon`:

```zig
.dependencies = .{
    .onet = .{
        .url = "https://github.com/richardmcquiston/onet-web-services-zig/archive/<commit>.tar.gz",
        .hash = "<hash>",
    },
},
```

Then import the module in your `build.zig`:

```zig
const onet_dep = b.dependency("onet", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("onet", onet_dep.module("onet-web-services"));
```

## Usage

### Initializing the client

`OnetClient` requires a `std.Io` instance for networking. The simplest approach is `std.Io.Threaded`:

```zig
const std = @import("std");
const onet = @import("onet");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();

var threaded_io: std.Io.Threaded = .init(allocator, .{});
defer threaded_io.deinit();
const io = threaded_io.io();

const client = try onet.OnetClient.init(allocator, io, "your-api-key");
defer client.deinit();
```

### Making requests

Each sub-client is accessed as a field on `OnetClient`. Allocators are passed per-call so you can use arenas for request-scoped memory:

```zig
// Search occupations
const result = try client.online.searchOccupations(allocator, .{
    .keyword = "software",
    .start = 1,
    .end = 10,
}, null);
defer result.deinit();

for (result.value.occupation) |occ| {
    std.debug.print("{s}: {s}\n", .{ occ.code, occ.title });
}
```

```zig
// Get a career from My Next Move
const career = try client.mnm.getCareer(allocator, "15-1252.00", null);
defer career.deinit();
std.debug.print("{s}\n", .{career.value.what_they_do.?});
```

```zig
// Convert an occupation code between taxonomy versions
const converted = try client.taxonomy.convert(allocator, "2010", "2019", "15-1141.00", null);
defer converted.deinit();
```

### Error handling

All methods return `OnetError!std.json.Parsed(T)`. For structured 422 error bodies, pass a pointer to an `ApiErrorDetail`:

```zig
var detail: onet.ApiErrorDetail = undefined;
const result = client.online.searchOccupations(allocator, params, &detail) catch |err| {
    if (err == onet.OnetError.ApiError) {
        std.debug.print("API error: {s}\n", .{detail.message});
    }
    return err;
};
```

`OnetError` values and their causes:

| Error | Cause |
|---|---|
| `Unauthorized` | 401 — invalid or missing API key |
| `Forbidden` | 403 — account lacks permission |
| `NotFound` | 404 — resource does not exist |
| `ApiError` | 422 — structured error from the API |
| `RateLimited` | 429 — request rate exceeded |
| `ServerError` | 5xx — O\*NET server error |
| `HttpError` | other non-2xx response |
| `InvalidResponse` | response body could not be parsed |
| `NetworkError` | TCP/TLS failure |

### Sub-clients

| Field | Prefix | Description |
|---|---|---|
| `client.online` | `/online/` | Full O\*NET occupational data |
| `client.mnm` | `/mnm/` | My Next Move (English) |
| `client.mpp` | `/mpp/` | Mi Próximo Paso (Spanish) |
| `client.veterans` | `/veterans/` | My Next Move for Veterans |
| `client.taxonomy` | `/taxonomy/` | Occupation code conversion |
| `client.database` | `/database/` | Raw O\*NET data tables |
| `client.about` | `/about/` | API version information |

## Building

```sh
zig build          # compile the library
zig build test     # run all tests
```

## API Reference

- [Overview](https://services.onetcenter.org/reference/start/overview)
- [Endpoints](https://services.onetcenter.org/reference/apis)
- [Authorization](https://services.onetcenter.org/reference/start/authorization)

## License

MIT © 2026 Richard McQuiston — see [LICENSE](LICENSE).
