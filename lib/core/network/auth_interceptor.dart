import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
  }) : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _tokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] =
      'Bearer $token';
    }

    handler.next(options);
  }
}