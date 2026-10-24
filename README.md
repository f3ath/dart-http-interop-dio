# dart-http-interop-dio
Dio [http_interop](https://pub.dev/packages/http_interop) adapter.

Import the extension to send an interop request through a Dio client:

```dart
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_dio/http_interop_dio.dart';

Future<void> main() async {
  final client = dio.Dio();
  try {
    final response = await client.requestInterop(Request(
      'GET',
      Uri.parse('https://example.com/'),
      Body.empty(),
      Headers(),
    ));
    print(response.statusCode);
    print(await response.body.decode(utf8));
  } finally {
    client.close();
  }
}
```

`requestInterop` uses Dio's configured headers, timeouts, redirect policy, status
validation, and interceptors. Headers on the interop request override matching
client defaults. Empty header lists are omitted from these overrides, so they do
not remove a configured default header. Empty string values are retained.

Request and response bodies use byte streams. The extension does not buffer the
bodies; helpers such as `decode` consume the response stream. Consume or cancel
the response body, and close the client when finished. A retry needs a fresh
request body unless the original stream supports replay.

Dio's default status validation rejects non-2xx responses with a `DioException`.
To receive all HTTP statuses as interop responses, configure the client before
sending requests:

```dart
client.options.validateStatus = (_) => true;
```

Transport failures still throw. Failures during response body consumption are
reported through the body stream.

Two current limitations apply:

- Dio uppercases method names, including custom methods whose casing may matter.
- The default IO adapter can decompress gzip responses while retaining the
  original `Content-Encoding` and `Content-Length` headers. These headers may not
  describe the returned bytes. Account for this when forwarding responses or
  decoding their content.
