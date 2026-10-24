import 'package:dio/dio.dart' as dio;
import 'package:http_interop/http_interop.dart';

/// Sends HTTP interop requests through a configured [dio.Dio] client.
extension DioExt on dio.Dio {
  /// Sends [request] and returns a response with a streamed body.
  ///
  /// Uses Dio's request pipeline, including client defaults, status validation,
  /// and request, response, and error interceptors. Request headers override
  /// matching client defaults. Empty header lists are omitted from the request
  /// overrides; singleton lists become strings and longer lists are retained.
  ///
  /// Passes the request body as a byte stream and requests a streamed response.
  /// The extension does not buffer either body. Consume or cancel the returned
  /// body's stream, and close the Dio client when it is no longer needed.
  /// Retries require a fresh request body unless its stream supports replay.
  ///
  /// Throws a [dio.DioException] for transport failures or HTTP statuses rejected
  /// by Dio's configured status validation. With Dio's defaults, non-2xx
  /// responses are rejected. Errors while reading the response body are emitted
  /// by its stream.
  ///
  /// Dio uppercases the request method, including custom method names.
  /// Response headers are forwarded unchanged. The default IO adapter can
  /// decompress gzip bodies while retaining the original content encoding and
  /// length headers; those headers may therefore describe the compressed body.
  Future<Response> requestInterop(Request request) async {
    final response = await this.request<dio.ResponseBody>(
      request.uri.toString(),
      data: request.body.bytes,
      options: dio.Options(
        method: request.method,
        responseType: dio.ResponseType.stream,
        headers: {
          for (final entry in request.headers.entries)
            if (entry.value.isNotEmpty)
              entry.key: entry.value.length == 1
                  ? entry.value.first
                  : entry.value,
        },
      ),
    );
    return Response(
      response.statusCode!,
      Body(response.data!.stream),
      Headers.from(response.headers.map),
    );
  }
}
