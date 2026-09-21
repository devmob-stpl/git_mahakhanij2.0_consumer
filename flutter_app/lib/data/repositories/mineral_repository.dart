import '../../domain/mineral.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

abstract class MineralRepository {
  Future<List<Mineral>> listMinerals();
  Future<Mineral?> getMineralById(String id);
  Future<List<StockPoint>> listStockPoints();
}

class MineralRepositoryImpl implements MineralRepository {
  final MockDb _db = MockDb();

  @override
  Future<List<Mineral>> listMinerals() async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.minerals;
  }

  @override
  Future<Mineral?> getMineralById(String id) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      return _db.minerals.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<StockPoint>> listStockPoints() async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.stockPoints;
  }
}
