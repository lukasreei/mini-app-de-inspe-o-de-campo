import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/work_orders/data/datasources/work_orders_remote_data_source.dart';
import 'features/work_orders/data/repositories/work_orders_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();

  final apiClient = ApiClient(tokenStorage: tokenStorage);

  final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);

  final authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );

  final workOrdersRemoteDataSource = WorkOrdersRemoteDataSource(
    apiClient: apiClient,
  );

  final workOrdersRepository = WorkOrdersRepository(
    remoteDataSource: workOrdersRemoteDataSource,
  );

  runApp(
    App(
      authRepository: authRepository,
      workOrdersRepository: workOrdersRepository,
    ),
  );
}
