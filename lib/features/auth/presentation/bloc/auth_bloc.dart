import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final hasToken = await _authRepository.hasToken();

    if (!hasToken) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();

      emit(AuthAuthenticated(user: user));
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _authRepository.logout();

        emit(const AuthUnauthenticated());
        return;
      }

      emit(const AuthAuthenticated(offline: true));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user: response.user));
    } on DioException catch (error) {
      emit(AuthFailure(message: _getErrorMessage(error)));
    } catch (_) {
      emit(const AuthFailure(message: 'Não foi possível realizar o login.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();

    emit(const AuthUnauthenticated());
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado.';

      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor.';

      default:
        return 'Não foi possível realizar o login.';
    }
  }
}
