import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/work_orders_repository.dart';
import 'work_order_detail_event.dart';
import 'work_order_detail_state.dart';

class WorkOrderDetailBloc
    extends Bloc<WorkOrderDetailEvent, WorkOrderDetailState> {
  WorkOrderDetailBloc({required WorkOrdersRepository workOrdersRepository})
    : _workOrdersRepository = workOrdersRepository,
      super(const WorkOrderDetailInitial()) {
    on<WorkOrderDetailRequested>(_onRequested);
  }

  final WorkOrdersRepository _workOrdersRepository;

  Future<void> _onRequested(
    WorkOrderDetailRequested event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    emit(const WorkOrderDetailLoading());

    try {
      final workOrder = await _workOrdersRepository.getWorkOrderById(
        event.workOrderId,
      );

      emit(WorkOrderDetailLoaded(workOrder: workOrder));
    } on DioException catch (error) {
      emit(WorkOrderDetailFailure(message: _getErrorMessage(error)));
    } catch (_) {
      emit(
        const WorkOrderDetailFailure(
          message: 'Não foi possível carregar a ordem de serviço.',
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

    if (error.response?.statusCode == 404) {
      return 'Ordem de serviço não encontrada.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado.';

      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor.';

      default:
        return 'Não foi possível carregar a ordem de serviço.';
    }
  }
}
