import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import 'network_info.dart';

/// Interceptor to check internet connection before sending requests
class NetworkInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;

  NetworkInterceptor({required NetworkInfo networkInfo})
    : _networkInfo = networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await _networkInfo.isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NetworkException('No internet connection'),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    handler.next(options);
  }
}
