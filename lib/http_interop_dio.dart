import 'package:dio/dio.dart' as dio;
import 'package:http_interop/http_interop.dart';

class ClientWrapper implements Handler {
  ClientWrapper(this._client);

  final dio.HttpClientAdapter _client;

  @override
  Future<Response> handle(Request request) async {
    final response =
        await _client.fetch(requestOptions(request), request.body.bytes, null);
    return Response(response.statusCode, Body.stream(response.stream),
        Headers.from(response.headers));
  }

  dio.RequestOptions requestOptions(Request request) => dio.RequestOptions(
      method: request.method,
      data: request.body.bytes,
      headers: request.headers,
      baseUrl: request.uri.toString());
}
