import 'package:dio/dio.dart';

/// Logs request/response details in debug mode only.
///
/// MUST NOT log sensitive headers (Authorization, cookies) in production.
abstract class LoggingInterceptor extends Interceptor {}
