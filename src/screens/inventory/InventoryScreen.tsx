import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Layers, ShieldCheck, Truck, Warehouse } from 'lucide-react';
import type { ID, InventoryBalance, Mineral, MineralCategory } from '@/domain';
import {
  computeAvailableQuantity,
  formatMineralCategory,
  formatQuantity,
  usesOrganizationContext,
} from '@/rules';
import {
  Chip,
  EmptyState,
  ErrorState,
  LoadingState,
  StatusBadge,
  Surface,
} from '@/design-system';

import { OrganizationContextBar, ROUTES, Screen } from '@/navigation';
import { inventoryRepository, mineralRepository, packageRepository, useAsync } from '@/data';
import { useCurrentUser, useOperatingContext } from '@/state';
import { useCopy } from '@/content';

export function InventoryScreen() {
  const user = useCurrentUser();
  const context = useOperatingContext();
  const navigate = useNavigate();
  const t = useCopy();

  const isOrganization = user ? usesOrganizationContext(user.userType) : false;
  const hasPackage = Boolean(context?.packageId);
  const [scopeToPackage, setScopeToPackage] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<MineralCategory | 'ALL'>('ALL');
  const packageScoped = isOrganization && hasPackage && scopeToPackage;

  const query = useAsync(async () => {
    if (!user) throw new Error('A session is required');

    const balances = isOrganization
      ? await inventoryRepository.list(
          packageScoped
            ? { packageId: context?.packageId as ID }
            : { ...(context?.organizationId ? { organizationId: context.organizationId } : {}) },
        )
      : await inventoryRepository.list({ userId: user.id });

    const [minerals, packages] = await Promise.all([
      mineralRepository.listAll(),
      isOrganization && context?.organizationId
        ? packageRepository.listByOrganization(context.organizationId)
        : Promise.resolve([]),
    ]);

    return { balances, minerals, packages };
  }, [user?.id, context?.organizationId, context?.packageId, packageScoped]);

  const rawBalances = query.data?.balances ?? [];
  const minerals = query.data?.minerals ?? [];

  const getMineral = (id: ID): Mineral | undefined =>
    minerals.find((m) => m.id === id);

  const balances = rawBalances.filter((b) => {
    if (selectedCategory === 'ALL') return true;
    const mineral = getMineral(b.mineralId);
    return mineral?.category === selectedCategory;
  });

  const availableCategories: MineralCategory[] = Array.from(
    new Set(
      rawBalances
        .map((b) => getMineral(b.mineralId)?.category)
        .filter((cat): cat is MineralCategory => Boolean(cat)),
    ),
  );

  const packageName = (balance: InventoryBalance) => {
    const scope = balance.scope;
    if (scope.kind !== 'PACKAGE') return undefined;
    return query.data?.packages.find((pkg) => pkg.id === scope.packageId)?.name;
  };

  return (
    <Screen
      title={t.inventory.title}
      onBack
      context={packageScoped ? <OrganizationContextBar showChange={false} /> : undefined}
    >
      {query.loading && <LoadingState variant="list" rows={4} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {query.data && (
        <div className="pb-8">
          {/* Scope switcher — only where an organization hierarchy exists. */}
          {isOrganization && hasPackage && (
            <div className="no-scrollbar flex gap-2 overflow-x-auto border-b border-line bg-surface px-4 py-3">
              <Chip
                label={t.inventory.thisPackage}
                active={scopeToPackage}
                onClick={() => setScopeToPackage(true)}
              />
              <Chip
                label={t.inventory.allPackages}
                active={!scopeToPackage}
                onClick={() => setScopeToPackage(false)}
              />
            </div>
          )}

          {/* Sourcing Compliance Header Banner */}
          <div className="border-b border-line bg-surface-sunken p-4">
            <div className="flex items-center gap-2.5 text-xs text-ink-secondary">
              <ShieldCheck size={16} className="text-emerald-600 shrink-0" />
              <span>
                Verified 100% legal sourcing under Maharashtra minor mineral regulations (e-TP).
              </span>
            </div>
          </div>

          {/* Category Filter Chips */}
          {availableCategories.length > 1 && (
            <div className="no-scrollbar flex gap-2 overflow-x-auto border-b border-line bg-surface px-4 py-2.5">
              <Chip
                label={t.inventory.allCategories}
                active={selectedCategory === 'ALL'}
                onClick={() => setSelectedCategory('ALL')}
              />
              {availableCategories.map((cat) => (
                <Chip
                  key={cat}
                  label={formatMineralCategory(cat)}
                  active={selectedCategory === cat}
                  onClick={() => setSelectedCategory(cat)}
                />
              ))}
            </div>
          )}

          {rawBalances.length === 0 ? (
            <EmptyState
              icon={<Warehouse size={24} />}
              title={packageScoped ? t.inventory.noStockInScope : t.inventory.noStock}
              description={
                packageScoped ? t.inventory.noStockInScopeBody : t.inventory.noStockBody
              }
            />
          ) : balances.length === 0 ? (
            <EmptyState
              icon={<Layers size={22} />}
              title="No minerals in this category"
              description="Choose a different mineral category or view all minerals."
            />
          ) : (
            <div className="space-y-3 p-4">
              {balances.map((balance) => {
                const mineral = getMineral(balance.mineralId);
                const available = computeAvailableQuantity(balance);
                const isUtilized = balance.status === 'FULLY_UTILIZED' || available.value <= 0;
                const pkg = packageName(balance);

                return (
                  <Surface
                    key={balance.id}
                    onClick={() => navigate(ROUTES.inventoryBalance(balance.id))}
                    className="cursor-pointer rounded-xl border border-line p-4 transition hover:border-primary-300 hover:shadow-sm"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        {mineral && (
                          <span className="text-[11px] font-semibold tracking-wide uppercase text-primary-700">
                            {formatMineralCategory(mineral.category)}
                          </span>
                        )}
                        <h3 className="text-body font-bold text-ink">
                          {mineral?.name ?? 'Mineral'}
                        </h3>
                        {pkg && <p className="text-caption text-ink-muted">{pkg}</p>}
                      </div>

                      <StatusBadge
                        tone={isUtilized ? 'neutral' : 'success'}
                        label={isUtilized ? t.inventory.statusUtilized : t.inventory.statusActive}
                        dot
                      />
                    </div>

                    <div className="mt-3 grid grid-cols-2 gap-2 rounded-lg bg-surface-sunken p-3">
                      <div>
                        <p className="text-[11px] text-ink-secondary">{t.inventory.received}</p>
                        <p className="tabular font-semibold text-ink">
                          {formatQuantity(balance.receivedQuantity)}
                        </p>
                      </div>
                      <div>
                        <p className="text-[11px] text-ink-secondary">{t.inventory.available}</p>
                        <p
                          className={`tabular font-bold ${
                            isUtilized ? 'text-ink-muted' : 'text-primary-700'
                          }`}
                        >
                          {formatQuantity(available)}
                        </p>
                      </div>
                    </div>

                    {balance.transferredQuantity && balance.transferredQuantity.value > 0 && (
                      <div className="mt-2 flex items-center gap-1.5 text-[11px] text-amber-800">
                        <Truck size={13} className="shrink-0" />
                        <span>
                          {formatQuantity(balance.transferredQuantity)} relocated to other sites
                        </span>
                      </div>
                    )}

                    <div className="mt-3 flex items-center justify-between border-t border-line pt-2 text-[11px] text-ink-muted">
                      <span>e-TP Verified Stock</span>
                      <span className="flex items-center gap-1 font-medium text-primary-600">
                        View Sourcing Ledger <ArrowRight size={12} />
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
