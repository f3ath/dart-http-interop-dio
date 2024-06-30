import 'package:dio/dio.dart' as dio;
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_dio/http_interop_dio.dart';
import 'package:test/test.dart';

void main() {
  group('Smoke test', () {
    test('can call example.com', () async {
      final request =
          Request('get', Uri.parse('https://example.com'), Body(), Headers());
      final response = await dio.Dio().handleInterop(request);
      expect(response.statusCode, equals(200));
    });
  });
}
