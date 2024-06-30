import 'package:dio/dio.dart' as dio;
import 'package:http_interop/http_interop.dart';

extension HttpClientAdapterExt on dio.HttpClientAdapter {
  Future<Response> handleInterop(Request request) async {
    final response = await fetch(
        dio.RequestOptions(
            method: request.method,
            data: request.body.bytes,
            headers: request.headers,
            baseUrl: request.uri.toString()),
        request.body.bytes,
        null);
    return Response(response.statusCode, Body.stream(response.stream),
        Headers.from(response.headers));
  }
}

extension DioExt on dio.Dio {
  Future<Response> handleInterop(Request request) =>
      httpClientAdapter.handleInterop(request);
}
