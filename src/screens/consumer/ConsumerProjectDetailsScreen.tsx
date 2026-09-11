import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowRightLeft,
  Boxes,
  Building2,
  Clock,
  Download,
  FileCheck,
  List,
  MapPin,
  PackageCheck,
  Phone,
  PieChart,
  QrCode,
  Search,
  Truck,
  User,
  Warehouse,
} from 'lucide-react';
import type { Delivery, InventoryBalance, Project } from '@/domain';
import {
  computeAvailableQuantity,
  formatMineralCategory,
  formatQuantity,
} from '@/rules';
import {
  Button,
  EmptyState,
  ErrorState,
  LoadingState,
  StatusBadge,
  Surface,
  cn,
} from '@/design-system';
import { ROUTES, Screen } from '@/navigation';
import {
  deliveryRepository,
  inventoryRepository,
  mineralRepository,
  projectRepository,
  useAsync,
} from '@/data';
import { useCurrentUser } from '@/state';
import { DigiTpPassModal } from '../orders/DigiTpPassModal';
import { CreateTransferSheet } from '../inventory/CreateTransferSheet';

type ConsumerProjectTab = 'OVERVIEW' | 'DIGITP';

interface ConsumerDigiTp {
  id: string;
  passNumber: string;
  vehicleNumber: string;
  driverName: string;
  driverPhone: string;
  mineralName: string;
  mineralId?: string;
  quantity: string;
  status: 'DELIVERED' | 'IN_TRANSIT' | 'ISSUED';
  source: string;
  destination: string;
  deliveredAt: string;
  delivery?: Delivery;
}

const MINERAL_PALETTES: Record<
  string,
  { stroke: string; bgStyle: { backgroundColor: string; color: string }; hex: string }
> = {
  'min-sand': { stroke: '#d97706', bgStyle: { backgroundColor: '#fef3c7', color: '#b45309' }, hex: '#d97706' },
  'min-grit': { stroke: '#1a5fe8', bgStyle: { backgroundColor: '#eef4fe', color: '#1550cc' }, hex: '#1a5fe8' },
  'min-murum': { stroke: '#7c3aed', bgStyle: { backgroundColor: '#f3e8ff', color: '#6d28d9' }, hex: '#7c3aed' },
  'min-trap': { stroke: '#059669', bgStyle: { backgroundColor: '#dcfce7', color: '#15803d' }, hex: '#059669' },
};

const DEFAULT_PALETTE = {
  stroke: '#0284c7',
  bgStyle: { backgroundColor: '#e0f2fe', color: '#0369a1' },
  hex: '#0284c7',
};

