import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Truck } from 'lucide-react';
import {
  formatDateTime,
  formatQuantity,
  formatTransferStatus,
  getTransferDestinationLabel,
} from '@/rules';
import {
  EmptyState,
  ErrorState,
  LoadingState,
  StatusBadge,
  Surface,
} from '@/design-system';
import { Screen, ROUTES } from '@/navigation';
import { mineralRepository, transferRepository, useAsync } from '@/data';
import { useCopy } from '@/content';

export function TransfersListScreen() {
  const t = useCopy();
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState<'ALL' | 'ACTIVE' | 'COMPLETED'>('ALL');

  const query = useAsync(async () => {
    const [allTransfers, minerals] = await Promise.all([
      transferRepository.listAll(),
      mineralRepository.listAll(),
    ]);

    return { allTransfers, minerals };
  }, []);

  const transfers = (query.data?.allTransfers ?? []).filter((transfer) => {
    if (activeTab === 'ACTIVE') {
      return transfer.status === 'PERMIT_ISSUED' || transfer.status === 'IN_TRANSIT';
    }
    if (activeTab === 'COMPLETED') {
      return transfer.status === 'RECEIVED';
    }
    return true;
  });

  const getMineralName = (mineralId: string) => {
    return query.data?.minerals.find((m) => m.id === mineralId)?.name ?? 'Mineral';
  };

  return (
    <Screen title={t.transfer.allTransfersTitle} onBack>
      {/* Filter Tabs */}
      <div className="flex border-b border-line bg-surface px-4 pt-2">
        <button
          type="button"
          onClick={() => setActiveTab('ALL')}
          className={`border-b-2 px-3 py-2 text-label font-medium transition ${
            activeTab === 'ALL'
              ? 'border-primary-600 text-primary-900'
              : 'border-transparent text-ink-secondary hover:text-ink'
          }`}
        >
          All
        </button>
        <button
          type="button"
          onClick={() => setActiveTab('ACTIVE')}
          className={`border-b-2 px-3 py-2 text-label font-medium transition ${
            activeTab === 'ACTIVE'
              ? 'border-primary-600 text-primary-900'
              : 'border-transparent text-ink-secondary hover:text-ink'
          }`}
        >
          Active e-TPs
        </button>
        <button
          type="button"
          onClick={() => setActiveTab('COMPLETED')}
          className={`border-b-2 px-3 py-2 text-label font-medium transition ${
            activeTab === 'COMPLETED'
              ? 'border-primary-600 text-primary-900'
              : 'border-transparent text-ink-secondary hover:text-ink'
          }`}
        >
          Completed
        </button>
      </div>

      {query.loading && <LoadingState variant="list" rows={4} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {query.data && (
        <div className="pb-8">
          {transfers.length === 0 ? (
            <Surface className="m-4 rounded-xl border border-line p-6">
              <EmptyState
                icon={<Truck size={24} />}
                title={t.transfer.noTransfers}
                description={t.transfer.noTransfersBody}
              />
            </Surface>
          ) : (
            <div className="space-y-3 p-4">
              {transfers.map((transfer) => {
                const statusInfo = formatTransferStatus(transfer.status);
                const destLabel = getTransferDestinationLabel(transfer.destination);

                return (
                  <Surface
                    key={transfer.id}
                    onClick={() => navigate(ROUTES.transferPermit(transfer.id))}
                    className="p-4 rounded-xl border border-line cursor-pointer transition hover:border-primary-300 hover:shadow-sm"
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-mono text-xs font-semibold text-primary-700">
                        {transfer.permit.etpNumber}
                      </span>
                      <StatusBadge tone={statusInfo.tone} label={statusInfo.label} />
                    </div>

                    <div className="mt-2 flex items-baseline justify-between">
                      <p className="text-body font-bold text-ink">
                        {getMineralName(transfer.mineralId)}
                      </p>
                      <p className="tabular text-body font-bold text-ink">
                        {formatQuantity(transfer.quantity)}
                      </p>
                    </div>

                    <div className="mt-2 text-caption text-ink-secondary">
                      <p className="truncate">
                        <strong>To:</strong> {destLabel}
                      </p>
                      <p className="mt-0.5 font-mono text-[11px] text-ink-muted">
                        Vehicle: {transfer.vehicleNumber}
                      </p>
                    </div>

                    <div className="mt-3 flex items-center justify-between border-t border-line pt-2 text-[11px] text-ink-muted">
                      <span>{formatDateTime(transfer.createdAt)}</span>
                      <span className="flex items-center gap-1 font-medium text-primary-600">
                        View e-TP <ArrowRight size={12} />
                      </span>
                    </div>
                  </Surface>
                );
              })}
            </div>
          )}
        </div>
      )}
    </Screen>
  );
}
