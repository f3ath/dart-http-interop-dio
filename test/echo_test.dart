import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_dio/http_interop_dio.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late dio.HttpClientAdapter client;
  late Handler handler;
  final host = 'localhost';
  final port = 8000;

  setUp(() async {
    client = dio.HttpClientAdapter();
    handler = ClientWrapper(client);
    server = await HttpServer.bind(host, port);
    server.listen((rq) async {
      rq.response.statusCode = 200;
      rq.response.headers.add('Content-Type', 'application/json');
      rq.response.headers
          .add('Set-Cookie', 'k1=v1; Expires=Thu, 24 Feb 2033 07:28:00 GMT');
      rq.response.headers
          .add('Set-Cookie', 'k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT');
      rq.response.headers.add('Vary', 'Accept');
      rq.response.headers.add('Vary', 'Accept-Language');
      rq.response.headers.add('Vary', 'Accept-Encoding');
      final headers = <String, List<String>>{};
      rq.headers.forEach((name, values) {
        headers[name] = values;
      });
      rq.response.write(jsonEncode({
        'request': {
          'uri': rq.uri.toString(),
          'method': rq.method.toLowerCase(),
          'headers': headers,
          'body_bytes': await rq.expand((e) => e).toList(),
        }
      }));
      await rq.response.close();
    });
  });

  tearDown(() {
    client.close();
    return server.close();
  });

  group('Smoke test', () {
    test('headers (un)folding', () async {
      final response = await handler.handle(Request(
          'post',
          Uri(host: host, port: port, scheme: 'http'),
          Body.text('Привет', utf8),
          Headers.from({
            'Accept-Encoding': ['deflate', 'gzip;q=1.0', '*;q=0.5']
          })));
      expect(response.statusCode, equals(200));
      final json = await response.body.decodeJson();
      expect(response.statusCode, equals(200));
      expect(
          response.headers['set-cookie'],
          equals([
            'k1=v1; Expires=Thu, 24 Feb 2033 07:28:00 GMT',
            'k2=v2; Expires=Thu, 24 Feb 2033 07:28:00 GMT'
          ]));
      expect(response.headers['vary'],
          equals(['Accept, Accept-Language, Accept-Encoding']));
      expect(json['request']['method'], equals('post'));
      expect(json['request']['headers']['accept-encoding'],
          equals(['deflate, gzip;q=1.0, *;q=0.5']));
      expect(json['request']['body_bytes'],
          equals([208, 159, 209, 128, 208, 184, 208, 178, 208, 181, 209, 130]));
    });
  });
}
