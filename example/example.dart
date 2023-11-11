import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:http_interop_dio/http_interop_dio.dart';

void main() async {
  final d = dio.Dio();
  final request =
      Request('get', Uri.parse('https://example.com'), Body(), Headers());
  final response = await ClientWrapper(d.httpClientAdapter).handle(request);
  print('Status code: ${response.statusCode}');
  print('Headers: ${response.headers}');
  print('Body: ${await response.body.decode(utf8)}');
}
