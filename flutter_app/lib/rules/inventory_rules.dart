import '../domain/inventory.dart';
import '../domain/common.dart';

class ConsumptionCheck {
  final bool isAllowed;
  final String? reason;

  const ConsumptionCheck({
    required this.isAllowed,
    this.reason,
  });
}

class InventoryRules {
  InventoryRules._();

  static ConsumptionCheck canRecordConsumption({
    required InventoryBalance balance,
    required double requestedValue,
  }) {
    if (requestedValue <= 0) {
      return const ConsumptionCheck(
        isAllowed: false,
        reason: 'Enter a consumption quantity greater than zero.',
      );
    }

    final available = balance.currentAvailableBalance.value;
    if (requestedValue > available) {
      return ConsumptionCheck(
        isAllowed: false,
        reason: 'Drawdown quantity (${requestedValue.toStringAsFixed(1)} ${balance.currentAvailableBalance.unit}) exceeds available on-site balance (${available.toStringAsFixed(1)} ${balance.currentAvailableBalance.unit}).',
      );
    }

    return const ConsumptionCheck(isAllowed: true);
  }
}