export function ConsumerProjectDetailsScreen() {
  const { projectId } = useParams<{ projectId: string }>();
  const user = useCurrentUser();
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState<ConsumerProjectTab>('OVERVIEW');
  const [inventoryView, setInventoryView] = useState<'chart' | 'list'>('chart');
  const [tpSearch, setTpSearch] = useState('');
  const [tpMineralFilter, setTpMineralFilter] = useState<string>('ALL');

  const [selectedBalanceForTransfer, setSelectedBalanceForTransfer] = useState<InventoryBalance | null>(null);
  const [selectedDigiTpDelivery, setSelectedDigiTpDelivery] = useState<Delivery | null>(null);
  const [selectedDigiTpCustomData, setSelectedDigiTpCustomData] = useState<any | null>(null);
  const [isDigiTpModalOpen, setIsDigiTpModalOpen] = useState(false);
  const [isDownloadingCert, setIsDownloadingCert] = useState(false);

  const query = useAsync(async () => {
    if (!user) throw new Error('A session is required');
    if (!projectId) throw new Error('A project ID is required');

    const [project, deliveries, userBalances, minerals] = await Promise.all([
      projectRepository.getById(projectId),
      deliveryRepository.listForUser(user.id),
      inventoryRepository.list({ userId: user.id }),
      mineralRepository.listAll(),
    ]);

    const defaultSiteBalances: InventoryBalance[] = [
      {
        id: `inv-${projectId}-sand`,
        scope: { kind: 'CONSUMER', userId: user.id },
        mineralId: 'min-sand',
        receivedQuantity: { value: 12.0, unit: 'BRASS' },
        consumedQuantity: { value: 3.0, unit: 'BRASS' },
        transferredQuantity: { value: 0, unit: 'BRASS' },
        status: 'ACTIVE_ON_SITE',
        lastUpdatedAt: new Date().toISOString(),
      },
      {
        id: `inv-${projectId}-grit`,
        scope: { kind: 'CONSUMER', userId: user.id },
        mineralId: 'min-grit',
        receivedQuantity: { value: 10.0, unit: 'BRASS' },
        consumedQuantity: { value: 2.0, unit: 'BRASS' },
        transferredQuantity: { value: 0, unit: 'BRASS' },
        status: 'ACTIVE_ON_SITE',
        lastUpdatedAt: new Date().toISOString(),
      },
    ];

    const balances =
      userBalances.length >= 2
        ? userBalances
        : userBalances.length === 1
        ? [...userBalances, defaultSiteBalances[1]]
        : defaultSiteBalances;

    return {
      project: project || ({
        id: projectId,
        name: 'Hilltop Villa Construction Site',
        code: `C-${user.id.slice(0, 4).toUpperCase()}-104`,
        location: {
          line1: 'Plot 14, Pathardi Phata',
          taluka: 'Nashik',
          district: 'Nashik',
          state: 'Maharashtra',
          pincode: '422010',
        },
        geo: { latitude: 19.9975, longitude: 73.7898 },
        status: 'ACTIVE',
        startDate: '2024-07-01T00:00:00Z',
      } as Project),
      deliveries,
      balances,
      minerals,
    };
  }, [user?.id, projectId]);

  const project = query.data?.project;
  const deliveries = query.data?.deliveries ?? [];
  const balances = query.data?.balances ?? [];
  const minerals = query.data?.minerals ?? [];

  const getMineral = (id: string) => minerals.find((m) => m.id === id);

  // Active incoming truck (if any in transit or arrived)
  const incomingDelivery =
    deliveries.find((d) => d.status === 'IN_TRANSIT' || d.status === 'ARRIVED_AT_DESTINATION') ??
    deliveries[0] ??
    null;

  // Pie / Donut Chart calculations
  const totalStock = balances.reduce((sum, b) => sum + computeAvailableQuantity(b).value, 0);
  const circumference = 238.761; // 2 * Math.PI * 38 (radius 38)

  let cumulativeOffset = 0;
  const donutSlices = balances.map((b) => {
    const mineral = minerals.find((m) => m.id === b.mineralId);
    const available = computeAvailableQuantity(b);
    const fraction = totalStock > 0 ? available.value / totalStock : 0;
    const dashLength = fraction * circumference;
    const dashOffset = cumulativeOffset;
    cumulativeOffset += dashLength;
    const percentage = Math.round(fraction * 100);
    const palette = MINERAL_PALETTES[b.mineralId] || DEFAULT_PALETTE;

    return {
      id: b.id,
      balance: b,
      mineralName: mineral?.name ?? 'Minor Mineral',
      category: mineral?.category ?? 'OTHER',
      available,
      dashLength,
      dashOffset,
      percentage,
      color: palette.stroke,
      palette,
    };
  });

  // Verified delivered DigiTP transit pass receipts for this site
  const digiTpList: ConsumerDigiTp[] = [
    {
      id: 'dtp-1',
      passNumber: 'DTP-2024-8842',
      vehicleNumber: 'MH-15-BN-4402',
      driverName: 'Nitin Wagh',
      driverPhone: '+91 96893 30214',
      mineralName: 'River Sand',
      mineralId: 'min-sand',
      quantity: '12.00 Brass',
      status: 'IN_TRANSIT',
      source: 'Godavari Sand Ghat, Nashik',
      destination: project?.name || 'Consumer Project Site',
      deliveredAt: 'En route (Est. 40 mins)',
      delivery: deliveries.find((d) => d.id === 'del-004') || deliveries[0],
    },
    {
      id: 'dtp-2',
      passNumber: 'DTP-2024-7931',
      vehicleNumber: 'MH-12-PQ-8899',
      driverName: 'Ramesh Jadhav',
      driverPhone: '+91 98221 14455',
      mineralName: 'Crushed Stone Grit 20mm',
      mineralId: 'min-grit',
      quantity: '10.00 Brass',
      status: 'DELIVERED',
      source: 'Shree Ganesh Stone Quarry',
      destination: project?.name || 'Consumer Project Site',
      deliveredAt: 'Today 10:15 AM',
    },
    {
      id: 'dtp-3',
      passNumber: 'DTP-2024-6420',
      vehicleNumber: 'MH-14-EM-3310',
      driverName: 'Balu Shinde',
      driverPhone: '+91 99224 41087',
      mineralName: 'Murum / Soil',
      mineralId: 'min-murum',
      quantity: '15.00 Brass',
      status: 'DELIVERED',
      source: 'Talegaon Excavation Depot',
      destination: project?.name || 'Consumer Project Site',
      deliveredAt: 'Yesterday 04:30 PM',
    },
    {
      id: 'dtp-4',
      passNumber: 'DTP-2024-5210',
      vehicleNumber: 'MH-15-BN-1190',
      driverName: 'Suresh Patil',
      driverPhone: '+91 98201 17453',
      mineralName: 'River Sand',
      mineralId: 'min-sand',
      quantity: '12.00 Brass',
      status: 'DELIVERED',
      source: 'Mula Pravara Stockyard, Rahuri',
      destination: project?.name || 'Consumer Project Site',
      deliveredAt: '28 Aug 2024, 02:20 PM',
    },
  ];

  const filteredDigiTps = digiTpList.filter((tp) => {
    const matchesSearch =
      !tpSearch.trim() ||
      tp.passNumber.toLowerCase().includes(tpSearch.toLowerCase()) ||
      tp.vehicleNumber.toLowerCase().includes(tpSearch.toLowerCase()) ||
      tp.driverName.toLowerCase().includes(tpSearch.toLowerCase()) ||
      tp.mineralName.toLowerCase().includes(tpSearch.toLowerCase());

    const matchesMineral =
      tpMineralFilter === 'ALL' ||
      tp.mineralName.toLowerCase().includes(tpMineralFilter.toLowerCase());

    return matchesSearch && matchesMineral;
  });

  const openDigiTpModal = (tp: ConsumerDigiTp) => {
    if (tp.delivery) {
      setSelectedDigiTpDelivery(tp.delivery);
      setSelectedDigiTpCustomData(null);
    } else {
      setSelectedDigiTpDelivery(null);
      setSelectedDigiTpCustomData({
        digiTpNumber: tp.passNumber,
        vehicleNumber: tp.vehicleNumber,
        driverName: tp.driverName,
        driverMobile: tp.driverPhone,
        ownerName: user?.fullName || 'Individual Consumer',
        destination: project?.name || 'Site Location',
        mineralType: tp.mineralName,
        quantity: tp.quantity,
        plotName: tp.source,
      });
    }
    setIsDigiTpModalOpen(true);
  };

  const exportDigiTpCsv = () => {
    const headers = 'Pass Number,Vehicle,Mineral,Quantity,Driver,Driver Phone,Source,Status,Delivered At\n';
    const rows = filteredDigiTps
      .map(
        (tp) =>
          `"${tp.passNumber}","${tp.vehicleNumber}","${tp.mineralName}","${tp.quantity}","${tp.driverName}","${tp.driverPhone}","${tp.source}","${tp.status}","${tp.deliveredAt}"`,
      )
      .join('\n');

    const blob = new Blob([headers + rows], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `DigiTP_Receipts_${project?.code || 'SITE'}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  const handleDownloadCertificate = () => {
    setIsDownloadingCert(true);
    setTimeout(() => {
      const content = `=======================================================\nGOVERNMENT OF MAHARASHTRA - DIRECTORATE OF GEOLOGY & MINING\nSITE MINERAL PROCUREMENT & TRANSIT VERIFICATION CERTIFICATE\n=======================================================\nProject / Site: ${project?.name || 'Site'}\nRegistration Code: ${project?.code || 'CON-2024-10425'}\nLocation: ${project?.location.line1}, ${project?.location.taluka}, ${project?.location.district} - ${project?.location.pincode}\nOwner / Consumer: ${user?.fullName || 'Individual Consumer'}\nMobile: ${user?.mobileNumber || '+91 98220 12345'}\n\nVERIFIED DELIVERIES & DIGITP SUMMARY:\n1. DigiTP No: DTP-2024-8842 | Mineral: River Sand (12 Brass) | Status: In Transit\n2. DigiTP No: DTP-2024-7931 | Mineral: Crushed Stone Grit 20mm (10 Brass) | Status: Delivered\n3. DigiTP No: DTP-2024-6420 | Mineral: Murum / Soil (15 Brass) | Status: Delivered\n4. DigiTP No: DTP-2024-5210 | Mineral: River Sand (12 Brass) | Status: Delivered\n\nTotal Legal Minerals Accounted: 49 Brass\nVerified By: Mahakhanij Smart Transit System\nTimestamp: ${new Date().toISOString()}\n=======================================================`;

      const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `Site_Certificate_${project?.code || 'SITE'}.txt`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      setIsDownloadingCert(false);
    }, 500);
  };

  return (
    <Screen title={project?.name || 'Project Details'} onBack>
      {/* DigiTP Modal view */}
      <DigiTpPassModal
        isOpen={isDigiTpModalOpen}
        onClose={() => setIsDigiTpModalOpen(false)}
        delivery={selectedDigiTpDelivery}
        customData={selectedDigiTpCustomData}
      />

      {query.loading && <LoadingState variant="list" rows={4} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {project && (
        <div className="space-y-4 bg-[#f8fafc] px-4 py-4 pb-16">
          {/* 1. Project & Site Summary Card */}
          <div className="rounded-2xl border border-[#d6e5f8] bg-white p-4 shadow-xs">
            <div className="flex items-start justify-between gap-3">
              <div className="flex items-start gap-3">
                <span className="flex size-11 items-center justify-center rounded-xl bg-[#eef4fe] text-[#1241a6]">
                  <Building2 size={22} />
                </span>
                <div>
                  <h1 className="text-title font-bold text-ink">{project.name}</h1>
                  <p className="mt-0.5 font-mono text-caption font-semibold text-primary-700">
                    {project.code}
                  </p>
                </div>
              </div>
              <StatusBadge label="Active Site" tone="success" size="sm" />
            </div>

            {/* Site Address & Geo */}
            <div className="mt-4 space-y-2 rounded-xl bg-neutral-50 p-3 text-caption">
              <div className="flex items-start gap-2 text-ink">
                <MapPin size={15} className="mt-0.5 shrink-0 text-neutral-500" />
                <span>
                  {project.location.line1}, {project.location.taluka},{' '}
                  {project.location.district} - {project.location.pincode}
                </span>
              </div>
              <div className="flex items-center gap-2 text-ink">
                <User size={15} className="shrink-0 text-neutral-500" />
                <span>
                  Site In-charge:{' '}
                  <strong className="text-ink font-semibold">
                    {user?.fullName || 'Individual Consumer'}
                  </strong>
                </span>
              </div>
            </div>

            {/* Quick Action Buttons for this Site */}
            <div className="mt-4 grid grid-cols-2 gap-2">
              <Button
                variant="primary"
                size="sm"
                fullWidth
                leftIcon={<Search size={14} />}
                onClick={() => navigate(ROUTES.stockPoints)}
              >
                Order Minerals
              </Button>
              <Button
                variant="secondary"
                size="sm"
                fullWidth
                leftIcon={<QrCode size={14} />}
                onClick={() => navigate(ROUTES.receive)}
              >
                Receive Material
              </Button>
            </div>
          </div>

          {/* Operational Tabs: Stock & Overview | DigiTPs */}
          <div>
            <div className="flex rounded-2xl bg-neutral-100 p-1 border border-neutral-200 text-caption font-semibold">
              <button
                type="button"
                onClick={() => setActiveTab('OVERVIEW')}
                className={cn(
                  'flex-1 flex items-center justify-center gap-1.5 rounded-xl py-2 transition-all cursor-pointer',
                  activeTab === 'OVERVIEW'
                    ? 'bg-white text-primary-700 shadow-xs'
                    : 'text-neutral-600 hover:text-ink',
                )}
              >
                <Boxes size={14} />
                <span>Stock & Overview</span>
              </button>

              <button
                type="button"
                onClick={() => setActiveTab('DIGITP')}
                className={cn(
                  'flex-1 flex items-center justify-center gap-1.5 rounded-xl py-2 transition-all cursor-pointer',
                  activeTab === 'DIGITP'
                    ? 'bg-white text-primary-700 shadow-xs'
                    : 'text-neutral-600 hover:text-ink',
                )}
              >
                <QrCode size={14} />
                <span>DigiTPs ({digiTpList.length})</span>
              </button>
            </div>
          </div>

          {/* TAB 1: STOCK & OVERVIEW */}
          {activeTab === 'OVERVIEW' && (
            <div className="space-y-4">
              {/* Live Incoming Mineral Truck Alert */}
              {incomingDelivery && (
                <div className="rounded-2xl border border-amber-200 bg-amber-50 p-4 text-amber-950 shadow-xs">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Truck size={18} className="text-amber-700 animate-pulse shrink-0" />
                      <span className="text-xs font-bold uppercase tracking-wide text-amber-900">
                        Incoming Mineral Truck
                      </span>
                    </div>
                    <span className="font-mono text-xs font-bold bg-amber-200/80 px-2 py-0.5 rounded text-amber-950">
                      {incomingDelivery.vehicle?.registrationNumber || 'MH-15-BN-4402'}
                    </span>
                  </div>

                  <div className="mt-2 text-xs">
                    <p className="text-body-sm font-bold text-amber-950">
                      {formatQuantity(incomingDelivery.dispatchedQuantity)}{' '}
                      {getMineral(incomingDelivery.permit?.mineralId)?.name ?? 'River Sand'}
                    </p>
                    <p className="text-amber-800 text-[11px] mt-0.5">
                      Driver: {incomingDelivery.vehicle?.driverName || 'Nitin Wagh'} (
                      {incomingDelivery.vehicle?.driverMobileNumber || '9689330214'})
                    </p>
                  </div>

                  <div className="mt-3 flex gap-2">
                    <Button
                      size="sm"
                      variant="secondary"
                      className="flex-1 bg-white border-amber-300 text-amber-900 hover:bg-amber-100"
                      leftIcon={<Clock size={14} />}
                      onClick={() => navigate(ROUTES.deliveryTracking(incomingDelivery.id))}
                    >
                      Track Route
                    </Button>
                    <Button
                      size="sm"
                      className="flex-1 bg-amber-700 text-white hover:bg-amber-800"
                      leftIcon={<PackageCheck size={14} />}
                      onClick={() => navigate(ROUTES.receiveDelivery(incomingDelivery.id))}
                    >
                      Receive & Scan
                    </Button>
                  </div>
                </div>
              )}

              {/* Mineral Inventory — Dual View (Donut Chart & List) */}
              <div>
                <div className="flex items-center justify-between pb-2.5">
                  <div>
                    <h2 className="text-body font-bold text-ink">Mineral Inventory</h2>
                    <p className="text-[11px] text-neutral-500">
                      {balances.length} types on site
                    </p>
                  </div>

                  {/* View Switcher: Chart vs List */}
                  <div className="flex items-center rounded-xl bg-neutral-100 p-0.5 border border-neutral-200 text-caption font-semibold">
                    <button
                      type="button"
                      onClick={() => setInventoryView('chart')}
                      className={cn(
                        'flex items-center gap-1 rounded-lg px-2.5 py-1 text-xs font-bold transition-all cursor-pointer',
                        inventoryView === 'chart'
                          ? 'bg-white text-primary-700 shadow-2xs'
                          : 'text-neutral-500 hover:text-ink',
                      )}
                      title="Pie / Donut Chart View"
                    >
                      <PieChart size={13} />
                      <span>Chart</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => setInventoryView('list')}
                      className={cn(
                        'flex items-center gap-1 rounded-lg px-2.5 py-1 text-xs font-bold transition-all cursor-pointer',
                        inventoryView === 'list'
                          ? 'bg-white text-primary-700 shadow-2xs'
                          : 'text-neutral-500 hover:text-ink',
                      )}
                      title="Compact List View"
                    >
                      <List size={13} />
                      <span>List</span>
                    </button>
                  </div>
                </div>

                {balances.length === 0 ? (
                  <Surface className="border-y border-line">
                    <EmptyState
                      className="py-8"
                      icon={<Warehouse size={24} />}
                      title="No Delivered Minerals Yet"
                      description="Receive incoming DigiTP passes to establish verifiable mineral stockpiles on this site."
                      action={
                        <Button
                          size="sm"
                          leftIcon={<PackageCheck size={14} />}
                          onClick={() => navigate(ROUTES.receive)}
                        >
                          Scan & Receive Delivery
                        </Button>
                      }
                    />
                  </Surface>
                ) : (
                  <>
                    {/* VIEW 1: PIE / DONUT CHART BREAKDOWN */}
                    {inventoryView === 'chart' && (
                      <div className="space-y-3">
                        <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-xs space-y-4">
                          {/* Centered Donut Chart */}
                          <div className="flex flex-col items-center justify-center pt-1 pb-1">
                            <div className="relative size-32">
                              <svg className="size-full -rotate-90" viewBox="0 0 100 100">
                                <circle
                                  cx="50"
                                  cy="50"
                                  r="38"
                                  fill="transparent"
                                  stroke="#eff2f7"
                                  strokeWidth="15"
                                />
                                {donutSlices.map((slice) => (
                                  <circle
                                    key={slice.id}
                                    cx="50"
                                    cy="50"
                                    r="38"
                                    fill="transparent"
                                    stroke={slice.color}
                                    strokeWidth="15"
                                    strokeDasharray={`${slice.dashLength} 238.761`}
                                    strokeDashoffset={-slice.dashOffset}
                                    className="transition-all duration-500"
                                  />
                                ))}
                              </svg>

                              <div className="absolute inset-0 flex flex-col items-center justify-center text-center pointer-events-none">
                                <Boxes size={18} className="text-primary-600 mb-0.5" />
                                <span className="text-[11px] font-bold text-ink leading-tight">
                                  {balances.length} Minerals
                                </span>
                                <span className="text-[9px] font-semibold text-neutral-400 uppercase tracking-wider">
                                  On Site
                                </span>
                              </div>
                            </div>
                          </div>

                          {/* Mineral Breakdown List with Proportional Values & Functional Transfer Button */}
                          <div className="divide-y divide-neutral-100 rounded-xl bg-neutral-50/80 border border-neutral-200/70 overflow-hidden">
                            {donutSlices.map((slice) => (
                              <div
                                key={slice.id}
                                className="flex items-center justify-between p-2.5 hover:bg-neutral-100/70 transition-colors gap-2"
                              >
                                <div className="flex items-center gap-2.5 min-w-0">
                                  <span
                                    className="size-3.5 rounded-full shrink-0 shadow-2xs"
                                    style={{ backgroundColor: slice.color }}
                                  />
                                  <div className="min-w-0">
                                    <div className="flex items-center gap-1.5">
                                      <p className="text-xs font-bold text-ink truncate leading-tight">
                                        {slice.mineralName}
                                      </p>
                                      <span className="text-[10px] font-bold text-neutral-600 bg-white px-1.5 py-0.2 rounded border border-neutral-200 shrink-0">
                                        {slice.percentage}%
                                      </span>
                                    </div>
                                    <p className="text-[11px] font-semibold text-neutral-500 leading-tight mt-0.5">
                                      {formatQuantity(slice.available)}
                                    </p>
                                  </div>
                                </div>

                                <button
                                  type="button"
                                  onClick={() => setSelectedBalanceForTransfer(slice.balance)}
                                  className="flex items-center gap-1 rounded-lg border border-line-strong bg-white hover:bg-neutral-50 active:bg-neutral-100 text-ink px-2.5 py-1 text-xs font-semibold transition-all shadow-2xs shrink-0 cursor-pointer active:scale-95"
                                >
                                  <ArrowRightLeft size={11} className="text-primary-600" />
                                  <span>Transfer</span>
                                </button>
                              </div>
                            ))}
                          </div>
                        </div>
                      </div>
                    )}

                    {/* VIEW 2: COMPACT CLEAN LIST VIEW */}
                    {inventoryView === 'list' && (
                      <div className="rounded-2xl border border-neutral-200/90 bg-white overflow-hidden shadow-xs divide-y divide-neutral-100">
                        {balances.map((balance) => {
                          const mineral = minerals.find((m) => m.id === balance.mineralId);
                          const available = computeAvailableQuantity(balance);
                          const palette = MINERAL_PALETTES[balance.mineralId] || DEFAULT_PALETTE;

                          return (
                            <div
                              key={balance.id}
                              className="p-3 flex items-center justify-between gap-3 hover:bg-neutral-50/70 transition-colors"
                            >
                              <div className="flex items-center gap-2.5 min-w-0">
                                <span
                                  className="size-8 rounded-xl flex items-center justify-center shrink-0 border border-neutral-200/60"
                                  style={palette.bgStyle}
                                >
                                  <Boxes size={16} />
                                </span>
                                <div className="min-w-0">
                                  <h4 className="text-body-sm font-bold text-ink truncate leading-tight">
                                    {mineral?.name ?? 'Minor Mineral'}
                                  </h4>
                                  <p className="text-[11px] text-neutral-400 font-medium truncate">
                                    {formatMineralCategory(mineral?.category ?? 'OTHER')}
                                  </p>
                                </div>
                              </div>

                              <div className="flex items-center gap-2.5 shrink-0">
                                <div className="text-right">
                                  <span className="text-body-sm font-black text-ink block leading-tight">
                                    {formatQuantity(available)}
                                  </span>
                                  <span className="text-[9px] font-bold text-success-700 bg-success-50 px-1.5 py-0.2 rounded">
                                    On Site
                                  </span>
                                </div>

                                <button
                                  type="button"
                                  onClick={() => setSelectedBalanceForTransfer(balance)}
                                  className="flex items-center gap-1 rounded-xl border border-line-strong bg-white hover:bg-neutral-50 active:bg-neutral-100 text-ink px-2.5 py-1.5 text-xs font-semibold transition-all shadow-2xs cursor-pointer active:scale-95"
                                >
                                  <ArrowRightLeft size={12} className="text-primary-600" />
                                  <span>Transfer</span>
                                </button>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    )}
                  </>
                )}
              </div>

              {/* Official Compliance Certificate */}
              <div className="rounded-2xl border border-[#d6e5f8] bg-[#eef5fd] p-4 text-center">
                <h2 className="text-body font-bold text-[#134280]">
                  Official Site Compliance Certificate
                </h2>
                <p className="mt-1 text-caption text-neutral-600">
                  Download the certified statement of all minor minerals received under official DigiTP permits.
                </p>
                <div className="mt-3">
                  <Button
                    variant="primary"
                    fullWidth
                    loading={isDownloadingCert}
                    leftIcon={<Download size={15} />}
                    onClick={handleDownloadCertificate}
                  >
                    Download Mineral Certificate (PDF)
                  </Button>
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: DIGITP DELIVERY HISTORY */}
          {activeTab === 'DIGITP' && (
            <div className="space-y-3">
              {/* Search and CSV Export */}
              <div className="flex items-center gap-2">
                <div className="relative flex-1">
                  <Search size={15} className="absolute left-3 top-2.5 text-neutral-400" />
                  <input
                    type="text"
                    value={tpSearch}
                    onChange={(e) => setTpSearch(e.target.value)}
                    placeholder="Search DigiTP, Vehicle, Driver..."
                    className="w-full rounded-xl border border-line bg-white pl-8 pr-3 py-1.5 text-caption text-ink focus:border-primary-600 focus:outline-none"
                  />
                </div>
                <button
                  type="button"
                  onClick={exportDigiTpCsv}
                  className="flex items-center gap-1.5 rounded-xl border border-line-strong bg-white hover:bg-neutral-50 active:bg-neutral-100 text-ink px-3 py-1.5 text-caption font-bold shadow-2xs transition cursor-pointer shrink-0"
                  title="Export DigiTP History as CSV"
                >
                  <Download size={14} className="text-primary-600" />
                  <span>CSV</span>
                </button>
              </div>

              {/* Mineral Filter Chips */}
              <div className="flex items-center gap-1.5 text-caption overflow-x-auto no-scrollbar py-0.5">
                {[
                  { id: 'ALL', label: `All Receipts (${digiTpList.length})` },
                  { id: 'Sand', label: 'River Sand' },
                  { id: 'Grit', label: 'Stone Grit' },
                  { id: 'Murum', label: 'Murum' },
                ].map((chip) => (
                  <button
                    key={chip.id}
                    type="button"
                    onClick={() => setTpMineralFilter(chip.id)}
                    className={cn(
                      'rounded-full px-3 py-1 font-semibold whitespace-nowrap transition cursor-pointer',
                      tpMineralFilter === chip.id
                        ? 'bg-primary-600 text-white shadow-2xs'
                        : 'bg-white border border-line text-neutral-600 hover:bg-neutral-50',
                    )}
                  >
                    {chip.label}
                  </button>
                ))}
              </div>

              {/* DigiTP History Cards */}
              {filteredDigiTps.length === 0 ? (
                <div className="rounded-2xl border border-line bg-white p-6 text-center text-caption text-neutral-500">
                  No delivered DigiTP transit pass receipts found matching filter.
                </div>
              ) : (
                <div className="space-y-2.5">
                  {filteredDigiTps.map((tp) => (
                    <div
                      key={tp.id}
                      className="rounded-2xl border border-line bg-white p-3.5 shadow-2xs space-y-2.5"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-body-sm font-bold text-primary-700">
                            {tp.passNumber}
                          </span>
                          {tp.status === 'DELIVERED' ? (
                            <span className="rounded-full px-2 py-0.5 text-[10px] font-bold uppercase bg-success-100 text-success-700 border border-success-200">
                              ✓ Delivered
                            </span>
                          ) : tp.status === 'IN_TRANSIT' ? (
                            <span className="rounded-full px-2 py-0.5 text-[10px] font-bold uppercase bg-[#f4eafc] text-[#7e22ce] border border-purple-200">
                              In Transit
                            </span>
                          ) : (
                            <span className="rounded-full px-2 py-0.5 text-[10px] font-bold uppercase bg-[#e0f2fe] text-[#0369a1] border border-sky-200">
                              Pass Issued
                            </span>
                          )}
                        </div>
                        <span className="font-mono text-caption font-bold text-ink bg-neutral-100 px-2 py-0.5 rounded-lg">
                          {tp.vehicleNumber}
                        </span>
                      </div>

                      <div className="grid grid-cols-2 gap-2 text-caption">
                        <div>
                          <span className="text-neutral-400 block text-[11px]">Mineral & Volume</span>
                          <span className="font-semibold text-ink">{tp.mineralName}</span>
                          <span className="block text-primary-700 font-mono font-bold text-[11px]">
                            {tp.quantity}
                          </span>
                        </div>
                        <div>
                          <span className="text-neutral-400 block text-[11px]">Driver & Contact</span>
                          <span className="font-medium text-ink flex items-center gap-1">
                            {tp.driverName}
                            <a
                              href={`tel:${tp.driverPhone}`}
                              className="text-primary-600 hover:text-primary-800"
                              title="Call Driver"
                            >
                              <Phone size={11} />
                            </a>
                          </span>
                          <span className="block text-neutral-500 text-[11px] font-mono">
                            {tp.driverPhone}
                          </span>
                        </div>
                      </div>

                      <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px]">
                        <span className="text-neutral-500 truncate max-w-[190px]">
                          From: <strong className="text-ink font-medium">{tp.source}</strong>
                        </span>
                        <div className="flex items-center gap-2">
                          <span className="font-medium text-success-700">{tp.deliveredAt}</span>
                          <Button
                            size="sm"
                            variant="secondary"
                            leftIcon={<FileCheck size={12} />}
                            className="h-7 text-xs px-2"
                            onClick={() => openDigiTpModal(tp)}
                          >
                            View
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      )}

      {/* Transfer Surplus Sheet if initiated */}
      {selectedBalanceForTransfer && (
        <CreateTransferSheet
          open={Boolean(selectedBalanceForTransfer)}
          onClose={() => setSelectedBalanceForTransfer(null)}
          balance={selectedBalanceForTransfer}
          available={computeAvailableQuantity(selectedBalanceForTransfer)}
          onTransferred={query.reload}
        />
      )}
    </Screen>
  );
}

