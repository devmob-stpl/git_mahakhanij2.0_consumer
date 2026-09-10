import type { ID, ISODateTime, Quantity } from './common';

/**
 * WHO owns a stock of mineral.
 *
 * This discriminated union is what lets ONE inventory concept serve both user
 * types without forking the feature:
 *   - Organizations hold inventory per Package (the operational scope).
 *   - Normal Consumers hold inventory against themselves (flat model).
 *
 * Maps cleanly onto a Dart sealed class for the Flutter implementation.
 */
export type InventoryScope =
  | { kind: 'PACKAGE'; organizationId: ID; projectId: ID; packageId: ID }
  | { kind: 'CONSUMER'; userId: ID };

/**
 * High-level status of the mineral batch on site.
 * - ACTIVE_ON_SITE: Mineral is currently stored/active on site.
 * - FULLY_UTILIZED: Work has concluded; mineral has been fully utilized in construction.
 */
export type InventoryBalanceStatus = 'ACTIVE_ON_SITE' | 'FULLY_UTILIZED';

/**
 * The inventory mental model is:
 *
 *     Received − (Consumed + Transferred) = Available
 *
 * `availableQuantity` is DERIVED — always compute it via
 * `computeAvailableQuantity()` in @/rules/inventoryRules rather than trusting
 * a stored value, so the invariant can never drift.
 */
export interface InventoryBalance {
  id: ID;
  scope: InventoryScope;
  mineralId: ID;
  receivedQuantity: Quantity;
  consumedQuantity: Quantity;
  transferredQuantity?: Quantity;
  status?: InventoryBalanceStatus;
  lastUpdatedAt: ISODateTime;
}
