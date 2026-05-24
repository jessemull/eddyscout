import 'package:dio/dio.dart';

/// Normalizes [DioException] into domain-specific failure subtypes.
abstract class ErrorNormalizingInterceptor extends Interceptor {}
