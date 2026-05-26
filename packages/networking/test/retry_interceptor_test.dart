import 'package:dio/dio.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EddyScoutRetryInterceptor', () {
    test('parseRetryAfter supports seconds', () {
      final d = EddyScoutRetryInterceptor.parseRetryAfter(
        value: '5',
        now: DateTime(2026),
      );
      expect(d, const Duration(seconds: 5));
    });

    test('parseRetryAfter supports ISO-8601 dates', () {
      final now = DateTime.parse('2026-01-01T00:00:00Z');
      final d = EddyScoutRetryInterceptor.parseRetryAfter(
        value: '2026-01-01T00:00:03Z',
        now: now,
      );
      expect(d, const Duration(seconds: 3));
    });

    test('parseRetryAfter clamps past dates to zero', () {
      final now = DateTime.parse('2026-01-01T00:00:00Z');
      final d = EddyScoutRetryInterceptor.parseRetryAfter(
        value: '2025-12-31T23:59:59Z',
        now: now,
      );
      expect(d, Duration.zero);
    });

    test('parseRetryAfter returns null for unknown values', () {
      final d = EddyScoutRetryInterceptor.parseRetryAfter(
        value: 'not a duration',
        now: DateTime(2026),
      );
      expect(d, isNull);
    });

    test('retries once on connection error then succeeds', () async {
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        EddyScoutRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          baseDelay: Duration.zero,
        ),
      );
      dio.httpClientAdapter = _FlakyAdapter(
        onFetch: () {
          calls++;
          if (calls == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: '/data'),
              type: DioExceptionType.connectionError,
            );
          }
          return Response<dynamic>(
            requestOptions: RequestOptions(path: '/data'),
            statusCode: 200,
            data: '{"ok":true}',
          );
        },
      );

      final response = await dio.get<Map<String, dynamic>>(
        '/data',
        options: Options(responseType: ResponseType.json),
      );

      expect(response.statusCode, 200);
      expect(response.data?['ok'], isTrue);
      expect(calls, 2);
    });

    test('does not retry on 4xx (except 429)', () async {
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        EddyScoutRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          baseDelay: Duration.zero,
        ),
      );
      dio.httpClientAdapter = _SequenceAdapter(
        onFetch: () {
          calls++;
          return _SeqResponse(
            statusCode: 404,
            body: '{"error":"nope"}',
          );
        },
      );

      await expectLater(
        dio.get<void>('/notfound'),
        throwsA(isA<DioException>()),
      );
      expect(calls, 1);
    });

    test('retries on 5xx then succeeds', () async {
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        EddyScoutRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          baseDelay: Duration.zero,
        ),
      );
      dio.httpClientAdapter = _SequenceAdapter(
        onFetch: () {
          calls++;
          if (calls == 1) {
            return _SeqResponse(statusCode: 503, body: '{"error":"down"}');
          }
          return _SeqResponse(statusCode: 200, body: '{"ok":true}');
        },
      );

      final response = await dio.get<Map<String, dynamic>>(
        '/maybe',
        options: Options(responseType: ResponseType.json),
      );
      expect(response.statusCode, 200);
      expect(response.data?['ok'], isTrue);
      expect(calls, 2);
    });

    test('retries on 429 and uses Retry-After when present', () async {
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        EddyScoutRetryInterceptor(
          dio: dio,
          maxRetries: 1,
          baseDelay: Duration.zero,
        ),
      );
      dio.httpClientAdapter = _SequenceAdapter(
        onFetch: () {
          calls++;
          if (calls == 1) {
            return _SeqResponse(
              statusCode: 429,
              body: '{"error":"rate"}',
              headers: {'retry-after': '0'},
            );
          }
          return _SeqResponse(statusCode: 200, body: '{"ok":true}');
        },
      );

      final response = await dio.get<Map<String, dynamic>>(
        '/rate',
        options: Options(responseType: ResponseType.json),
      );
      expect(response.statusCode, 200);
      expect(calls, 2);
    });

    test('cancellation during backoff prevents retry', () async {
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        EddyScoutRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          baseDelay: const Duration(milliseconds: 200),
        ),
      );
      dio.httpClientAdapter = _FlakyAdapter(
        onFetch: () {
          calls++;
          throw DioException(
            requestOptions: RequestOptions(path: '/data'),
            type: DioExceptionType.connectionError,
          );
        },
      );

      final cancelToken = CancelToken();
      final future = dio.get<void>('/data', cancelToken: cancelToken);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cancelToken.cancel('cancel during backoff');

      await expectLater(future, throwsA(isA<DioException>()));
      expect(calls, 1);
    });
  });

  group('EddyScoutDioFactory', () {
    test('create adds retry interceptor', () {
      final dio = const EddyScoutDioFactory().create();

      expect(
        dio.interceptors.any((i) => i is EddyScoutRetryInterceptor),
        isTrue,
      );
    });
  });
}

class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter({required this.onFetch});

  final Response<dynamic> Function() onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = onFetch();
    return ResponseBody.fromString(
      response.data?.toString() ?? '',
      response.statusCode ?? 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _SeqResponse {
  _SeqResponse({
    required this.statusCode,
    required this.body,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter({required this.onFetch});

  final _SeqResponse Function() onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = onFetch();
    final headerMap = <String, List<String>>{
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...{
        for (final e in response.headers.entries) e.key: [e.value],
      },
    };
    return ResponseBody.fromString(
      response.body,
      response.statusCode,
      headers: headerMap,
    );
  }

  @override
  void close({bool force = false}) {}
}
