import type { InventoryBalance, MineralCategory, Quantity } from '@/domain';
import { compareQuantity, formatQuantity, subtractQuantity } from './quantity';

/**
 * INVENTORY SOURCING MODEL:
 *
 *   Active on Site = Total Sourced (Received) − Transferred Out
 *   (or 0 if marked FULLY_UTILIZED)
 */
export function computeAvailableQuantity(balance: InventoryBalance): Quantity {
  if (balance.status === 'FULLY_UTILIZED') {
    return { value: 0, unit: balance.receivedQuantity.unit };
  }

  if (balance.transferredQuantity) {
    return subtractQuantity(balance.receivedQuantity, balance.transferredQuantity);
  }

  return balance.receivedQuantity;
}

export function isStockDepleted(balance: InventoryBalance): boolean {
  if (balance.status === 'FULLY_UTILIZED') return true;
  const available = computeAvailableQuantity(balance);
  return available.value <= 0;
}

export function formatMineralCategory(category: MineralCategory): string {
  switch (category) {
    case 'SAND':
      return 'Sand & Riverbed';
    case 'STONE_AGGREGATE':
      return 'Stone & Aggregates';
    case 'GRAVEL':
      return 'Gravel & Grit';
    case 'MURUM':
      return 'Murrum & Soil';
    case 'BLACK_TRAP':
      return 'Basalt & Hard Rock';
    case 'OTHER':
    default:
      return 'Minor Minerals';
  }
}

export interface ConsumptionCheck {
  allowed: boolean;
  /** User-facing explanation when `allowed` is false. */
  reason?: string;
}

export function canRecordConsumption(
  balance: InventoryBalance,
  requested: Quantity,
): ConsumptionCheck {
  if (requested.value <= 0) {
    return { allowed: false, reason: 'Enter a quantity greater than zero.' };
  }

  const available = computeAvailableQuantity(balance);

  if (compareQuantity(requested, available) > 0) {
    return {
      allowed: false,
      reason: `Only ${formatQuantity(available)} is available on site.`,
    };
  }

  return { allowed: true };
}
