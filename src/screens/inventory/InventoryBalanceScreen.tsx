import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  CheckCircle2,
  FileCheck,
  QrCode,
  RotateCcw,
  ShieldCheck,
  Truck,
} from 'lucide-react';
import {
  computeAvailableQuantity,
  formatMineralCategory,
  formatQuantity,
  formatQuantityValue,
  formatTransferStatus,
  getTransferDestinationLabel,
} from '@/rules';
import {
  Button,
  ConfirmDialog,
  EmptyState,
  ErrorState,
  ListGroup,
  ListRow,
  LoadingState,
  MetricTile,
  SectionHeader,
  StatusBadge,
  Surface,
} from '@/design-system';
import { Screen, ROUTES } from '@/navigation';
import {
  deliveryRepository,
  inventoryRepository,
  mineralRepository,
  packageRepository,
  transferRepository,
  useAsync,
} from '@/data';
import { useCopy } from '@/content';
import { CreateTransferSheet } from './CreateTransferSheet';

/**
 * MATERIAL SOURCING & COMPLIANCE LEDGER
 *
 * Replaces manual micro-consumption tracking with a robust proof-of-sourcing
 * ledger and 1-tap milestone completion.
 */
export function InventoryBalanceScreen() {
  const { balanceId } = useParams<{ balanceId: string }>();
  const [transferOpen, setTransferOpen] = useState(false);
  const [confirmUtilizeOpen, setConfirmUtilizeOpen] = useState(false);
  const [confirmReactivateOpen, setConfirmReactivateOpen] = useState(false);
  const [actionInProgress, setActionInProgress] = useState(false);

  const t = useCopy();
  const navigate = useNavigate();

  const query = useAsync(async () => {
    if (!balanceId) throw new Error('A balance is required');

    const balance = await inventoryRepository.getById(balanceId);
    if (!balance) throw new Error('Inventory balance not found');

    const [minerals, transfers, allDeliveries, activePackage] = await Promise.all([
      mineralRepository.listAll(),
      transferRepository.listByBalanceId(balance.id),
      deliveryRepository.list(),
      balance.scope.kind === 'PACKAGE'
        ? packageRepository.getById(balance.scope.packageId)
        : Promise.resolve(null),
    ]);

    const mineral = minerals.find((candidate) => candidate.id === balance.mineralId);

    // Filter deliveries that delivered this mineral to this scope
    const sourcingDeliveries = allDeliveries.filter((d) => {
      const matchMineral = d.permit.mineralId === balance.mineralId;
      if (balance.scope.kind === 'PACKAGE') {
        return matchMineral && d.packageId === balance.scope.packageId;
      } else {
        return matchMineral;
      }
    });

    return { balance, mineral, transfers, sourcingDeliveries, activePackage };
  }, [balanceId]);

  const balance = query.data?.balance;
  const mineral = query.data?.mineral;
  const available = balance ? computeAvailableQuantity(balance) : null;
  const isUtilized = balance?.status === 'FULLY_UTILIZED' || (available !== null && available.value <= 0);

  async function handleMarkUtilized() {
    if (!balance) return;
    setActionInProgress(true);
    try {
      await inventoryRepository.markAsUtilized(balance.id);
      setConfirmUtilizeOpen(false);
      await query.reload();
    } finally {
      setActionInProgress(false);
    }
  }

  async function handleReactivate() {
    if (!balance) return;
    setActionInProgress(true);
    try {
      await inventoryRepository.reactivateStock(balance.id);
      setConfirmReactivateOpen(false);
      await query.reload();
    } finally {
      setActionInProgress(false);
    }
  }

  return (
    <Screen
      title={mineral?.name ?? t.inventory.balanceTitle}
      {...(query.data?.activePackage ? { subtitle: query.data.activePackage.name } : {})}
      onBack
      footer={
        balance && available && !isUtilized ? (
          <div className="flex gap-2">
            <Button
              size="lg"
              variant="secondary"
              className="flex-1"
              leftIcon={<Truck size={16} />}
              onClick={() => setTransferOpen(true)}
            >
              {t.inventory.transferStock}
            </Button>
            <Button
              size="lg"
              className="flex-1 bg-emerald-700 hover:bg-emerald-800"
              leftIcon={<CheckCircle2 size={16} />}
              onClick={() => setConfirmUtilizeOpen(true)}
            >
              {t.inventory.markAsUtilized}
            </Button>
          </div>
        ) : isUtilized ? (
          <Button
            size="lg"
            variant="secondary"
            fullWidth
            leftIcon={<RotateCcw size={16} />}
            onClick={() => setConfirmReactivateOpen(true)}
          >
            {t.inventory.reactivateStock}
          </Button>
        ) : undefined
      }
    >
      {query.loading && <LoadingState variant="list" rows={4} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {query.data && balance && available && mineral && (
        <div className="pb-8 space-y-4">
          {/* Main Ledger Metric Card */}
          <Surface className="border-b border-line p-4">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold tracking-wide uppercase text-primary-700">
                {formatMineralCategory(mineral.category)}
              </span>
              <StatusBadge
                tone={isUtilized ? 'neutral' : 'success'}
                label={isUtilized ? t.inventory.statusUtilized : t.inventory.statusActive}
                dot
              />
            </div>

            <p className="text-label text-ink-secondary mt-3">{t.inventory.available}</p>
            <p className="tabular mt-0.5 text-display text-ink">
              {formatQuantityValue(available)}{' '}
              <span className="text-title text-ink-muted">{available.unit}</span>
            </p>

            {isUtilized && (
              <p className="mt-1.5 text-body-sm text-ink-muted flex items-center gap-1.5">
                <CheckCircle2 size={15} className="text-emerald-600" />
                {t.inventory.fullyConsumed}
              </p>
            )}

            <div className="mt-4 grid grid-cols-3 gap-2 border-t border-line pt-4">
              <MetricTile
                label={t.inventory.received}
                value={formatQuantityValue(balance.receivedQuantity)}
                unit={balance.receivedQuantity.unit}
              />
              <MetricTile
                label={t.inventory.consumed}
                value={formatQuantityValue(balance.consumedQuantity)}
                unit={balance.consumedQuantity.unit}
              />
              <MetricTile
                label={t.inventory.transferred}
                value={formatQuantityValue(
                  balance.transferredQuantity ?? { value: 0, unit: balance.receivedQuantity.unit },
                )}
                unit={balance.receivedQuantity.unit}
              />
            </div>
          </Surface>

          {/* Legal Sourcing Passes (e-TP) Section */}
          <div>
            <SectionHeader title={t.inventory.sourcingPassesTitle} />

            {query.data.sourcingDeliveries.length === 0 ? (
              <Surface className="border-y border-line">
                <EmptyState
                  className="py-6"
                  icon={<FileCheck size={22} />}
                  title="Sourced under Initial Package Stock"
                  description="Initial verified allocation recorded under Mahakhanij quota."
                />
              </Surface>
            ) : (
              <ListGroup className="border-y border-line">
                {query.data.sourcingDeliveries.map((delivery) => (
                  <ListRow
                    key={delivery.id}
                    leading={<ShieldCheck size={17} className="text-emerald-600" />}
                    leadingTone="neutral"
                    title={delivery.permit.etpNumber}
                    subtitle={`From: ${delivery.permit.sourceQuarryName} (${delivery.vehicle.registrationNumber})`}
                    detail={formatQuantity(delivery.dispatchedQuantity)}
                    trailing={<StatusBadge tone="success" label="Verified e-TP" />}
                    onClick={() => navigate(ROUTES.deliveryTracking(delivery.id))}
                  />
                ))}
              </ListGroup>
            )}
          </div>

          {/* Surplus Transfers / Transit Passes */}
          <div>
            <SectionHeader
              title={t.inventory.transferHistory}
              action={
                query.data.transfers.length > 0 ? (
                  <button
                    type="button"
                    onClick={() => navigate(ROUTES.transfers)}
                    className="text-label font-medium text-primary-600 hover:text-primary-700"
                  >
                    View all
                  </button>
                ) : undefined
              }
            />

            {query.data.transfers.length === 0 ? (
              <Surface className="border-y border-line">
                <EmptyState
                  className="py-6"
                  icon={<Truck size={20} />}
                  title="No Surplus Transferred"
                  description="All sourced mineral remains assigned to this site."
                />
              </Surface>
            ) : (
              <ListGroup className="border-y border-line">
                {query.data.transfers.map((transfer) => {
                  const statusInfo = formatTransferStatus(transfer.status);
                  const destLabel = getTransferDestinationLabel(transfer.destination);

                  return (
                    <ListRow
                      key={transfer.id}
                      leading={<QrCode size={17} />}
                      leadingTone="neutral"
                      title={transfer.permit.etpNumber}
                      subtitle={`To: ${destLabel} (${transfer.vehicleNumber})`}
                      detail={formatQuantity(transfer.quantity)}
                      trailing={<StatusBadge tone={statusInfo.tone} label={statusInfo.label} />}
                      onClick={() => navigate(ROUTES.transferPermit(transfer.id))}
                    />
                  );
                })}
              </ListGroup>
            )}
          </div>
        </div>
      )}

      {/* 1-Tap Milestone Completion Dialog */}
      <ConfirmDialog
        open={confirmUtilizeOpen}
        onCancel={() => setConfirmUtilizeOpen(false)}
        title="Mark Material as Fully Utilized?"
        description="This records that all remaining stock of this mineral has been successfully utilized in construction. No further daily logs are needed."
        confirmLabel={actionInProgress ? 'Updating…' : 'Mark as Utilized'}
        cancelLabel="Cancel"
        onConfirm={handleMarkUtilized}
      />

      {/* Reactivate Stock Dialog */}
      <ConfirmDialog
        open={confirmReactivateOpen}
        onCancel={() => setConfirmReactivateOpen(false)}
        title="Reactivate Mineral Stock?"
        description="This marks the mineral as active on site again if additional construction work is ongoing."
        confirmLabel={actionInProgress ? 'Reactivating…' : 'Reactivate'}
        cancelLabel="Cancel"
        onConfirm={handleReactivate}
      />

      {/* Transfer Surplus Bottom Sheet */}
      {balance && available && (
        <CreateTransferSheet
          open={transferOpen}
          onClose={() => setTransferOpen(false)}
          balance={balance}
          available={available}
          onTransferred={query.reload}
        />
      )}
    </Screen>
  );
}
