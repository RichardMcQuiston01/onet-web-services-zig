# onet-web-services-zig

A Zig library for interacting with the [O\*NET Web Services API](https://services.onetcenter.org/reference/start/overview).

## Design

- Consistent input format across all API endpoints
- Consistent output format across all API endpoints
- Consistent error types across all API endpoints
- JSON parsing and HTTP requests use the Zig standard library only
- HTTP status codes and error messages match the O\*NET API specification
- Thread-safe; no global state

## Resources

- [O\*NET Web Services Overview](https://services.onetcenter.org/reference/start/overview)
- [API Reference](https://services.onetcenter.org/reference/apis)
- [Authorization](https://services.onetcenter.org/reference/start/authorization)

## License

MIT © 2026 Richard McQuiston — see [LICENSE](LICENSE).
