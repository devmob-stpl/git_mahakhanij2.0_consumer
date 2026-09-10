import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  AlertTriangle,
  ArrowRight,
  Download,
  Edit3,
  FileText,
  FileX,
  IndianRupee,
  MapPin,
  Plus,
  Search,
  Shovel,
} from 'lucide-react';
import type { ID, TemporaryExcavationApplication } from '@/domain';
import {
  awaitsDemandNotePayment,
  formatMoney,
  formatQuantity,
  hasExcavationOrder,
  needsApplicantResponse,
  statusPresentation,
} from '@/rules';
import {
  Button,
  ConfirmDialog,
  EmptyState,
  ErrorState,
  LoadingState,
  StatusBadge,
  cn,
} from '@/design-system';
import { ROUTES, Screen } from '@/navigation';
import { mineralRepository, temporaryExcavationRepository, useAsync } from '@/data';
import { useCurrentOrganization } from '@/state';
import { useCopy } from '@/content';

const STEP_NAMES = [
  'Applicant Details',
  'Excavation Details',
  'Quarry & Location',
  'Compliance Documents',
  'Review & Declaration',
];

type FilterTab = 'ALL' | 'DRAFTS' | 'UNDER_REVIEW' | 'DEMAND_NOTE' | 'PERMIT_ISSUED' | 'REJECTED' | 'ATTENTION';

