import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { CheckCircle2, Info } from 'lucide-react';
import type { ID } from '@/domain';
import { enquiryScopeFor, formatQuantity } from '@/rules';
import {
  Button,
  ErrorState,
  Input,
  LoadingState,
  QuantityInput,
  SectionHeader,
  Select,
  Surface,
  Textarea,
  cn,
} from '@/design-system';
import { OrganizationContextBar, ROUTES, Screen } from '@/navigation';
import {
  enquiryRepository,
  mineralRepository,
  packageRepository,
  projectRepository,
  stockPointRepository,
  useAsync,
} from '@/data';
import { useCurrentUser, useOperatingContext } from '@/state';
import { useCopy } from '@/content';
import { useDevQuickFill } from '@/prototype';

interface MineralSelection {
  selected: boolean;
  quantity: number | null;
}

/**
 * MINERAL ENQUIRY — state requirement for one or MULTIPLE minerals against a chosen source.
 */
export function CreateEnquiryScreen() {
  const { stockPointId } = useParams<{ stockPointId: string }>();
  const context = useOperatingContext();
  const currentUser = useCurrentUser();
  const navigate = useNavigate();
  const t = useCopy();

  const [selectedMinerals, setSelectedMinerals] = useState<Record<ID, MineralSelection>>({});
  const [contactName, setContactName] = useState(currentUser?.fullName ?? '');
  const [contactMobileNumber, setContactMobileNumber] = useState(currentUser?.mobileNumber ?? '');
  const [selectedProjectId, setSelectedProjectId] = useState<ID | ''>(context?.projectId ?? '');
  const [selectedPackageId, setSelectedPackageId] = useState<ID | ''>(context?.packageId ?? '');
  const [requiredByDate, setRequiredByDate] = useState('');
  const [remarks, setRemarks] = useState('');
  const [mineralErrors, setMineralErrors] = useState<Record<ID, string>>({});
  const [generalError, setGeneralError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [submittedCount, setSubmittedCount] = useState<number | null>(null);

  const query = useAsync(async () => {
    if (!stockPointId) throw new Error('A mineral place is required');

    const [stockPoint, minerals] = await Promise.all([
      stockPointRepository.getById(stockPointId),
      mineralRepository.listAll(),
    ]);
    if (!stockPoint) throw new Error('Mineral place not found');

    let projects: { id: ID; name: string; materialIds?: ID[] }[] = [];
    let packages: { id: ID; name: string; projectId: ID }[] = [];

    if (context?.userType === 'ORGANIZATION' && context.organizationId) {
      const [orgProjects, orgPackages] = await Promise.all([
        projectRepository.listByOrganization(context.organizationId),
        packageRepository.listByOrganization(context.organizationId),
      ]);
      projects = orgProjects.map((project) => ({
        id: project.id,
        name: project.name,
        materialIds: project.materialIds,
      }));
      packages = orgPackages.map((pkg) => ({ id: pkg.id, name: pkg.name, projectId: pkg.projectId }));
    }

    if (context?.userType === 'NORMAL_CONSUMER') {
      const consumerProjects = await projectRepository.listForConsumer(context.userId);
      projects = consumerProjects.map((project) => ({
        id: project.id,
        name: project.name,
        materialIds: project.materialIds,
      }));
    }

    return { stockPoint, minerals, projects, packages };
  }, [stockPointId, context?.organizationId, context?.projectId, context?.packageId, context?.userId, context?.userType]);

  const stockPoint = query.data?.stockPoint;
  const minerals = query.data?.minerals ?? [];
  const projects = query.data?.projects ?? [];
  const packages = query.data?.packages ?? [];

  useEffect(() => {
    if (!contactName && currentUser?.fullName) setContactName(currentUser.fullName);
    if (!contactMobileNumber && currentUser?.mobileNumber) setContactMobileNumber(currentUser.mobileNumber);
  }, [contactName, contactMobileNumber, currentUser?.fullName, currentUser?.mobileNumber]);

  useEffect(() => {
    if (context?.projectId && !selectedProjectId) setSelectedProjectId(context.projectId);
    if (context?.packageId && !selectedPackageId) setSelectedPackageId(context.packageId);
  }, [context?.projectId, context?.packageId, selectedProjectId, selectedPackageId]);

  useEffect(() => {
    if (selectedProjectId && selectedPackageId) {
      const packageIsValid = packages.some(
        (pkg) => pkg.id === selectedPackageId && pkg.projectId === selectedProjectId,
      );
      if (!packageIsValid) setSelectedPackageId('');
    }
  }, [packages, selectedPackageId, selectedProjectId]);

  // Initialize mineral selections when stock point minerals are loaded or project changes
  useEffect(() => {
    if (!stockPoint?.minerals || stockPoint.minerals.length === 0) return;

    const project = projects.find((item) => item.id === selectedProjectId);
    const preferredIds = project?.materialIds ?? [];

    setSelectedMinerals((prev) => {
      const initial: Record<ID, MineralSelection> = { ...prev };
      stockPoint.minerals.forEach((holding, index) => {
        if (!initial[holding.mineralId]) {
          const isPreferred = preferredIds.length > 0
            ? preferredIds.includes(holding.mineralId)
            : index === 0;
          initial[holding.mineralId] = {
            selected: isPreferred,
            quantity: isPreferred ? (holding.availableQuantity.value > 0 ? 100 : null) : null,
          };
        }
      });
      return initial;
    });
  }, [stockPoint?.minerals, selectedProjectId, projects]);

  const projectOptions = projects.map((project) => ({ value: project.id, label: project.name }));
  const packageOptions = (selectedProjectId
    ? packages.filter((pkg) => pkg.projectId === selectedProjectId)
    : packages
  ).map((pkg) => ({ value: pkg.id, label: pkg.name }));

  const activeSelectedEntries = Object.entries(selectedMinerals).filter(
    ([, val]) => val.selected,
  );

  function toggleMineral(mineralId: ID) {
    setSelectedMinerals((prev) => {
      const current = prev[mineralId];
      const isNowSelected = !current?.selected;
      return {
        ...prev,
        [mineralId]: {
          selected: isNowSelected,
          quantity: isNowSelected ? (current?.quantity ?? 100) : current?.quantity ?? null,
        },
      };
    });
    setMineralErrors((prev) => {
      const copy = { ...prev };
      delete copy[mineralId];
      return copy;
    });
    setGeneralError(null);
  }

  function updateQuantity(mineralId: ID, quantity: number | null) {
    setSelectedMinerals((prev) => ({
      ...prev,
      [mineralId]: {
        selected: true,
        quantity,
      },
    }));
    setMineralErrors((prev) => {
      const copy = { ...prev };
      delete copy[mineralId];
      return copy;
    });
    setGeneralError(null);
  }

  function handleQuickFill() {
    if (stockPoint?.minerals && stockPoint.minerals.length > 0) {
      const fill: Record<ID, MineralSelection> = {};
      stockPoint.minerals.forEach((holding, idx) => {
        fill[holding.mineralId] = {
          selected: true,
          quantity: holding.availableQuantity.value > 0 ? (idx === 0 ? 150 : 50) : 100,
        };
      });
      setSelectedMinerals(fill);
    }
    setContactName(currentUser?.fullName || 'Rajesh Patil');
    setContactMobileNumber(currentUser?.mobileNumber || '9822014576');
    setRequiredByDate(new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10));
    setRemarks('Urgent supply required for structural concrete casting work. Please confirm vehicle dispatch timeline.');
    if (projects.length > 0 && !selectedProjectId) {
      setSelectedProjectId(projects[0].id);
    }
    if (packages.length > 0 && !selectedPackageId) {
      setSelectedPackageId(packages[0].id);
    }
    setMineralErrors({});
    setGeneralError(null);
  }

  useDevQuickFill(handleQuickFill);

  async function handleSubmit() {
    if (!context || !stockPoint) return;

    if (activeSelectedEntries.length === 0) {
      setGeneralError('Please select at least one mineral requirement to enquire.');
      return;
    }

    const nextErrors: Record<ID, string> = {};
    activeSelectedEntries.forEach(([minId, val]) => {
      if (val.quantity === null || val.quantity <= 0) {
        nextErrors[minId] = 'Enter a valid quantity greater than 0.';
      }
    });

    if (Object.keys(nextErrors).length > 0) {
      setMineralErrors(nextErrors);
      setGeneralError('Please enter quantities for all selected minerals.');
      return;
    }

    setSubmitting(true);
    setGeneralError(null);

    try {
      const scope = enquiryScopeFor({
        userType: context.userType,
        organizationId: context.organizationId,
        projectId: selectedProjectId || context.projectId,
        packageId: selectedPackageId || context.packageId,
      });

      await Promise.all(
        activeSelectedEntries.map(([minId, val]) => {
          const holding = stockPoint.minerals.find((m) => m.mineralId === minId);
          const unit = holding?.availableQuantity?.unit ?? 'MT';
          return enquiryRepository.create({
            raisedByUserId: context.userId,
            raisedByUserType: context.userType,
            ...scope,
            stockPointId: stockPoint.id,
            mineralId: minId,
            requiredQuantity: { value: val.quantity!, unit },
            ...(requiredByDate ? { requiredByDate } : {}),
            ...(contactName.trim() ? { contactName: contactName.trim() } : {}),
            ...(contactMobileNumber.trim() ? { contactMobileNumber: contactMobileNumber.trim() } : {}),
            ...(remarks.trim() ? { remarks: remarks.trim() } : {}),
          });
        }),
      );

      setSubmittedCount(activeSelectedEntries.length);
    } finally {
      setSubmitting(false);
    }
  }

  if (submittedCount !== null) {
    return (
      <Screen title={t.enquiry.sentTitle}>
        <div className="flex flex-col items-center px-8 py-16 text-center">
          <span className="mb-4 flex size-14 items-center justify-center rounded-full bg-success-50 text-success-600">
            <CheckCircle2 size={28} aria-hidden />
          </span>
          <h2 className="text-title-lg text-ink">{t.enquiry.sentTitle}</h2>
          <p className="mt-2 max-w-[34ch] text-body text-ink-secondary">
            Enquiries for <span className="font-bold text-ink">{submittedCount} mineral{submittedCount > 1 ? 's' : ''}</span> have been sent to{' '}
            <span className="font-semibold text-ink">{stockPoint?.name}</span>. You can track progress in Activity.
          </p>

          <div className="mt-8 w-full space-y-3">
            <Button
              size="lg"
              fullWidth
              onClick={() => navigate(`${ROUTES.activity}?tab=enquiries`, { replace: true })}
            >
              View in Activity
            </Button>
            <Button
              size="lg"
              variant="secondary"
              fullWidth
              onClick={() => navigate(ROUTES.home, { replace: true })}
            >
              {t.nav.home}
            </Button>
          </div>
        </div>
      </Screen>
    );
  }

  return (
    <Screen
      title={t.enquiry.title}
      {...(stockPoint ? { subtitle: stockPoint.name } : {})}
      onBack
      context={<OrganizationContextBar showChange={false} />}
      footer={
        <Button size="lg" fullWidth loading={submitting} onClick={handleSubmit}>
          {submitting
            ? t.enquiry.submitting
            : activeSelectedEntries.length > 1
            ? `Send Enquiry (${activeSelectedEntries.length} Minerals)`
            : t.enquiry.submit}
        </Button>
      }
    >
      {query.loading && <LoadingState variant="list" rows={3} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {query.data && stockPoint && (
        <div className="pb-6">
          <SectionHeader title={t.enquiry.requirement} />

          <Surface className="border-y border-line px-4 py-4">
            <div className="space-y-4">
              {projectOptions.length > 0 && (
                <Select
                  label={context?.userType === 'ORGANIZATION' ? 'Project' : 'Project for this enquiry'}
                  placeholder="Select a project"
                  value={selectedProjectId}
                  options={projectOptions}
                  onChange={(event) => {
                    const nextProjectId = event.target.value;
                    setSelectedProjectId(nextProjectId);
                    setSelectedPackageId('');
                  }}
                />
              )}

              {context?.userType === 'ORGANIZATION' && packageOptions.length > 0 && (
                <Select
                  label="Package"
                  placeholder="Select a package"
                  value={selectedPackageId}
                  options={packageOptions}
                  onChange={(event) => setSelectedPackageId(event.target.value)}
                />
              )}

              {context?.userType === 'NORMAL_CONSUMER' && projectOptions.length === 0 && (
                <Button
                  variant="secondary"
                  fullWidth
                  onClick={() => navigate(ROUTES.consumerProjectRegistration)}
                >
                  Register a project first
                </Button>
              )}

              {/* Multi-Mineral Requirements Selection */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="text-label font-bold text-ink">
                    Select Minerals & Quantities <span className="text-danger-500">*</span>
                  </label>
                  <span className="text-[11.5px] font-semibold text-ink-muted">
                    {activeSelectedEntries.length} selected
                  </span>
                </div>

                <div className="space-y-3">
                  {(stockPoint.minerals ?? []).map((holding) => {
                    const minMeta = minerals.find((m) => m.id === holding.mineralId);
                    const name = minMeta?.name ?? 'Mineral';
                    const available = holding.availableQuantity;
                    const selection = selectedMinerals[holding.mineralId] ?? {
                      selected: false,
                      quantity: null,
                    };
                    const isSelected = selection.selected;
                    const hasError = mineralErrors[holding.mineralId];
                    const isOverAvailable =
                      isSelected &&
                      selection.quantity !== null &&
                      selection.quantity > available.value;

                    return (
                      <div
                        key={holding.mineralId}
                        className={cn(
                          'rounded-xl border p-3 transition-all space-y-2.5',
                          isSelected
                            ? 'border-primary-500 bg-primary-50/40 ring-1 ring-primary-300/60'
                            : 'border-line bg-surface hover:border-neutral-300'
                        )}
                      >
                        <div
                          className="flex items-center justify-between cursor-pointer"
                          onClick={() => toggleMineral(holding.mineralId)}
                        >
                          <div className="flex items-center gap-2.5 min-w-0">
                            <input
                              type="checkbox"
                              checked={isSelected}
                              onChange={() => toggleMineral(holding.mineralId)}
                              onClick={(e) => e.stopPropagation()}
                              className="size-4 rounded text-primary-600 accent-primary-600 shrink-0"
                            />
                            <div className="min-w-0">
                              <p className="text-body-sm font-semibold text-ink truncate">
                                {name}
                              </p>
                              <p className="text-[11px] text-ink-muted">
                                Unit: {available.unit}
                              </p>
                            </div>
                          </div>

                          <span
                            className={cn(
                              'text-[11px] font-semibold px-2 py-0.5 rounded-full shrink-0 tabular',
                              available.value > 0
                                ? 'bg-emerald-100 text-emerald-800'
                                : 'bg-neutral-100 text-neutral-600'
                            )}
                          >
                            {available.value > 0
                              ? `${formatQuantity(available)} available`
                              : 'Out of stock'}
                          </span>
                        </div>

                        {isSelected && (
                          <div className="pt-1.5 border-t border-line/60">
                            <QuantityInput
                              label="Required Quantity"
                              required
                              value={selection.quantity}
                              unit={available.unit}
                              onChange={(val) => updateQuantity(holding.mineralId, val)}
                              {...(hasError ? { error: hasError } : {})}
                              {...(available.value > 0 && !hasError
                                ? { hint: `${formatQuantity(available)} currently in stock at site` }
                                : {})}
                            />

                            {isOverAvailable && (
                              <p className="mt-1.5 flex items-start gap-1.5 text-[11.5px] text-amber-700 bg-amber-50/80 p-2 rounded-lg border border-amber-200">
                                <Info size={13} className="mt-0.5 shrink-0" />
                                <span>
                                  Exceeds currently available stock ({formatQuantity(available)}). The mineral place will review replenishment.
                                </span>
                              </p>
                            )}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>

                {generalError && (
                  <p className="mt-2 text-caption text-danger-600 font-medium">
                    {generalError}
                  </p>
                )}
              </div>

              <Input
                label={t.enquiry.requiredBy}
                type="date"
                hint={t.enquiry.requiredByHint}
                value={requiredByDate}
                onChange={(event) => setRequiredByDate(event.target.value)}
              />

              <div className="space-y-4 rounded-lg border border-line bg-surface-subtle p-3">
                <Input
                  label="Contact name"
                  placeholder="Enter your name"
                  value={contactName}
                  onChange={(event) => setContactName(event.target.value)}
                />
                <Input
                  label="Contact mobile"
                  placeholder="Enter your mobile number"
                  value={contactMobileNumber}
                  onChange={(event) => setContactMobileNumber(event.target.value)}
                />
              </div>

              <Textarea
                label={t.enquiry.remarks}
                placeholder={t.enquiry.remarksPlaceholder}
                value={remarks}
                onChange={(event) => setRemarks(event.target.value)}
              />
            </div>
          </Surface>
        </div>
      )}
    </Screen>
  );
}
