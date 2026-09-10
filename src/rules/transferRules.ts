import type {
  InventoryBalance,
  MineralTransfer,
  Quantity,
  TransferDestination,
  TransferReason,
  TransferStatus,
} from '@/domain';
import { compareQuantity, formatQuantity, isZeroQuantity } from './quantity';
import { computeAvailableQuantity } from './inventoryRules';

export interface TransferCheck {
  allowed: boolean;
  reason?: string;
}

/**
 * Validates if a transfer request can be initiated against an inventory balance.
 */
export function canInitiateTransfer(
  balance: InventoryBalance,
  requested: Quantity,
): TransferCheck {
  if (requested.value <= 0 || isZeroQuantity(requested)) {
    return { allowed: false, reason: 'Enter a quantity greater than zero.' };
  }

  const available = computeAvailableQuantity(balance);

  if (compareQuantity(requested, available) > 0) {
    return {
      allowed: false,
      reason: `Only ${formatQuantity(available)} is available for transfer.`,
    };
  }

  return { allowed: true };
}

/**
 * Extracts a human-readable destination name regardless of destination variant.
 */
export function getTransferDestinationLabel(destination: TransferDestination): string {
  if (destination.kind === 'STOCKPOINT_RETURN') {
    return destination.stockPointName;
  }
  return destination.siteLabel;
}

/**
 * Generates an official Maharashtra minor mineral transfer e-TP number.
 * Format: "MH-TR-YYYY-XXXXXX"
 */
export function generateTransferEtpNumber(): string {
  const year = new Date().getFullYear();
  const randomSuffix = Math.floor(100000 + Math.random() * 900000);
  return `MH-TR-${year}-${randomSuffix}`;
}

/**
 * Generates QR payload string for Transfer e-TP inspection by mining / RTO squads.
 */
export function generateTransferQrPayload(transfer: Partial<MineralTransfer>): string {
  const destLabel = transfer.destination
    ? getTransferDestinationLabel(transfer.destination)
    : 'Site Destination';

  const payload = {
    etp: transfer.permit?.etpNumber ?? `MH-TR-${Date.now()}`,
    source: transfer.sourceLabel,
    destination: destLabel,
    mineralId: transfer.mineralId,
    qty: transfer.quantity ? `${transfer.quantity.value} ${transfer.quantity.unit}` : '0',
    veh: transfer.vehicleNumber,
    validUntil: transfer.permit?.validUntil ?? new Date(Date.now() + 86400000).toISOString(),
    type: 'MAHAKHANIJ_SURPLUS_TRANSFER_PASS',
  };
  return btoa(JSON.stringify(payload));
}

/**
 * Human readable label for transfer reason.
 */
export function formatTransferReason(reason: TransferReason): string {
  switch (reason) {
    case 'SURPLUS_RELOCATION':
      return 'Surplus Mineral Relocation';
    case 'PROJECT_HANDOVER':
      return 'Inter-Project Handover';
    case 'STOCKPOINT_RETURN':
      return 'Return to Mineral Place';
    case 'EXCAVATION_DISPOSAL':
      return 'Excavation Site Transfer';
    default:
      return reason;
  }
}

/**
 * Status tone and label for UI presentation with StatusBadge.
 */
export function formatTransferStatus(status: TransferStatus): {
  label: string;
  tone: 'info' | 'success' | 'warning' | 'danger' | 'neutral';
} {
  switch (status) {
    case 'DRAFT':
      return { label: 'Draft', tone: 'neutral' };
    case 'PERMIT_ISSUED':
      return { label: 'Permit Issued', tone: 'info' };
    case 'IN_TRANSIT':
      return { label: 'In Transit', tone: 'warning' };
    case 'RECEIVED':
      return { label: 'Received & Verified', tone: 'success' };
    case 'CANCELLED':
      return { label: 'Cancelled', tone: 'danger' };
  }
}


/**
 * User-friendly date-time formatter.
 */
export function formatDateTime(iso: string): string {
  return new Date(iso).toLocaleString('en-IN', {
    day: 'numeric',
    month: 'short',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
}
