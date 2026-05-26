import 'package:dio/dio.dart';

/// Throws when [cancelToken] is already cancelled (Dio-shaped error).
void ensureCallableNotCancelled(CancelToken? cancelToken) {
  if (cancelToken?.isCancelled ?? false) {
    throw DioException(
      requestOptions: RequestOptions(path: 'cloud-functions'),
      type: DioExceptionType.cancel,
      message: 'Callable cancelled',
    );
  }
}
