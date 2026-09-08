import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();

  final apiClient = ApiClient(tokenStorage: tokenStorage);

  final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);

  final authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );

  runApp(App(authRepository: authRepository));
}
