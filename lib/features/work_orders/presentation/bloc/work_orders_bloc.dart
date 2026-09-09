import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/work_orders_repository.dart';
import 'work_orders_event.dart';
import 'work_orders_state.dart';

class WorkOrdersBloc extends Bloc<WorkOrdersEvent, WorkOrdersState> {
  WorkOrdersBloc({required WorkOrdersRepository workOrdersRepository})
    : _workOrdersRepository = workOrdersRepository,
      super(const WorkOrdersInitial()) {
    on<WorkOrdersRequested>(_onRequested);
    on<WorkOrdersRefreshed>(_onRefreshed);
  }

  final WorkOrdersRepository _workOrdersRepository;

  Future<void> _onRequested(
    WorkOrdersRequested event,
    Emitter<WorkOrdersState> emit,
  ) async {
    emit(const WorkOrdersLoading());

    await _loadWorkOrders(emit);
  }

  Future<void> _onRefreshed(
    WorkOrdersRefreshed event,
    Emitter<WorkOrdersState> emit,
  ) async {
    await _loadWorkOrders(emit);
  }

  Future<void> _loadWorkOrders(Emitter<WorkOrdersState> emit) async {
    try {
      final workOrders = await _workOrdersRepository.getWorkOrders();

      if (workOrders.isEmpty) {
        emit(const WorkOrdersEmpty());
        return;
      }

      emit(WorkOrdersLoaded(workOrders: workOrders));
    } on DioException catch (error) {
      emit(WorkOrdersFailure(message: _getErrorMessage(error)));
    } catch (_) {
      emit(
        const WorkOrdersFailure(
          message: 'Não foi possível carregar as ordens de serviço.',
        ),
      );
    }
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
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Tempo de conexão esgotado.';

      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor.';

      default:
        return 'Não foi possível carregar as ordens de serviço.';
    }
  }
}
