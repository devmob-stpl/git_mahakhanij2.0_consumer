import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/inventory.dart';
import '../data/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});

class InventoryState {
  final List<InventoryBalance> balances;
  final List<ConsumptionEntry> history;
  final bool isLoading;
  final String? error;

  const InventoryState({
    this.balances = const [],
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  InventoryState copyWith({
    List<InventoryBalance>? balances,
    List<ConsumptionEntry>? history,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      balances: balances ?? this.balances,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryRepository _repo;

  InventoryNotifier(this._repo) : super(const InventoryState(isLoading: true)) {
    loadPackageInventory('pkg-1');
  }

  Future<void> loadPackageInventory(String packageId) async {
    state = state.copyWith(isLoading: true);
    try {
      final balances = await _repo.listBalances(packageId);
      final history = await _repo.listConsumptionHistory(packageId);
      state = InventoryState(balances: balances, history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> recordConsumption({
    required String balanceId,
    required String packageId,
    required double quantityValue,
    required String purpose,
    required String userId,
    required String userName,
  }) async {
    try {
      await _repo.recordConsumption(
        balanceId: balanceId,
        packageId: packageId,
        quantityValue: quantityValue,
        purpose: purpose,
        userId: userId,
        userName: userName,
      );
      await loadPackageInventory(packageId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repo);
});
