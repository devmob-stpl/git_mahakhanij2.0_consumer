import '../../domain/order.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

abstract class OrderRepository {
  Future<List<Order>> listOrders({String? orgId, String? consumerId});
  Future<Order?> getOrderById(String id);
  Future<Order> createOrder(Order order);
}

class OrderRepositoryImpl implements OrderRepository {
  final MockDb _db = MockDb();

  @override
  Future<List<Order>> listOrders({String? orgId, String? consumerId}) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    if (orgId != null) {
      return _db.orders.where((o) => o.organizationId == orgId).toList();
    }
    if (consumerId != null) {
      return _db.orders.where((o) => o.consumerUserId == consumerId).toList();
    }
    return _db.orders;
  }

  @override
  Future<Order?> getOrderById(String id) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      return _db.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    _db.orders.insert(0, order);
    return order;
  }
}
