import '../../../../core/network/api_client.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.dio.get('/auth/me');

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}

//responsavel pela comunicacao com api
