import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));
  }

  late final Dio dio;
}
