import type { Address, GeoPoint, ID, ISODateTime, Quantity } from './common';
import type { InventoryScope } from './inventory';

/**
 * Status of an inter-site or surplus mineral transfer under Mahakhanij.
 */
export type TransferStatus =
  | 'DRAFT'
  | 'PERMIT_ISSUED'
  | 'IN_TRANSIT'
  | 'RECEIVED'
  | 'CANCELLED';

/**
 * Reason/Classification for moving mineral from Site A to another destination.
 */
export type TransferReason =
  | 'SURPLUS_RELOCATION'
  | 'PROJECT_HANDOVER'
  | 'STOCKPOINT_RETURN'
  | 'EXCAVATION_DISPOSAL';

/**
 * Where the transferred mineral is destined:
 * - PACKAGE: An internal package/project of the same or partner organization
 * - CONSUMER_SITE: Another personal site / property of a normal consumer
 * - STOCKPOINT_RETURN: Returning unused mineral back to a certified stock point
 * - EXTERNAL_SITE: Any other approved public work or disposal destination
 */
export type TransferDestination =
  | { kind: 'PACKAGE'; organizationId: ID; projectId: ID; packageId: ID; siteLabel: string; address?: Address; geo?: GeoPoint }
  | { kind: 'CONSUMER_SITE'; userId: ID; siteLabel: string; address: Address; geo?: GeoPoint }
  | { kind: 'STOCKPOINT_RETURN'; stockPointId: ID; stockPointName: string; address: Address; geo?: GeoPoint }
  | { kind: 'EXTERNAL_SITE'; siteLabel: string; address: Address; receiverContact?: string; geo?: GeoPoint };

/**
 * Official Electronic Transfer Permit (Transfer e-TP) issued for legal road transit.
 */
export interface TransferPermit {
  etpNumber: string;
  qrPayload: string;
  issuedAt: ISODateTime;
  validFrom: ISODateTime;
  validUntil: ISODateTime;
  originLabel: string;
  destinationLabel: string;
  mineralId: ID;
  permittedQuantity: Quantity;
  vehicleNumber: string;
  driverName?: string;
  driverMobileNumber?: string;
}

/**
 * Complete record of a mineral transfer transaction.
 */
export interface MineralTransfer {
  id: ID;
  transferNumber: string;
  sourceScope: InventoryScope;
  sourceLabel: string;
  destination: TransferDestination;
  mineralId: ID;
  quantity: Quantity;
  reason: TransferReason;
  remarks?: string;

  vehicleNumber: string;
  driverName?: string;
  driverMobileNumber?: string;

  permit: TransferPermit;
  status: TransferStatus;
  createdAt: ISODateTime;
  dispatchedAt?: ISODateTime;
  receivedAt?: ISODateTime;
  receivedByUserId?: ID;
}
