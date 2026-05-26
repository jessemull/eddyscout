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
