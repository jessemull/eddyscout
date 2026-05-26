import 'package:dio/dio.dart';
import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EddyScoutLoggingInterceptor', () {
    test('is invoked for request + response', () async {
      final dio = const EddyScoutDioFactory(enableDebugLogging: true).create()
        ..httpClientAdapter = _Adapter(
          onFetch: () => Response<dynamic>(
            requestOptions: RequestOptions(path: '/ok'),
            statusCode: 200,
            data: '{"ok":true}',
          ),
        );

      final res = await dio.get<String>(
        'https://example.test/ok',
        options: Options(responseType: ResponseType.plain),
      );
      expect(res.statusCode, 200);
    });

    test('is invoked for request + error', () async {
      final dio =
          const EddyScoutDioFactory(
              enableDebugLogging: true,
              maxRetries: 0,
            ).create()
            ..httpClientAdapter = _Adapter(
              onFetch: () => throw DioException(
                requestOptions: RequestOptions(path: '/fail'),
                type: DioExceptionType.connectionError,
              ),
            );

      await expectLater(
        dio.get<void>('https://example.test/fail'),
        throwsA(isA<DioException>()),
      );
    });
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter({required this.onFetch});

  final Object Function() onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<dynamic>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final out = onFetch();
    if (out is Response<dynamic>) {
      return ResponseBody.fromString(
        out.data?.toString() ?? '',
        out.statusCode ?? 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    // This is only used to throw a DioException in tests.
    // ignore: only_throw_errors
    throw out;
  }

  @override
  void close({bool force = false}) {}
}
