import '../../../../core/network/api_client.dart';
import '../models/work_order_model.dart';

class WorkOrdersRemoteDataSource {
  WorkOrdersRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<WorkOrderModel>> getWorkOrders() async {
    final response = await _apiClient.dio.get('/work-orders');

    final data = response.data as List<dynamic>;

    return data
        .map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
