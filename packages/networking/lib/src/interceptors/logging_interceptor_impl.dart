import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Debug-only request logging without sensitive headers or bodies.
class EddyScoutLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '→ ${options.method} ${options.uri}',
      name: 'eddyscout.networking',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'eddyscout.networking',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✕ ${err.response?.statusCode ?? err.type} ${err.requestOptions.uri}',
      name: 'eddyscout.networking',
    );
    handler.next(err);
  }
}
