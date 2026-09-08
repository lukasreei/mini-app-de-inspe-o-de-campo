import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _tokenStorage.saveToken(response.accessToken);

    return response;
  }

  Future<UserModel> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  Future<bool> hasToken() async {
    final token = await _tokenStorage.getToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> logout() {
    return _tokenStorage.deleteToken();
  }
}
