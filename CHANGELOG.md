## [0.3.0] - 2026-10-23
### Added
- Document streaming, header conversion, error handling, and method-casing and gzip-response limitations.
- Add regression tests for URL preservation and Dio configuration; bind echo-test servers to an automatically assigned port.

### Changed
- BREAKING: Require Dart ^3.13.0 and http\_interop ^3.0.0.
- BREAKING: Rename Dio.handleInterop to Dio.requestInterop.
- BREAKING: Send requests through Dio's pipeline, honoring client defaults, interceptors, timeouts, redirect policy, and status validation. Rejected HTTP statuses now throw DioException.

### Fixed
- Preserve repeated slashes in request paths and query values by passing the absolute URI as the Dio request path.

### Removed
- BREAKING: Remove HttpClientAdapterExt and HttpClientAdapter.handleInterop; use Dio.requestInterop instead.

## [0.2.0] - 2024-06-30
### Changed
- Bump http\_interop to v2.0

## [0.1.0] - 2023-11-10
### Added
- Initial release

[0.3.0]: https://github.com/f3ath/dart-http-interop-dio/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/f3ath/dart-http-interop-dio/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/f3ath/dart-http-interop-dio/releases/tag/0.1.0
