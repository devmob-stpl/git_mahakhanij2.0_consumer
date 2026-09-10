import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Info, Truck } from 'lucide-react';
import type {
  InventoryBalance,
  Package,
  Quantity,
  StockPointSearchResult,
  TransferDestination,
  TransferReason,
} from '@/domain';
import {
  canInitiateTransfer,
  formatQuantity,
  subtractQuantity,
} from '@/rules';
import {
  BottomSheet,
  Button,
  Input,
  QuantityInput,
  Select,
  type SelectOption,
} from '@/design-system';

import {
  packageRepository,
  stockPointRepository,
  transferRepository,
} from '@/data';
import { useCurrentUser } from '@/state';
import { useCopy } from '@/content';
import { useDevQuickFill } from '@/prototype';
import { ROUTES } from '@/navigation';

export interface CreateTransferSheetProps {
  open: boolean;
  onClose: () => void;
  balance: InventoryBalance;
  available: Quantity;
  onTransferred: () => void;
}

export function CreateTransferSheet({
  open,
  onClose,
  balance,
  available,
  onTransferred,
}: CreateTransferSheetProps) {
  const user = useCurrentUser();
  const t = useCopy();
  const navigate = useNavigate();

  const isOrg = balance.scope.kind === 'PACKAGE';

  const [destType, setDestType] = useState<
    'PACKAGE' | 'CONSUMER_SITE' | 'STOCKPOINT_RETURN' | 'EXTERNAL_SITE'
  >(isOrg ? 'PACKAGE' : 'STOCKPOINT_RETURN');

  const [quantity, setQuantity] = useState<number | null>(null);
  const [vehicleNumber, setVehicleNumber] = useState('');
  const [driverName, setDriverName] = useState('');
  const [driverPhone, setDriverPhone] = useState('');
  const [reason, setReason] = useState<TransferReason>('SURPLUS_RELOCATION');
  const [remarks, setRemarks] = useState('');

  // Destination specific inputs
  const [packages, setPackages] = useState<Package[]>([]);
  const [selectedPackageId, setSelectedPackageId] = useState('');
  const [stockPoints, setStockPoints] = useState<StockPointSearchResult[]>([]);
  const [selectedStockPointId, setSelectedStockPointId] = useState('');

  const [externalAddress, setExternalAddress] = useState({
    line1: '',
    taluka: 'Nashik',
    district: 'Nashik',
    state: 'Maharashtra',
    pincode: '422001',
  });
  const [externalSiteLabel, setExternalSiteLabel] = useState('');

  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!open) return;

    if (isOrg && balance.scope.kind === 'PACKAGE') {
      const pkgScope = balance.scope;
      packageRepository
        .listByOrganization(pkgScope.organizationId)
        .then((pkgs) => {
          // Exclude the source package
          const otherPackages = pkgs.filter((p) => p.id !== pkgScope.packageId);
          setPackages(otherPackages);
          if (otherPackages.length > 0) {
            setSelectedPackageId(otherPackages[0].id);
          }
        });
    }

    stockPointRepository.search({ availableOnly: false }).then((sps) => {
      setStockPoints(sps);
      if (sps.length > 0) {
        setSelectedStockPointId(sps[0].stockPoint.id);
      }
    });
  }, [open, isOrg, balance]);

  const requested: Quantity = { value: quantity ?? 0, unit: available.unit };
  const check = canInitiateTransfer(balance, requested);
  const remaining = subtractQuantity(available, requested);

  const isVehicleValid = vehicleNumber.trim().length >= 4;
  const canSubmit =
    quantity !== null &&
    quantity > 0 &&
    check.allowed &&
    isVehicleValid;

  function handleQuickFill() {
    const fillQty = Math.max(1, Math.min(50, Math.floor(available.value * 0.4)));
    setQuantity(fillQty);
    setVehicleNumber('MH-12-PQ-8899');
    setDriverName('Ramesh Jadhav');
    setDriverPhone('9822114455');
    setReason('SURPLUS_RELOCATION');
    setRemarks('Surplus mineral relocation to secondary active package site.');
    if (isOrg && packages.length > 0) {
      setDestType('PACKAGE');
      setSelectedPackageId(packages[0].id);
    }
  }

  useDevQuickFill(handleQuickFill);

  async function handleCreateTransfer() {
    if (!user || !canSubmit) return;

    setSubmitting(true);
    try {
      let destination: TransferDestination;

      if (destType === 'PACKAGE') {
        const pkg = packages.find((p) => p.id === selectedPackageId);
        if (!pkg) throw new Error('Please select a destination package');
        destination = {
          kind: 'PACKAGE',
          organizationId: pkg.organizationId,
          projectId: pkg.projectId,
          packageId: pkg.id,
          siteLabel: pkg.name,
          address: pkg.siteAddress,
          geo: pkg.siteGeo,
        };
      } else if (destType === 'STOCKPOINT_RETURN') {
        const spResult = stockPoints.find(
          (sp) => sp.stockPoint.id === selectedStockPointId,
        );
        if (!spResult) throw new Error('Please select a destination mineral place');
        destination = {
          kind: 'STOCKPOINT_RETURN',
          stockPointId: spResult.stockPoint.id,
          stockPointName: spResult.stockPoint.name,
          address: spResult.stockPoint.address,
          geo: spResult.stockPoint.geo,
        };
      } else if (destType === 'CONSUMER_SITE') {
        destination = {
          kind: 'CONSUMER_SITE',
          userId: user.id,
          siteLabel: externalSiteLabel.trim() || 'Secondary Consumer Site',
          address: externalAddress,
        };
      } else {
        destination = {
          kind: 'EXTERNAL_SITE',
          siteLabel: externalSiteLabel.trim() || 'External Disposal Site',
          address: externalAddress,
        };
      }

      const result = await transferRepository.create({
        inventoryBalanceId: balance.id,
        destination,
        quantity: requested,
        reason,
        remarks: remarks.trim() || undefined,
        vehicleNumber: vehicleNumber.trim().toUpperCase(),
        driverName: driverName.trim() || undefined,
        driverMobileNumber: driverPhone.trim() || undefined,
        userId: user.id,
      });

      onTransferred();
      onClose();
      navigate(ROUTES.transferPermit(result.transfer.id));
    } catch (err: any) {
      alert(err?.message ?? 'Failed to generate transfer e-TP');
    } finally {
      setSubmitting(false);
    }
  }

  const packageOptions: SelectOption[] = packages.map((pkg) => ({
    value: pkg.id,
    label: `${pkg.name} (${pkg.code})`,
  }));

  const stockPointOptions: SelectOption[] = stockPoints.map((sp) => ({
    value: sp.stockPoint.id,
    label: `${sp.stockPoint.name} — ${sp.stockPoint.address.district}`,
  }));

  const reasonOptions: SelectOption[] = [
    { value: 'SURPLUS_RELOCATION', label: 'Surplus Mineral Relocation' },
    { value: 'PROJECT_HANDOVER', label: 'Inter-Project Handover' },
    { value: 'STOCKPOINT_RETURN', label: 'Return to Mineral Place' },
    { value: 'EXCAVATION_DISPOSAL', label: 'Excavation Site Disposal' },
  ];

  return (
    <BottomSheet
      open={open}
      onClose={onClose}
      title={t.transfer.sheetTitle}
      description={t.transfer.sheetBody}
      footer={
        <Button
          size="lg"
          fullWidth
          disabled={!canSubmit}
          loading={submitting}
          leftIcon={<Truck size={17} />}
          onClick={handleCreateTransfer}
        >
          {submitting ? t.transfer.submitting : t.transfer.submitAction}
        </Button>
      }
    >
      <div className="space-y-4 px-4 pb-4">
        <div className="flex items-baseline justify-between gap-4 rounded-md bg-surface-sunken px-3 py-2">
          <span className="text-body-sm text-ink-secondary">{t.inventory.available}</span>
          <span className="tabular text-title text-ink">{formatQuantity(available)}</span>
        </div>

        {/* Destination Kind Selector */}
        <div>
          <label className="text-label text-ink-secondary block mb-1.5">
            {t.transfer.destinationType}
          </label>
          <div className="grid grid-cols-2 gap-2">
            {isOrg ? (
              <>
                <button
                  type="button"
                  onClick={() => setDestType('PACKAGE')}
                  className={`rounded-lg border px-3 py-2 text-left text-body-sm font-medium transition ${
                    destType === 'PACKAGE'
                      ? 'border-primary-600 bg-primary-50 text-primary-900'
                      : 'border-line bg-surface text-ink hover:bg-surface-sunken'
                  }`}
                >
                  {t.transfer.destinationPackage}
                </button>
                <button
                  type="button"
                  onClick={() => setDestType('STOCKPOINT_RETURN')}
                  className={`rounded-lg border px-3 py-2 text-left text-body-sm font-medium transition ${
                    destType === 'STOCKPOINT_RETURN'
                      ? 'border-primary-600 bg-primary-50 text-primary-900'
                      : 'border-line bg-surface text-ink hover:bg-surface-sunken'
                  }`}
                >
                  {t.transfer.destinationStockPoint}
                </button>
                <button
                  type="button"
                  onClick={() => setDestType('EXTERNAL_SITE')}
                  className={`col-span-2 rounded-lg border px-3 py-2 text-left text-body-sm font-medium transition ${
                    destType === 'EXTERNAL_SITE'
                      ? 'border-primary-600 bg-primary-50 text-primary-900'
                      : 'border-line bg-surface text-ink hover:bg-surface-sunken'
                  }`}
                >
                  {t.transfer.destinationExternal}
                </button>
              </>
            ) : (
              <>
                <button
                  type="button"
                  onClick={() => setDestType('STOCKPOINT_RETURN')}
                  className={`rounded-lg border px-3 py-2 text-left text-body-sm font-medium transition ${
                    destType === 'STOCKPOINT_RETURN'
                      ? 'border-primary-600 bg-primary-50 text-primary-900'
                      : 'border-line bg-surface text-ink hover:bg-surface-sunken'
                  }`}
                >
                  {t.transfer.destinationStockPoint}
                </button>
                <button
                  type="button"
                  onClick={() => setDestType('CONSUMER_SITE')}
                  className={`rounded-lg border px-3 py-2 text-left text-body-sm font-medium transition ${
                    destType === 'CONSUMER_SITE'
                      ? 'border-primary-600 bg-primary-50 text-primary-900'
                      : 'border-line bg-surface text-ink hover:bg-surface-sunken'
                  }`}
                >
                  {t.transfer.destinationConsumerSite}
                </button>
              </>
            )}
          </div>
        </div>

        {/* Destination Details */}
        {destType === 'PACKAGE' && (
          <Select
            label={t.transfer.selectPackage}
            value={selectedPackageId}
            options={packageOptions}
            onChange={(e) => setSelectedPackageId(e.target.value)}
          />
        )}

        {destType === 'STOCKPOINT_RETURN' && (
          <Select
            label={t.transfer.selectStockPoint}
            value={selectedStockPointId}
            options={stockPointOptions}
            onChange={(e) => setSelectedStockPointId(e.target.value)}
          />
        )}

        {(destType === 'CONSUMER_SITE' || destType === 'EXTERNAL_SITE') && (
          <div className="space-y-3">
            <Input
              label="Destination Site Name"
              placeholder="e.g. Residential Plot #2, Panchavati"
              value={externalSiteLabel}
              onChange={(e) => setExternalSiteLabel(e.target.value)}
            />
            <Input
              label="Address Line"
              placeholder="Street / Land / Plot Address"
              value={externalAddress.line1}
              onChange={(e) =>
                setExternalAddress((prev) => ({ ...prev, line1: e.target.value }))
              }
            />
            <div className="grid grid-cols-2 gap-2">
              <Input
                label="Taluka"
                value={externalAddress.taluka}
                onChange={(e) =>
                  setExternalAddress((prev) => ({ ...prev, taluka: e.target.value }))
                }
              />
              <Input
                label="District"
                value={externalAddress.district}
                onChange={(e) =>
                  setExternalAddress((prev) => ({ ...prev, district: e.target.value }))
                }
              />
            </div>
          </div>
        )}

        {/* Quantity */}
        <QuantityInput
          label={t.transfer.quantityLabel}
          value={quantity}
          unit={available.unit}
          onChange={setQuantity}
          {...(quantity !== null && quantity > 0 && !check.allowed && check.reason
            ? { error: check.reason }
            : {})}
        />

        {quantity !== null && quantity > 0 && check.allowed && (
          <p className="flex items-center gap-2 rounded-md bg-primary-50 px-3 py-2 text-body-sm text-primary-700">
            <Info size={15} className="shrink-0" aria-hidden />
            Remaining on site:{' '}
            <span className="tabular font-medium">{formatQuantity(remaining)}</span>
          </p>
        )}

        {/* Vehicle & Logistics */}
        <div className="space-y-3 pt-2 border-t border-line">
          <Input
            label={t.transfer.vehicleNumberLabel}
            placeholder="e.g. MH 15 AB 1234"
            value={vehicleNumber}
            onChange={(e) => setVehicleNumber(e.target.value.toUpperCase())}
            required
          />

          <div className="grid grid-cols-2 gap-2">
            <Input
              label={t.transfer.driverNameLabel}
              placeholder="Driver Name"
              value={driverName}
              onChange={(e) => setDriverName(e.target.value)}
            />
            <Input
              label={t.transfer.driverPhoneLabel}
              placeholder="Mobile Number"
              type="tel"
              value={driverPhone}
              onChange={(e) => setDriverPhone(e.target.value)}
            />
          </div>

          <Select
            label={t.transfer.reasonLabel}
            value={reason}
            options={reasonOptions}
            onChange={(e) => setReason(e.target.value as TransferReason)}
          />

          <Input
            label={t.transfer.remarksLabel}
            placeholder="Any specific instructions or note"
            value={remarks}
            onChange={(e) => setRemarks(e.target.value)}
          />
        </div>
      </div>
    </BottomSheet>
  );
}
