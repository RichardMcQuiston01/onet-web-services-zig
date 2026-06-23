const std = @import("std");

pub const OnetError = error{
    Unauthorized,
    Forbidden,
    NotFound,
    /// HTTP 422 — a structured error body is available via the `?*ApiErrorDetail`
    /// out-parameter on the calling method.
    ApiError,
    /// HTTP 429 — caller should back off before retrying.
    RateLimited,
    /// HTTP 5xx.
    ServerError,
    /// Any other non-2xx status.
    HttpError,
    /// Response body is not valid JSON or does not match the expected shape.
    InvalidResponse,
    /// TCP/TLS-level failure.
    NetworkError,
};

/// Populated on `OnetError.ApiError`; passed as `?*ApiErrorDetail` to methods.
pub const ApiErrorDetail = struct {
    message: []const u8,
};
