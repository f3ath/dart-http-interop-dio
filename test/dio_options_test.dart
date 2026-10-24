import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_dio/http_interop_dio.dart';
import 'package:test/test.dart';

void main() {
  late dio.Dio client;
  late _RecordingAdapter adapter;

  setUp(() {
    adapter = _RecordingAdapter();
    client = dio.Dio()..httpClientAdapter = adapter;
  });

  tearDown(() => client.close());

  Future<void> sendRequest() async {
    final response = await client.requestInterop(
      Request(
        'GET',
        Uri.parse('https://example.com/'),
        Body.empty(),
        Headers(),
      ),
    );
    await response.body.bytes.drain<void>();
  }

  group('Dio configuration', () {
    test('preserves configured authorization headers', () async {
      client.options.headers['Authorization'] = 'Bearer test-token';

      await sendRequest();

      expect(
        adapter.options.headers['Authorization'],
        equals('Bearer test-token'),
      );
    });

    test('preserves configured timeouts', () async {
      client.options
        ..connectTimeout = const Duration(seconds: 1)
        ..sendTimeout = const Duration(seconds: 2)
        ..receiveTimeout = const Duration(seconds: 3);

      await sendRequest();

      expect(
        [
          adapter.options.connectTimeout,
          adapter.options.sendTimeout,
          adapter.options.receiveTimeout,
        ],
        equals([
          const Duration(seconds: 1),
          const Duration(seconds: 2),
          const Duration(seconds: 3),
        ]),
      );
    });

    test('preserves disabled redirects', () async {
      client.options.followRedirects = false;

      await sendRequest();

      expect(adapter.options.followRedirects, isFalse);
    });

    test('runs request interceptors before sending', () async {
      client.interceptors.add(
        dio.InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['X-From-Interceptor'] = 'present';
            handler.next(options);
          },
        ),
      );

      await sendRequest();

      expect(adapter.options.headers['X-From-Interceptor'], equals('present'));
    });

    test(
      'sends singleton headers and streamed body with request overrides',
      () async {
        client.options.headers['Content-Type'] = 'application/json';
        final response = await client.requestInterop(
          Request(
            'POST',
            Uri.parse('https://example.com/'),
            Body.text('hello'),
            Headers.from({
              'Content-Type': ['text/plain'],
              'Content-Length': ['5'],
            }),
          ),
        );
        await response.body.bytes.drain<void>();

        expect(adapter.options.contentType, equals('text/plain'));
        expect(adapter.body, equals('hello'.codeUnits));
      },
    );

    test('runs response interceptors before returning', () async {
      client.interceptors.add(
        dio.InterceptorsWrapper(
          onResponse: (response, handler) {
            response.headers.set('X-From-Interceptor', 'present');
            handler.next(response);
          },
        ),
      );

      final response = await client.requestInterop(
        Request(
          'GET',
          Uri.parse('https://example.com/'),
          Body.empty(),
          Headers(),
        ),
      );
      await response.body.bytes.drain<void>();

      expect(response.headers['x-from-interceptor'], equals(['present']));
    });

    test('honors configured status validation', () async {
      client.options.validateStatus = (_) => false;

      await expectLater(
        sendRequest(),
        throwsA(
          isA<dio.DioException>().having(
            (error) => error.type,
            'type',
            dio.DioExceptionType.badResponse,
          ),
        ),
      );
    });
  });
}

class _RecordingAdapter implements dio.HttpClientAdapter {
  late dio.RequestOptions options;
  final body = <int>[];

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        body.addAll(chunk);
      }
    }
    return dio.ResponseBody.fromString('ok', 200);
  }

  @override
  void close({bool force = false}) {}
}
