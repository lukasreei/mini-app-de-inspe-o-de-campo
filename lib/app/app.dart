import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/inspections/data/repositories/inspections_repository.dart';
import '../features/inspections/presentation/bloc/inspection_sync_cubit.dart';
import '../features/work_orders/data/repositories/work_orders_repository.dart';
import '../features/work_orders/presentation/bloc/work_orders_bloc.dart';
import '../features/work_orders/presentation/bloc/work_orders_event.dart';
import '../features/work_orders/presentation/pages/ordens_servico_page.dart';

class App extends StatelessWidget {
  const App({
    required this.authRepository,
    required this.workOrdersRepository,
    required this.inspectionsRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final WorkOrdersRepository workOrdersRepository;
  final InspectionsRepository inspectionsRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: workOrdersRepository),
        RepositoryProvider.value(value: inspectionsRepository),
      ],
      child: BlocProvider(
        create: (_) =>
            AuthBloc(authRepository: authRepository)..add(const AuthStarted()),
        child: MaterialApp(
          title: 'Inspeção de Campo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => WorkOrdersBloc(
                  workOrdersRepository: context.read<WorkOrdersRepository>(),
                )..add(const WorkOrdersRequested()),
              ),
              BlocProvider(
                create: (_) => InspectionSyncCubit(
                  inspectionsRepository: context.read<InspectionsRepository>(),
                )..start(),
              ),
            ],
            child: const OrdensServicoPage(),
          );
        }

        return const LoginPage();
      },
    );
  }
}
