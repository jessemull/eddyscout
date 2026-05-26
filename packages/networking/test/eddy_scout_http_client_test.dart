import 'package:dio/dio.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EddyScoutHttpClient', () {
    late Dio dio;
    late _TestAdapter adapter;

    setUp(() {
      adapter = _TestAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
    });

    test('getJson returns decoded map on success', () async {
      final client = EddyScoutHttpClient(dio: dio);
      final json = await client.getJson(Uri.parse('https://api.test/forecast'));

      expect(json, {'temperature': 55});
    });

    test('get returns status and body for plain requests', () async {
      final client = EddyScoutHttpClient(dio: dio);
      final res = await client.get(Uri.parse('https://api.test/plain'));
      expect(res.statusCode, 200);
      expect(res.body, '{"ok":true}');
    });

    test('getNws sets geo+json accept header', () async {
      final client = EddyScoutHttpClient(dio: dio);
      await client.getNws(Uri.parse('https://api.test/nws'));

      expect(adapter.lastHeaders?['Accept'], 'application/geo+json');
    });

    test('getJson returns null on non-2xx', () async {
      final client = EddyScoutHttpClient(dio: dio);
      adapter.nextStatusCode = 503;
      final json = await client.getJson(
        Uri.parse('https://api.test/unavailable'),
      );
      expect(json, isNull);
    });

    test('getJson returns null on transport error', () async {
      final client = EddyScoutHttpClient(dio: dio);
      adapter.throwOnFetch = DioExceptionType.connectionError;
      final json = await client.getJson(Uri.parse('https://api.test/error'));
      expect(json, isNull);
    });

    test('getJson returns null when response is not a map', () async {
      final client = EddyScoutHttpClient(dio: dio);
      adapter.nextJsonBody = <dynamic>[1, 2, 3];
      final json = await client.getJson(Uri.parse('https://api.test/list'));
      expect(json, isNull);
    });

    test('getNwsJson sets geo+json accept header and returns map', () async {
      final client = EddyScoutHttpClient(dio: dio);
      final json = await client.getNwsJson(
        Uri.parse('https://api.test/nws_json'),
      );
      expect(adapter.lastHeaders?['Accept'], 'application/geo+json');
      expect(json, {'temperature': 55});
    });

    test('close closes underlying dio', () {
      final client = EddyScoutHttpClient(dio: dio);
      final close = client.close;
      close();
      expect(close, returnsNormally);
    });
  });
}

class _TestAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastHeaders;
  int nextStatusCode = 200;
  Object? nextJsonBody = const {'temperature': 55};
  String nextPlainBody = '{"temperature":55}';
  DioExceptionType? throwOnFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastHeaders = options.headers;
    final toThrow = throwOnFetch;
    if (toThrow != null) {
      throwOnFetch = null;
      throw DioException(requestOptions: options, type: toThrow);
    }

    final isPlain = options.responseType == ResponseType.plain;
    if (isPlain || options.path.endsWith('/plain')) {
      final body = options.path.endsWith('/plain')
          ? '{"ok":true}'
          : nextPlainBody;
      return ResponseBody.fromString(
        body,
        nextStatusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    final body = nextJsonBody;
    if (body is Map) {
      return ResponseBody.fromString(
        '{"temperature":55}',
        nextStatusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (body is List) {
      return ResponseBody.fromString(
        '[1,2,3]',
        nextStatusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      'null',
      nextStatusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
