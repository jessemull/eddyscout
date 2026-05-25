import 'package:dio/dio.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EddyScoutHttpClient', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.httpClientAdapter = _JsonAdapter();
    });

    test('getJson returns decoded map on success', () async {
      final client = EddyScoutHttpClient(dio: dio);
      final json = await client.getJson(Uri.parse('https://api.test/forecast'));

      expect(json, {'temperature': 55});
    });

    test('getNws sets geo+json accept header', () async {
      final client = EddyScoutHttpClient(dio: dio);
      await client.getNws(Uri.parse('https://api.test/nws'));

      final captured = (dio.httpClientAdapter as _JsonAdapter).lastHeaders;
      expect(captured?['Accept'], 'application/geo+json');
    });
  });
}

class _JsonAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastHeaders;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastHeaders = options.headers;
    return ResponseBody.fromString(
      '{"temperature":55}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
