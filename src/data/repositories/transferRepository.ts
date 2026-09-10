import type {
  ID,
  InventoryScope,
  MineralTransfer,
  Quantity,
  TransferDestination,
  TransferReason,
} from '@/domain';
import {
  addQuantity,
  canInitiateTransfer,
  generateTransferEtpNumber,
  generateTransferQrPayload,
  getTransferDestinationLabel,
} from '@/rules';
import { request } from '../client';
import { db } from '../db';

export interface CreateTransferInput {
  inventoryBalanceId: ID;
  destination: TransferDestination;
  quantity: Quantity;
  reason: TransferReason;
  remarks?: string;
  vehicleNumber: string;
  driverName?: string;
  driverMobileNumber?: string;
  userId: ID;
}

export interface CreateTransferResult {
  transfer: MineralTransfer;
  sourceBalance: import('@/domain').InventoryBalance;
}

export const transferRepository = {
  listAll: (): Promise<MineralTransfer[]> =>
    request(() =>
      [...db.transfers].sort((a, b) => b.createdAt.localeCompare(a.createdAt)),
    ),

  listByScope: (scope: InventoryScope): Promise<MineralTransfer[]> =>
    request(() => {
      return db.transfers
        .filter((t) => {
          if (scope.kind === 'PACKAGE') {
            return (
              (t.sourceScope.kind === 'PACKAGE' &&
                t.sourceScope.packageId === scope.packageId) ||
              (t.destination.kind === 'PACKAGE' &&
                t.destination.packageId === scope.packageId)
            );
          } else {
            return (
              (t.sourceScope.kind === 'CONSUMER' &&
                t.sourceScope.userId === scope.userId) ||
              (t.destination.kind === 'CONSUMER_SITE' &&
                t.destination.userId === scope.userId)
            );
          }
        })
        .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    }),

  listByBalanceId: (balanceId: ID): Promise<MineralTransfer[]> =>
    request(() => {
      const balance = db.inventoryBalances.find((b) => b.id === balanceId);
      if (!balance) return [];
      const balanceScope = balance.scope;
      return db.transfers
        .filter((t) => {
          if (balanceScope.kind === 'PACKAGE') {
            return (
              t.sourceScope.kind === 'PACKAGE' &&
              t.sourceScope.packageId === balanceScope.packageId &&
              t.mineralId === balance.mineralId
            );
          } else {
            return (
              t.sourceScope.kind === 'CONSUMER' &&
              t.sourceScope.userId === balanceScope.userId &&
              t.mineralId === balance.mineralId
            );
          }
        })
        .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    }),

  getById: (transferId: ID): Promise<MineralTransfer | null> =>
    request(() => db.transfers.find((t) => t.id === transferId) ?? null),

  getByPermitNumber: (etpNumber: string): Promise<MineralTransfer | null> =>
    request(
      () =>
        db.transfers.find((t) => t.permit.etpNumber.trim().toUpperCase() === etpNumber.trim().toUpperCase()) ?? null,
    ),

  create: (input: CreateTransferInput): Promise<CreateTransferResult> =>
    request(() => {
      const balance = db.inventoryBalances.find(
        (b) => b.id === input.inventoryBalanceId,
      );
      if (!balance) throw new Error('Source inventory balance not found');

      const check = canInitiateTransfer(balance, input.quantity);
      if (!check.allowed) {
        throw new Error(check.reason ?? 'Cannot initiate transfer');
      }

      const now = new Date();
      const validUntil = new Date(now.getTime() + 24 * 60 * 60 * 1000); // 24-hour validity
      const etpNumber = generateTransferEtpNumber();

      // Resolve source label
      let sourceLabel = 'Origin Site';
      const balanceScope = balance.scope;
      if (balanceScope.kind === 'PACKAGE') {
        const pkg = db.packages.find((p) => p.id === balanceScope.packageId);
        sourceLabel = pkg ? pkg.name : `Package ${balanceScope.packageId}`;
      } else {
        const user = db.users.find((u) => u.id === balanceScope.userId);
        sourceLabel = (user as any)?.deliveryAddress?.line1
          ? `${(user as any).deliveryAddress.line1}, ${(user as any).deliveryAddress.district}`
          : 'Registered Consumer Site';
      }

      const transferNumber = `TR-${now.getFullYear()}-${Math.floor(10000 + Math.random() * 90000)}`;

      const destinationLabel = getTransferDestinationLabel(input.destination);

      const permit = {
        etpNumber,
        qrPayload: '',
        issuedAt: now.toISOString(),
        validFrom: now.toISOString(),
        validUntil: validUntil.toISOString(),
        originLabel: sourceLabel,
        destinationLabel,
        mineralId: balance.mineralId,
        permittedQuantity: input.quantity,
        vehicleNumber: input.vehicleNumber.trim().toUpperCase(),
        ...(input.driverName ? { driverName: input.driverName.trim() } : {}),
        ...(input.driverMobileNumber ? { driverMobileNumber: input.driverMobileNumber.trim() } : {}),
      };

      permit.qrPayload = generateTransferQrPayload({
        sourceLabel,
        destination: input.destination,
        mineralId: balance.mineralId,
        quantity: input.quantity,
        vehicleNumber: permit.vehicleNumber,
        permit,
      });

      const transfer: MineralTransfer = {
        id: `tr-${db.transfers.length + 1}-${Date.now()}`,
        transferNumber,
        sourceScope: balance.scope,
        sourceLabel,
        destination: input.destination,
        mineralId: balance.mineralId,
        quantity: input.quantity,
        reason: input.reason,
        ...(input.remarks ? { remarks: input.remarks.trim() } : {}),
        vehicleNumber: permit.vehicleNumber,
        ...(permit.driverName ? { driverName: permit.driverName } : {}),
        ...(permit.driverMobileNumber ? { driverMobileNumber: permit.driverMobileNumber } : {}),
        permit,
        status: 'PERMIT_ISSUED',
        createdAt: now.toISOString(),
        dispatchedAt: now.toISOString(),
      };

      // Deduct from source balance
      balance.transferredQuantity = balance.transferredQuantity
        ? addQuantity(balance.transferredQuantity, input.quantity)
        : input.quantity;
      balance.lastUpdatedAt = now.toISOString();

      db.transfers.unshift(transfer);

      return {
        transfer,
        sourceBalance: balance,
      };
    }),

  markInTransit: (transferId: ID): Promise<MineralTransfer> =>
    request(() => {
      const transfer = db.transfers.find((t) => t.id === transferId);
      if (!transfer) throw new Error('Transfer record not found');
      transfer.status = 'IN_TRANSIT';
      return transfer;
    }),

  completeTransfer: (
    transferId: ID,
    receivedByUserId: ID,
  ): Promise<MineralTransfer> =>
    request(() => {
      const transfer = db.transfers.find((t) => t.id === transferId);
      if (!transfer) throw new Error('Transfer record not found');
      if (transfer.status === 'RECEIVED') return transfer;

      const now = new Date().toISOString();
      transfer.status = 'RECEIVED';
      transfer.receivedAt = now;
      transfer.receivedByUserId = receivedByUserId;

      // If destination is an internal package, credit the destination package inventory
      if (transfer.destination.kind === 'PACKAGE') {
        const destPkgId = transfer.destination.packageId;
        const destOrgId = transfer.destination.organizationId;
        const destProjId = transfer.destination.projectId;

        let destBalance = db.inventoryBalances.find(
          (b) =>
            b.scope.kind === 'PACKAGE' &&
            b.scope.packageId === destPkgId &&
            b.mineralId === transfer.mineralId,
        );

        if (destBalance) {
          destBalance.receivedQuantity = addQuantity(
            destBalance.receivedQuantity,
            transfer.quantity,
          );
          destBalance.lastUpdatedAt = now;
        } else {
          destBalance = {
            id: `inv-${db.inventoryBalances.length + 1}-${Date.now()}`,
            scope: {
              kind: 'PACKAGE',
              organizationId: destOrgId,
              projectId: destProjId,
              packageId: destPkgId,
            },
            mineralId: transfer.mineralId,
            receivedQuantity: transfer.quantity,
            consumedQuantity: { value: 0, unit: transfer.quantity.unit },
            lastUpdatedAt: now,
          };
          db.inventoryBalances.push(destBalance);
        }
      } else if (transfer.destination.kind === 'CONSUMER_SITE') {
        const destUserId = transfer.destination.userId;
        let destBalance = db.inventoryBalances.find(
          (b) =>
            b.scope.kind === 'CONSUMER' &&
            b.scope.userId === destUserId &&
            b.mineralId === transfer.mineralId,
        );

        if (destBalance) {
          destBalance.receivedQuantity = addQuantity(
            destBalance.receivedQuantity,
            transfer.quantity,
          );
          destBalance.lastUpdatedAt = now;
        } else {
          destBalance = {
            id: `inv-${db.inventoryBalances.length + 1}-${Date.now()}`,
            scope: {
              kind: 'CONSUMER',
              userId: destUserId,
            },
            mineralId: transfer.mineralId,
            receivedQuantity: transfer.quantity,
            consumedQuantity: { value: 0, unit: transfer.quantity.unit },
            lastUpdatedAt: now,
          };
          db.inventoryBalances.push(destBalance);
        }
      }

      return transfer;
    }),
};