export function TemporaryExcavationScreen() {
  const organization = useCurrentOrganization();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const t = useCopy();

  const filterParam = searchParams.get('filter') as FilterTab | null;
  const [activeTab, setActiveTab] = useState<FilterTab>(filterParam || 'ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [draftToDelete, setDraftToDelete] = useState<string | null>(null);
  const [showResumeModal, setShowResumeModal] = useState(false);

  useEffect(() => {
    if (filterParam) {
      setActiveTab(filterParam);
    }
  }, [filterParam]);

  const query = useAsync(async () => {
    const [applications, minerals] = await Promise.all([
      temporaryExcavationRepository.listByOrganization(organization?.id || 'org-001'),
      mineralRepository.listAll(),
    ]);

    return { applications, minerals };
  }, [organization?.id]);

  const applications = query.data?.applications ?? [];
  const minerals = query.data?.minerals ?? [];
  const mineralName = (id: ID) =>
    minerals.find((mineral) => mineral.id === id)?.name ?? 'Minor Mineral';

  const draftApplications = applications.filter((app) => app.status === 'DRAFT');
  const submittedApplications = applications.filter((app) => app.status !== 'DRAFT');
  const draftCount = draftApplications.length;
  const latestDraft = draftApplications[0] ?? null;

  const isUnderReviewCategory = (app: TemporaryExcavationApplication) =>
    app.status === 'UNDER_REVIEW' || app.status === 'QUERY_RAISED';

  // Counts for Top Summary Cards & Chips
  const totalCount = submittedApplications.length;
  const underReviewCount = applications.filter(isUnderReviewCategory).length;
  const demandNoteCount = applications.filter(
    (a) => a.status === 'DEMAND_NOTE_ISSUED'
  ).length;
  const permitIssuedCount = applications.filter(
    (a) => a.status === 'ORDER_ISSUED'
  ).length;
  const rejectedCount = applications.filter(
    (a) => a.status === 'REJECTED'
  ).length;
  const attentionCount = applications.filter(
    (app) => needsApplicantResponse(app) || awaitsDemandNotePayment(app) || app.status === 'REJECTED'
  ).length;

  async function handleConfirmDeleteDraft() {
    if (!draftToDelete) return;
    try {
      await temporaryExcavationRepository.deleteDraft(draftToDelete);
      try {
        const key = `mahakhanij_temp_excavation_draft_${organization?.id || 'org-001'}`;
        const local = localStorage.getItem(key);
        if (local) {
          const parsed = JSON.parse(local);
          if (parsed.draftId === draftToDelete) {
            localStorage.removeItem(key);
          }
        }
      } catch (e) {}
      query.reload();
    } finally {
      setDraftToDelete(null);
    }
  }

  function handleNewApplicationClick() {
    if (draftApplications.length > 0) {
      setShowResumeModal(true);
    } else {
      navigate(ROUTES.newExcavationApplication);
    }
  }

  // Filtered List
  const filteredApplications = applications.filter((app) => {
    // Tab filter
    if (activeTab === 'ALL' && app.status === 'DRAFT') return false;
    if (activeTab === 'DRAFTS' && app.status !== 'DRAFT') return false;
    if (activeTab === 'UNDER_REVIEW' && !isUnderReviewCategory(app)) return false;
    if (activeTab === 'DEMAND_NOTE' && app.status !== 'DEMAND_NOTE_ISSUED') return false;
    if (activeTab === 'PERMIT_ISSUED' && app.status !== 'ORDER_ISSUED') return false;
    if (activeTab === 'REJECTED' && app.status !== 'REJECTED') return false;
    if (activeTab === 'ATTENTION' && !needsApplicantResponse(app) && !awaitsDemandNotePayment(app) && app.status !== 'REJECTED') return false;

    // Search query
    if (searchQuery.trim()) {
      const qLower = searchQuery.toLowerCase();
      const minName = mineralName(app.mineralId).toLowerCase();
      const matchesNo = app.applicationNumber.toLowerCase().includes(qLower);
      const matchesSurvey = app.surveyNumber.toLowerCase().includes(qLower);
      const matchesVillage = app.village.toLowerCase().includes(qLower);
      const matchesTaluka = app.siteAddress.taluka.toLowerCase().includes(qLower);
      const matchesMineral = minName.includes(qLower);
      if (!matchesNo && !matchesSurvey && !matchesVillage && !matchesTaluka && !matchesMineral) {
        return false;
      }
    }

    return true;
  });

  return (
    <Screen
      title="Temporary Excavation"
      onBack
      footer={
        <Button
          size="lg"
          fullWidth
          leftIcon={<Plus size={16} />}
          onClick={handleNewApplicationClick}
        >
          {t.excavation.newApplication}
        </Button>
      }
    >
      {query.loading && <LoadingState variant="list" rows={4} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {query.data && (
        <div className="space-y-4 bg-[#f8fafc] px-4 py-4 pb-12">
          {/* 1. Compact Strategic Pipeline Dashboard */}
          <div className="rounded-2xl border border-line bg-surface p-3 shadow-xs space-y-3">
            {/* Top: 4-Stage Status Data Cards */}
            <div className="grid grid-cols-4 gap-1.5">
              {/* Stage 1: Pending */}
              <button
                type="button"
                onClick={() => setActiveTab(activeTab === 'UNDER_REVIEW' ? 'ALL' : 'UNDER_REVIEW')}
                className={cn(
                  'flex flex-col items-center justify-center rounded-xl py-2.5 px-1 transition-all cursor-pointer border text-center',
                  activeTab === 'UNDER_REVIEW'
                    ? 'border-warning-500 bg-warning-50 ring-2 ring-warning-500/25 shadow-xs'
                    : 'border-line bg-surface hover:bg-neutral-50 active:scale-98'
                )}
              >
                <span className="text-body-lg font-extrabold text-[#b45309] leading-tight">
                  {String(underReviewCount).padStart(2, '0')}
                </span>
                <span className="mt-0.5 text-[11px] font-bold text-neutral-800 leading-tight">
                  Pending
                </span>
              </button>

              {/* Stage 2: Payment Due */}
              <button
                type="button"
                onClick={() => setActiveTab(activeTab === 'DEMAND_NOTE' ? 'ALL' : 'DEMAND_NOTE')}
                className={cn(
                  'flex flex-col items-center justify-center rounded-xl py-2.5 px-1 transition-all cursor-pointer border text-center',
                  activeTab === 'DEMAND_NOTE'
                    ? 'border-[#0f766e] bg-[#f0fdfa] ring-2 ring-[#0f766e]/25 shadow-xs'
                    : 'border-line bg-surface hover:bg-neutral-50 active:scale-98'
                )}
              >
                <span className="text-body-lg font-extrabold text-[#0f766e] leading-tight">
                  {String(demandNoteCount).padStart(2, '0')}
                </span>
                <span className="mt-0.5 text-[11px] font-bold text-neutral-800 leading-tight">
                  Payment Due
                </span>
              </button>

              {/* Stage 3: Approved / Permit Issued */}
              <button
                type="button"
                onClick={() => setActiveTab(activeTab === 'PERMIT_ISSUED' ? 'ALL' : 'PERMIT_ISSUED')}
                className={cn(
                  'flex flex-col items-center justify-center rounded-xl py-2.5 px-1 transition-all cursor-pointer border text-center',
                  activeTab === 'PERMIT_ISSUED'
                    ? 'border-success-600 bg-success-50 ring-2 ring-success-600/25 shadow-xs'
                    : 'border-line bg-surface hover:bg-neutral-50 active:scale-98'
                )}
              >
                <span className="text-body-lg font-extrabold text-[#15803d] leading-tight">
                  {String(permitIssuedCount).padStart(2, '0')}
                </span>
                <span className="mt-0.5 text-[11px] font-bold text-neutral-800 leading-tight">
                  Permit Ready
                </span>
              </button>

              {/* Stage 4: Rejected */}
              <button
                type="button"
                onClick={() => setActiveTab(activeTab === 'REJECTED' ? 'ALL' : 'REJECTED')}
                className={cn(
                  'flex flex-col items-center justify-center rounded-xl py-2.5 px-1 transition-all cursor-pointer border text-center',
                  activeTab === 'REJECTED'
                    ? 'border-danger-500 bg-danger-50 ring-2 ring-danger-500/25 shadow-xs'
                    : 'border-line bg-surface hover:bg-neutral-50 active:scale-98'
                )}
              >
                <span className="text-body-lg font-extrabold text-[#dc2626] leading-tight">
                  {String(rejectedCount).padStart(2, '0')}
                </span>
                <span className="mt-0.5 text-[11px] font-bold text-neutral-800 leading-tight">
                  Rejected
                </span>
              </button>
            </div>

            {/* Below the Data Cards: Small Themed Filter Pills */}
            <div className="flex items-center gap-2 border-t border-line pt-2.5 flex-wrap">
              {/* Pill 1: All */}
              <button
                type="button"
                onClick={() => setActiveTab('ALL')}
                className={cn(
                  'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold transition-all cursor-pointer whitespace-nowrap border',
                  activeTab === 'ALL'
                    ? 'bg-[#1241a6] text-white border-[#1241a6] shadow-xs'
                    : 'bg-surface text-ink-secondary border-line hover:bg-neutral-50 hover:text-ink'
                )}
              >
                <FileText size={12} className={activeTab === 'ALL' ? 'text-white' : 'text-[#1241a6]'} />
                <span>All ({totalCount})</span>
              </button>

              {/* Pill 2: Drafts */}
              <button
                type="button"
                onClick={() => setActiveTab(activeTab === 'DRAFTS' ? 'ALL' : 'DRAFTS')}
                className={cn(
                  'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold transition-all cursor-pointer whitespace-nowrap border',
                  activeTab === 'DRAFTS'
                    ? 'bg-[#1241a6] text-white border-[#1241a6] shadow-xs'
                    : 'bg-surface text-ink-secondary border-line hover:bg-neutral-50 hover:text-ink'
                )}
              >
                <Edit3 size={12} className={activeTab === 'DRAFTS' ? 'text-white' : 'text-[#b45309]'} />
                <span>Drafts ({draftCount})</span>
              </button>

              {/* Pill 3: Action Required */}
              <button
                type="button"
                onClick={() => setActiveTab(activeTab === 'ATTENTION' ? 'ALL' : 'ATTENTION')}
                className={cn(
                  'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold transition-all cursor-pointer whitespace-nowrap border',
                  activeTab === 'ATTENTION'
                    ? 'bg-[#1241a6] text-white border-[#1241a6] shadow-xs'
                    : 'bg-surface text-ink-secondary border-line hover:bg-neutral-50 hover:text-ink'
                )}
              >
                <AlertTriangle size={12} className={activeTab === 'ATTENTION' ? 'text-white' : 'text-[#b45309]'} />
                <span>Action Required ({attentionCount})</span>
              </button>
            </div>
          </div>

          {/* 3. Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-neutral-400" size={16} />
            <input
              type="text"
              placeholder="Search by application no, survey no, mineral, village..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-xl border border-neutral-200 bg-white py-2 pl-9 pr-4 text-body-sm text-ink placeholder-neutral-400 outline-none focus:border-primary-500 focus:ring-1 focus:ring-primary-500"
            />
          </div>

          {/* 4. Applications List with Status Stepper */}
          {filteredApplications.length === 0 ? (
            <EmptyState
              icon={<Shovel size={22} />}
              title="No applications found"
              description={
                searchQuery
                  ? 'No applications match your search query. Try clearing the filter.'
                  : activeTab === 'DRAFTS'
                  ? 'There are no active draft applications.'
                  : 'There are no excavation applications under this category.'
              }
            />
          ) : (
            <div className="space-y-3.5">
              {filteredApplications.map((app) => (
                <ApplicationCard
                  key={app.id}
                  application={app}
                  mineralTitle={mineralName(app.mineralId)}
                  onDeleteDraft={setDraftToDelete}
                  onClick={() =>
                    navigate(
                      app.status === 'DRAFT'
                        ? `${ROUTES.newExcavationApplication}?draftId=${app.id}`
                        : ROUTES.excavationApplication(app.id)
                    )
                  }
                />
              ))}
            </div>
          )}
        </div>
      )}

      {/* Resume Incomplete Application Modal when tapping + New application */}
      <ConfirmDialog
        open={showResumeModal}
        title="Resume Incomplete Application?"
        description={
          latestDraft
            ? `You have an unfinished application draft for ${mineralName(latestDraft.mineralId)} saved at Step ${(latestDraft.lastStepIndex ?? 0) + 1}: ${STEP_NAMES[latestDraft.lastStepIndex ?? 0] || 'In Progress'}. Would you like to resume where you left off or start a fresh application?`
            : 'You have an unfinished application draft. Would you like to resume where you left off?'
        }
        confirmLabel={`Resume Step ${(latestDraft?.lastStepIndex ?? 0) + 1}`}
        cancelLabel="Start Fresh"
        onConfirm={() => {
          setShowResumeModal(false);
          if (latestDraft) {
            navigate(`${ROUTES.newExcavationApplication}?draftId=${latestDraft.id}`);
          } else {
            navigate(ROUTES.newExcavationApplication);
          }
        }}
        onCancel={() => {
          setShowResumeModal(false);
          navigate(ROUTES.newExcavationApplication);
        }}
      />

      {/* Discard Draft Confirmation Dialog */}
      <ConfirmDialog
        open={draftToDelete !== null}
        title="Discard Incomplete Draft?"
        description="Are you sure you want to discard this application draft? All unsubmitted changes will be permanently deleted."
        confirmLabel="Discard Draft"
        cancelLabel="Keep Draft"
        destructive
        onConfirm={handleConfirmDeleteDraft}
        onCancel={() => setDraftToDelete(null)}
      />
    </Screen>
  );
}

/**
 * Modern Application Card with embedded multi-stage progress bar and clear status handling
 */
function ApplicationCard({
  application,
  mineralTitle,
  onClick,
  onDeleteDraft,
}: {
  application: TemporaryExcavationApplication;
  mineralTitle: string;
  onClick: () => void;
  onDeleteDraft?: (id: string) => void;
}) {
  const navigate = useNavigate();
  const status = statusPresentation.temporaryExcavation(application.status);

  // Derive stage brief for clean concise preview on card
  let stageBrief = {
    title: 'Stage 1: Application Submitted',
    description: 'Application fee of ₹520 paid. Ready for departmental review.',
  };

  if (application.status === 'DRAFT') {
    const stepName = STEP_NAMES[application.lastStepIndex ?? 0] || 'Applicant Details';
    stageBrief = {
      title: `Draft Saved · Step ${(application.lastStepIndex ?? 0) + 1} of 5`,
      description: `In-progress draft. Ready to resume at Step ${(application.lastStepIndex ?? 0) + 1}: ${stepName}.`,
    };
  } else if (application.status === 'UNDER_REVIEW') {
    stageBrief = {
      title: 'Stage 2: Under Department Review',
      description: 'Site boundary inspection and verification in progress by Revenue Officer.',
    };
  } else if (application.status === 'QUERY_RAISED') {
    stageBrief = {
      title: 'Stage 2: Action Required',
      description: application.statusRemarks || 'Revised survey plan or boundary clarification requested.',
    };
  } else if (application.status === 'DEMAND_NOTE_ISSUED') {
    stageBrief = {
      title: 'Stage 3: Demand Note Issued',
      description: `Royalty calculation complete. Challan payment of ${formatMoney(application.demandNote?.totalAmount || { amount: 268800, currency: 'INR' })} due.`,
    };
  } else if (application.status === 'ORDER_ISSUED') {
    stageBrief = {
      title: 'Stage 4: Permit Granted',
      description: 'Official excavation order issued. Transport permits & DigiTP authorized.',
    };
  } else if (application.status === 'REJECTED') {
    stageBrief = {
      title: 'Application Rejected',
      description: application.statusRemarks || 'Application proposal rejected by Revenue Officer due to site buffer restrictions or document discrepancies.',
    };
  }

  const isRejected = application.status === 'REJECTED';

  return (
    <div
      onClick={onClick}
      className={cn(
        'cursor-pointer rounded-2xl border p-4 shadow-xs transition-all active:scale-[0.99]',
        isRejected
          ? 'border-danger-200 bg-white hover:border-danger-500 hover:shadow-md'
          : application.status === 'DRAFT'
          ? 'border-warning-200 bg-white hover:border-warning-500 hover:shadow-md'
          : 'border-line bg-white hover:border-primary-400 hover:shadow-md'
      )}
    >
      {/* Header: App Number & Status Badge */}
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center gap-1.5">
          <span
            className={cn(
              'flex size-6 items-center justify-center rounded-md',
              isRejected
                ? 'bg-danger-50 text-danger-600'
                : application.status === 'DRAFT'
                ? 'bg-warning-50 text-warning-700'
                : 'bg-[#eef4fe] text-[#1241a6]'
            )}
          >
            {isRejected ? <FileX size={14} /> : application.status === 'DRAFT' ? <Edit3 size={14} /> : <FileText size={14} />}
          </span>
          <span className="font-mono text-body-sm font-bold text-ink">
            {application.applicationNumber}
          </span>
        </div>
        <div className="flex items-center gap-2">
          {application.status === 'DRAFT' && onDeleteDraft && (
            <button
              type="button"
              className="text-[11px] font-semibold text-neutral-400 hover:text-danger-600 transition-colors cursor-pointer px-1"
              onClick={(e) => {
                e.stopPropagation();
                onDeleteDraft(application.id);
              }}
              title="Discard draft"
            >
              Discard
            </button>
          )}
          <StatusBadge label={status.label} tone={status.tone} size="sm" />
        </div>
      </div>

      {/* Mineral & Quantity */}
      <div className="mt-2.5 flex items-baseline justify-between rounded-xl bg-neutral-50 px-3 py-2 text-caption">
        <div>
          <span className="text-neutral-500">Mineral: </span>
          <span className="font-semibold text-ink">{mineralTitle}</span>
        </div>
        <div>
          <span className="text-neutral-500">Volume: </span>
          <span className="tabular font-bold text-ink">
            {formatQuantity(application.estimatedQuantity)}
          </span>
        </div>
      </div>

      {/* Land & Site Location */}
      <div className="mt-2 space-y-1 text-caption text-neutral-600">
        <div className="flex items-center gap-1.5">
          <MapPin size={13} className="text-neutral-400 shrink-0" />
          <span className="truncate">
            Survey No. <strong>{application.surveyNumber}</strong>, {application.village}, {application.siteAddress.taluka}
          </span>
        </div>
      </div>

      {/* Concise Stage / Rejection Box */}
      <div
        className={cn(
          'mt-3 rounded-xl border p-2.5',
          isRejected
            ? 'border-danger-200 bg-danger-50/60'
            : application.status === 'DRAFT'
            ? 'border-warning-200 bg-warning-50/60'
            : 'border-line bg-canvas'
        )}
      >
        <div className="flex items-center justify-between">
          <span
            className={cn(
              'text-[11px] font-bold uppercase tracking-wider',
              isRejected ? 'text-danger-700' : application.status === 'DRAFT' ? 'text-warning-700' : 'text-neutral-500'
            )}
          >
            {isRejected ? 'Rejection Reason' : application.status === 'DRAFT' ? 'Draft Progress' : 'Current Stage'}
          </span>
          <span
            className={cn(
              'text-[11px] font-bold',
              isRejected
                ? 'text-danger-700'
                : application.status === 'ORDER_ISSUED'
                ? 'text-success-700'
                : application.status === 'DEMAND_NOTE_ISSUED'
                ? 'text-[#0f766e]'
                : application.status === 'QUERY_RAISED'
                ? 'text-warning-700'
                : application.status === 'DRAFT'
                ? 'text-warning-700'
                : 'text-[#1241a6]'
            )}
          >
            {stageBrief.title}
          </span>
        </div>
        <p
          className={cn(
            'mt-1 text-[12px] leading-snug',
            isRejected ? 'text-danger-700 font-medium' : 'text-neutral-600'
          )}
        >
          {isRejected ? `"${stageBrief.description}"` : stageBrief.description}
        </p>
      </div>

      {/* Action footer button / pill */}
      <div className="mt-3.5 flex items-center justify-between pt-2 border-t border-line">
        <span className="text-[11px] text-neutral-400">
          Updated: {application.statusUpdatedAt ? new Date(application.statusUpdatedAt).toLocaleDateString('en-IN') : 'Recent'}
        </span>

        <div className="flex items-center gap-1.5">
          {isRejected ? (
            <button
              type="button"
              className="inline-flex items-center gap-1.5 rounded-lg bg-[#dc2626] hover:bg-[#b91c1c] text-white px-3 py-1.5 text-[11px] font-bold shadow-xs transition-all active:scale-95 cursor-pointer"
              onClick={(e) => {
                e.stopPropagation();
                navigate(`${ROUTES.newExcavationApplication}?draftId=${application.id}&resubmit=true`);
              }}
            >
              <Edit3 size={12} className="text-white" />
              <span className="text-white">Edit & Re-submit Proposal</span>
              <ArrowRight size={12} className="text-white" />
            </button>
          ) : application.status === 'DRAFT' ? (
            <button
              type="button"
              className="inline-flex items-center gap-1.5 rounded-lg bg-[#1241a6] hover:bg-[#0f3484] text-white px-3 py-1.5 text-[11px] font-bold shadow-xs transition-all active:scale-95 cursor-pointer"
              onClick={(e) => {
                e.stopPropagation();
                navigate(`${ROUTES.newExcavationApplication}?draftId=${application.id}`);
              }}
            >
              <Edit3 size={12} className="text-white" />
              <span className="text-white">Resume Application</span>
              <ArrowRight size={12} className="text-white" />
            </button>
          ) : hasExcavationOrder(application) ? (
            <span className="inline-flex items-center gap-1 text-[11px] font-bold text-[#15803d] bg-[#dcfce7] px-2.5 py-1 rounded-lg border border-[#86efac]">
              <Download size={12} />
              <span>Permit Ready (Ordnrno-04/08/2026-1)</span>
            </span>
          ) : awaitsDemandNotePayment(application) && application.demandNote ? (
            <button
              type="button"
              style={{ backgroundColor: '#15803d', color: '#ffffff' }}
              className="inline-flex items-center gap-1 rounded-lg py-1 px-3 text-[11px] font-bold text-white shadow-xs transition-all active:scale-95 cursor-pointer"
              onClick={(e) => {
                e.stopPropagation();
                navigate(ROUTES.applicationPayment(application.id, 'demand-note'));
              }}
            >
              <IndianRupee size={12} className="text-white" />
              <span className="text-white">Pay Demand Note ({formatMoney(application.demandNote.totalAmount)})</span>
            </button>
          ) : needsApplicantResponse(application) ? (
            <span className="inline-flex items-center gap-1 text-[11px] font-bold text-warning-700 bg-warning-50 px-2.5 py-1 rounded-lg border border-warning-200">
              <AlertTriangle size={12} />
              <span>Respond to Query</span>
            </span>
          ) : (
            <span className="inline-flex items-center gap-1 text-[11px] font-bold text-primary-700 hover:text-primary-900">
              <span>View Details</span>
              <ArrowRight size={12} />
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

