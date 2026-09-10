import { useState } from 'react';
import { useParams } from 'react-router-dom';
import {
  CheckCircle2,
  Clock,
  FileText,
  MapPin,
  MessageCircle,
  QrCode,
  Send,
  ShieldCheck,
  Truck,
} from 'lucide-react';
import {
  formatDateTime,
  formatQuantity,
  formatTransferReason,
  formatTransferStatus,
  getTransferDestinationLabel,
} from '@/rules';
import {
  BottomSheet,
  Button,
  ErrorState,
  LoadingState,
  StatusBadge,
  Surface,
} from '@/design-system';
import { Screen } from '@/navigation';
import { mineralRepository, transferRepository, useAsync } from '@/data';
import { useCopy } from '@/content';

export function TransferPermitScreen() {
  const { transferId } = useParams<{ transferId: string }>();
  const t = useCopy();

  const [driverPassModalOpen, setDriverPassModalOpen] = useState(false);
  const [actionInProgress, setActionInProgress] = useState(false);
  const [shareSuccessToast, setShareSuccessToast] = useState<string | null>(null);

  const query = useAsync(async () => {
    if (!transferId) throw new Error('Transfer ID is required');

    const transfer = await transferRepository.getById(transferId);
    if (!transfer) throw new Error('Transfer record not found');

    const minerals = await mineralRepository.listAll();
    const mineral = minerals.find((m) => m.id === transfer.mineralId);

    return { transfer, mineral };
  }, [transferId]);

  const transfer = query.data?.transfer;
  const mineral = query.data?.mineral;

  async function handleConfirmDispatch() {
    if (!transfer) return;
    setActionInProgress(true);
    try {
      await transferRepository.markInTransit(transfer.id);
      await query.reload();
    } finally {
      setActionInProgress(false);
    }
  }

  function handleShareWhatsApp() {
    if (!transfer || !mineral) return;
    const destLabel = getTransferDestinationLabel(transfer.destination);
    const text = `*MAHAKHANIJ TRANSIT PASS (e-TP)*\nPass No: ${transfer.permit.etpNumber}\nVehicle: ${transfer.vehicleNumber}\nMineral: ${mineral.name} (${transfer.quantity.value} ${transfer.quantity.unit})\nOrigin: ${transfer.sourceLabel}\nDestination: ${destLabel}\nValid Until: ${formatDateTime(transfer.permit.validUntil)}\n\n_Show this message or digital QR pass at checkpoints._`;

    const phone = transfer.driverMobileNumber ? `91${transfer.driverMobileNumber.replace(/\D/g, '')}` : '';
    const whatsappUrl = phone
      ? `https://wa.me/${phone}?text=${encodeURIComponent(text)}`
      : `https://wa.me/?text=${encodeURIComponent(text)}`;

    window.open(whatsappUrl, '_blank');
    setShareSuccessToast('Pass link shared to driver via WhatsApp!');
    setTimeout(() => setShareSuccessToast(null), 4000);
  }

  function handleSendSms() {
    if (!transfer || !mineral) return;
    const destLabel = getTransferDestinationLabel(transfer.destination);
    const text = `Mahakhanij e-TP: ${transfer.permit.etpNumber} | Veh: ${transfer.vehicleNumber} | ${transfer.quantity.value} ${transfer.quantity.unit} ${mineral.name} to ${destLabel}. Valid till ${formatDateTime(transfer.permit.validUntil)}`;

    const phone = transfer.driverMobileNumber || '';
    window.open(`sms:${phone}?body=${encodeURIComponent(text)}`, '_self');
    setShareSuccessToast('Pass details sent via SMS!');
    setTimeout(() => setShareSuccessToast(null), 4000);
  }

  const statusInfo = transfer ? formatTransferStatus(transfer.status) : null;
  const destLabel = transfer ? getTransferDestinationLabel(transfer.destination) : '';

  return (
    <Screen
      title={t.transfer.screenTitle}
      subtitle={transfer ? transfer.permit.etpNumber : undefined}
      onBack
    >
      {query.loading && <LoadingState variant="screen" />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {transfer && mineral && statusInfo && (
        <div className="space-y-4 p-4 pb-12">
          {/* Toast Notification */}
          {shareSuccessToast && (
            <div className="flex items-center gap-2 rounded-lg bg-primary-900 px-3.5 py-2.5 text-xs text-white shadow-lg animate-in fade-in slide-in-from-top-2 duration-200">
              <CheckCircle2 size={16} className="text-emerald-400 shrink-0" />
              <span>{shareSuccessToast}</span>
            </div>
          )}

          {/* Transfer Summary Card */}
          <Surface className="rounded-xl border border-line p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-[11px] font-medium text-ink-secondary">e-TP Transit Pass</p>
                <p className="font-mono text-base font-bold text-primary-700">
                  {transfer.permit.etpNumber}
                </p>
              </div>
              <StatusBadge tone={statusInfo.tone} label={statusInfo.label} />
            </div>

            <div className="mt-3 grid grid-cols-2 gap-2 border-t border-line pt-3 text-xs">
              <div>
                <span className="text-ink-secondary">Transfer Ref: </span>
                <span className="font-mono font-medium text-ink">{transfer.transferNumber}</span>
              </div>
              <div className="text-right">
                <span className="text-ink-secondary">Issued: </span>
                <span className="text-ink">{formatDateTime(transfer.createdAt)}</span>
              </div>
            </div>
          </Surface>

          {/* Stage Status Callout */}
          {transfer.status === 'PERMIT_ISSUED' && (
            <div className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-amber-900 shadow-sm">
              <div className="flex items-start gap-3">
                <Truck size={20} className="text-amber-700 shrink-0 mt-0.5" />
                <div>
                  <p className="text-body-sm font-bold text-amber-950">
                    Ready for Driver Handover & Departure
                  </p>
                  <p className="mt-0.5 text-caption text-amber-800">
                    Share the transit pass with the driver. Once the truck is loaded and leaves the gate, confirm departure below.
                  </p>
                </div>
              </div>

              <div className="mt-3.5">
                <Button
                  size="md"
                  fullWidth
                  loading={actionInProgress}
                  leftIcon={<Truck size={16} />}
                  onClick={handleConfirmDispatch}
                >
                  {t.transfer.confirmDispatch}
                </Button>
              </div>
            </div>
          )}

          {transfer.status === 'IN_TRANSIT' && (
            <div className="rounded-xl border border-primary-200 bg-primary-50 p-4 text-primary-900 shadow-sm">
              <div className="flex items-start gap-3">
                <Clock size={20} className="text-primary-700 shrink-0 mt-0.5" />
                <div>
                  <p className="text-body-sm font-bold text-primary-950">
                    Vehicle In Transit with Driver
                  </p>
                  <p className="mt-0.5 text-caption text-primary-800">
                    {transfer.vehicleNumber} is en route to {destLabel}. The destination site will verify and offload the mineral on arrival.
                  </p>
                </div>
              </div>
            </div>
          )}

          {transfer.status === 'RECEIVED' && (
            <div className="rounded-xl border border-emerald-200 bg-emerald-50 p-4 text-emerald-900 shadow-sm">
              <div className="flex items-start gap-3">
                <CheckCircle2 size={20} className="text-emerald-600 shrink-0 mt-0.5" />
                <div>
                  <p className="text-body-sm font-bold text-emerald-950">
                    Received & Verified at Destination
                  </p>
                  <p className="mt-0.5 text-caption text-emerald-800">
                    Offloaded at {destLabel}. Destination inventory has been credited by{' '}
                    <strong>{formatQuantity(transfer.quantity)}</strong>.
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Driver Handover & Gate Pass Card */}
          <Surface className="rounded-xl border border-line p-4 space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Truck size={17} className="text-primary-700" />
                <h3 className="text-body-sm font-bold text-ink">
                  {t.transfer.driverHandoverTitle}
                </h3>
              </div>
              <span className="font-mono text-xs font-bold text-ink bg-surface-sunken px-2 py-0.5 rounded">
                {transfer.vehicleNumber}
              </span>
            </div>

            <div className="rounded-lg bg-surface-sunken p-3 text-xs space-y-1">
              <div className="flex justify-between">
                <span className="text-ink-secondary">Driver Name:</span>
                <span className="font-medium text-ink">
                  {transfer.driverName ?? 'Assigned Transporter Driver'}
                </span>
              </div>
              {transfer.driverMobileNumber && (
                <div className="flex justify-between">
                  <span className="text-ink-secondary">Contact Number:</span>
                  <span className="font-mono text-ink">{transfer.driverMobileNumber}</span>
                </div>
              )}
            </div>

            {/* Handover Actions for Sender */}
            <div className="grid grid-cols-2 gap-2 pt-1">
              <Button
                variant="secondary"
                size="sm"
                className="flex-1 text-emerald-700 border-emerald-200 bg-emerald-50 hover:bg-emerald-100"
                leftIcon={<MessageCircle size={15} />}
                onClick={handleShareWhatsApp}
              >
                WhatsApp
              </Button>
              <Button
                variant="secondary"
                size="sm"
                className="flex-1"
                leftIcon={<Send size={15} />}
                onClick={handleSendSms}
              >
                SMS Pass
              </Button>
            </div>

            <Button
              variant="subtle"
              size="sm"
              fullWidth
              className="mt-1"
              leftIcon={<FileText size={15} />}
              onClick={() => setDriverPassModalOpen(true)}
            >
              {t.transfer.viewDriverPass}
            </Button>
          </Surface>

          {/* Operational Movement Timeline */}
          <Surface className="rounded-xl border border-line p-4">
            <h3 className="text-body-sm font-bold text-ink mb-3">{t.transfer.timelineTitle}</h3>

            <div className="space-y-4 pl-1">
              {/* Step 1: Permit Issued */}
              <div className="flex items-start gap-3 relative">
                <div className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-emerald-700">
                  <CheckCircle2 size={14} />
                </div>
                <div>
                  <p className="text-body-sm font-semibold text-ink">
                    {t.transfer.timelinePermitIssued}
                  </p>
                  <p className="text-caption text-ink-muted">
                    Generated at {transfer.sourceLabel} • {formatDateTime(transfer.createdAt)}
                  </p>
                </div>
              </div>

              {/* Step 2: Dispatched */}
              <div className="flex items-start gap-3 relative">
                <div
                  className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full ${
                    transfer.status !== 'PERMIT_ISSUED'
                      ? 'bg-emerald-100 text-emerald-700'
                      : 'bg-neutral-100 text-ink-muted'
                  }`}
                >
                  {transfer.status !== 'PERMIT_ISSUED' ? (
                    <CheckCircle2 size={14} />
                  ) : (
                    <Clock size={13} />
                  )}
                </div>
                <div>
                  <p
                    className={`text-body-sm font-semibold ${
                      transfer.status !== 'PERMIT_ISSUED' ? 'text-ink' : 'text-ink-secondary'
                    }`}
                  >
                    {t.transfer.timelineDispatched}
                  </p>
                  <p className="text-caption text-ink-muted">
                    {transfer.dispatchedAt
                      ? `Vehicle ${transfer.vehicleNumber} departed at ${formatDateTime(transfer.dispatchedAt)}`
                      : 'Pending vehicle departure confirmation'}
                  </p>
                </div>
              </div>

              {/* Step 3: Destination Receiving */}
              <div className="flex items-start gap-3 relative">
                <div
                  className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-full ${
                    transfer.status === 'RECEIVED'
                      ? 'bg-emerald-100 text-emerald-700'
                      : 'bg-neutral-100 text-ink-muted'
                  }`}
                >
                  {transfer.status === 'RECEIVED' ? (
                    <CheckCircle2 size={14} />
                  ) : (
                    <MapPin size={13} />
                  )}
                </div>
                <div>
                  <p
                    className={`text-body-sm font-semibold ${
                      transfer.status === 'RECEIVED' ? 'text-ink' : 'text-ink-secondary'
                    }`}
                  >
                    {t.transfer.timelineReceiving}
                  </p>
                  <p className="text-caption text-ink-muted">
                    {transfer.status === 'RECEIVED'
                      ? `Received and verified at ${destLabel}`
                      : `${destLabel} will scan driver's QR code upon arrival.`}
                  </p>
                </div>
              </div>
            </div>
          </Surface>

          {/* Cargo & Route Overview */}
          <Surface className="rounded-xl border border-line p-4 space-y-3">
            <div className="flex items-baseline justify-between">
              <div>
                <p className="text-[11px] text-ink-secondary">Transferred Mineral</p>
                <p className="text-title font-bold text-ink">{mineral.name}</p>
              </div>
              <p className="tabular text-title font-bold text-primary-700">
                {formatQuantity(transfer.quantity)}
              </p>
            </div>

            <div className="border-t border-line pt-2 text-caption text-ink-muted space-y-1">
              <p>
                <strong>Reason:</strong> {formatTransferReason(transfer.reason)}
              </p>
              {transfer.remarks && (
                <p>
                  <strong>Remarks:</strong> {transfer.remarks}
                </p>
              )}
            </div>

            <div className="rounded-lg bg-surface-sunken p-3 text-xs space-y-2">
              <div className="flex items-start gap-2">
                <MapPin size={14} className="text-primary-700 shrink-0 mt-0.5" />
                <div>
                  <span className="text-ink-secondary">From: </span>
                  <span className="font-medium text-ink">{transfer.sourceLabel}</span>
                </div>
              </div>
              <div className="flex items-start gap-2">
                <MapPin size={14} className="text-emerald-700 shrink-0 mt-0.5" />
                <div>
                  <span className="text-ink-secondary">To: </span>
                  <span className="font-medium text-ink">{destLabel}</span>
                </div>
              </div>
            </div>
          </Surface>
        </div>
      )}

      {/* Official Driver Gate Pass Modal */}
      {transfer && mineral && (
        <BottomSheet
          open={driverPassModalOpen}
          onClose={() => setDriverPassModalOpen(false)}
          title="Driver Digital Gate Pass"
          description="The driver presents this official e-TP with QR code at highway checkpoints and destination receiving."
        >
          <div className="space-y-4 px-4 pb-6">
            {/* Pass Card */}
            <div className="rounded-xl border border-primary-200 bg-gradient-to-br from-primary-900 to-primary-950 p-4 text-white">
              <div className="flex items-center justify-between border-b border-primary-800 pb-2.5">
                <div className="flex items-center gap-2">
                  <ShieldCheck size={18} className="text-accent-400" />
                  <div>
                    <p className="text-[10px] font-bold tracking-wider uppercase text-primary-200">
                      Govt of Maharashtra
                    </p>
                    <p className="text-xs font-semibold">Transfer e-Transit Pass</p>
                  </div>
                </div>
                <span className="font-mono text-xs bg-primary-800 px-2 py-0.5 rounded text-white font-bold">
                  {transfer.vehicleNumber}
                </span>
              </div>

              <div className="mt-3 flex items-baseline justify-between text-xs">
                <div>
                  <p className="text-[10px] text-primary-300">Permit Number</p>
                  <p className="font-mono font-bold text-sm text-white">
                    {transfer.permit.etpNumber}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-[10px] text-primary-300">Quantity</p>
                  <p className="font-bold text-sm text-white">
                    {formatQuantity(transfer.quantity)}
                  </p>
                </div>
              </div>
            </div>

            {/* QR Code */}
            <div className="flex flex-col items-center justify-center p-4 text-center rounded-xl bg-surface-sunken border border-line">
              <div className="relative flex h-40 w-40 items-center justify-center rounded-xl border-2 border-dashed border-primary-300 bg-white p-2.5 shadow-sm">
                <div className="grid h-full w-full grid-cols-6 grid-rows-6 gap-1.5 rounded bg-white p-1">
                  <div className="col-span-2 row-span-2 rounded bg-ink" />
                  <div className="col-span-2 bg-ink" />
                  <div className="col-span-2 row-span-2 rounded bg-ink" />
                  <div className="bg-ink" />
                  <div className="bg-ink" />
                  <div className="col-span-2 bg-ink" />
                  <div className="col-span-2 row-span-2 rounded bg-ink" />
                  <div className="bg-ink" />
                  <div className="col-span-2 bg-ink" />
                  <div className="col-span-2 row-span-2 rounded bg-ink" />
                </div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="rounded-full bg-primary-600 p-2 text-white shadow">
                    <QrCode size={20} />
                  </div>
                </div>
              </div>

              <p className="mt-2.5 text-xs text-ink-secondary">
                Valid for transit until: <strong className="text-ink">{formatDateTime(transfer.permit.validUntil)}</strong>
              </p>
            </div>

            <div className="grid grid-cols-2 gap-2 pt-2">
              <Button
                variant="secondary"
                size="md"
                leftIcon={<MessageCircle size={16} />}
                onClick={handleShareWhatsApp}
              >
                Share to Driver
              </Button>
              <Button
                variant="primary"
                size="md"
                onClick={() => setDriverPassModalOpen(false)}
              >
                Close Pass
              </Button>
            </div>
          </div>
        </BottomSheet>
      )}
    </Screen>
  );
}
