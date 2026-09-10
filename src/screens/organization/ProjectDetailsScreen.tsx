import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Boxes,
  Building2,
  ChevronDown,
  FileText,
  MapPin,
} from 'lucide-react';
import { statusPresentation } from '@/rules';
import {
  EmptyState,
  ErrorState,
  ListGroup,
  ListRow,
  LoadingState,
  MetricTile,
  SectionHeader,
  StatusBadge,
  Surface,
  cn,
} from '@/design-system';
import { ROUTES, Screen } from '@/navigation';
import {
  orderRepository,
  packageRepository,
  projectRepository,
  useAsync,
} from '@/data';
import { useOrganizationContextStore } from '@/state';
import { useCopy } from '@/content';
import { ProjectActionFAB } from './ProjectActionFAB';

export function ProjectDetailsScreen() {
  const { projectId } = useParams<{ projectId: string }>();
  const navigate = useNavigate();
  const setProject = useOrganizationContextStore((state) => state.setProject);
  const t = useCopy();
  const [showDetails, setShowDetails] = useState(false);

  const query = useAsync(async () => {
    if (!projectId) throw new Error('A project is required');

    const project = await projectRepository.getById(projectId);
    if (!project) throw new Error('Project not found');

    const [packages, orders] = await Promise.all([
      packageRepository.listByProject(projectId),
      orderRepository.list({ projectId }),
    ]);

    return { project, packages, orders };
  }, [projectId]);

  const project = query.data?.project;

  useEffect(() => {
    if (project) setProject(project);
  }, [project, setProject]);

  const totalPackages = query.data?.packages.length ?? 0;
  const activePackages = query.data?.packages.filter((pkg) => pkg.status === 'ACTIVE').length ?? 0;

  // Determine location type
  const isLinear =
    project?.location.line1.toLowerCase().includes('km') ||
    project?.location.line1.toLowerCase().includes('corridor') ||
    project?.location.line1.toLowerCase().includes('highway') ||
    project?.name.toLowerCase().includes('highway') ||
    project?.name.toLowerCase().includes('line');

  return (
    <Screen
      title={project?.name ?? t.projects.projectDetails}
      {...(project ? { subtitle: project.code } : {})}
      onBack
      floatingAction={project ? <ProjectActionFAB projectId={project.id} mode="project-details" /> : undefined}
    >
      {query.loading && <LoadingState variant="list" rows={4} />}
      {query.error && <ErrorState onRetry={query.reload} />}

      {query.data && project && (
        <div className="pb-8 space-y-4">
          {/* Compact Project Header Overview */}
          <Surface className="border-b border-line p-3.5 space-y-3">
            {/* Status & Categorisation Badges */}
            <div className="flex flex-wrap items-center gap-1.5">
              <StatusBadge {...statusPresentation.project(project.status)} />
              
              {project.projectType && (
                <span className="inline-flex items-center gap-1 rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-semibold text-blue-700 border border-blue-200">
                  <Building2 size={12} />
                  {project.projectType === 'GOVERNMENT' ? 'Govt Project' : 'Private'}
                </span>
              )}

              <span className="inline-flex items-center gap-1 rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium text-slate-700 border border-slate-200">
                {isLinear ? 'Linear Corridor' : 'Stationary Site'}
                {project.category ? ` · ${project.category === 'URBAN' ? 'Urban' : 'Rural'}` : ''}
              </span>
            </div>

            {/* Location Line */}
            <div className="flex items-start gap-1.5 text-body-sm text-ink-secondary">
              <MapPin size={15} className="mt-0.5 shrink-0 text-ink-muted" aria-hidden />
              <div className="leading-snug">
                <span className="font-semibold text-ink">{project.location.line1}</span>
                <span className="block text-caption text-ink-muted">
                  {project.location.taluka}, {project.location.district}, {project.location.state} — {project.location.pincode}
                </span>
              </div>
            </div>

            {/* Collapsible Work Order & Department Info Drawer */}
            {(project.department || project.officeName || project.workOrderNumber) && (
              <div className="pt-1">
                <button
                  type="button"
                  onClick={() => setShowDetails((prev) => !prev)}
                  className="flex w-full items-center justify-between rounded-xl bg-slate-50 hover:bg-slate-100 border border-slate-200/80 px-3 py-2 text-xs text-ink-secondary transition-all cursor-pointer"
                >
                  <div className="flex items-center gap-2 truncate">
                    <FileText size={13} className="text-blue-600 shrink-0" />
                    <span className="font-semibold text-ink truncate">
                      {project.workOrderNumber ? `Work Order: ${project.workOrderNumber}` : project.department}
                    </span>
                  </div>
                  <div className="flex items-center gap-1 text-[11px] font-bold text-blue-700 shrink-0">
                    <span>{showDetails ? 'Hide Info' : 'Authority & WO'}</span>
                    <ChevronDown
                      size={14}
                      className={cn('transition-transform duration-200', showDetails && 'rotate-180')}
                    />
                  </div>
                </button>

                {showDetails && (
                  <div className="mt-1.5 rounded-xl border border-slate-200 bg-slate-50/70 p-3 text-xs space-y-2 animate-in fade-in duration-150">
                    {project.department && (
                      <div className="flex items-center justify-between">
                        <span className="text-neutral-500 font-medium">Dept / Authority:</span>
                        <span className="font-bold text-ink">{project.department}</span>
                      </div>
                    )}
                    {project.officeName && (
                      <div className="flex items-center justify-between">
                        <span className="text-neutral-500 font-medium">Office Division:</span>
                        <span className="font-bold text-ink">{project.officeName}</span>
                      </div>
                    )}
                    {project.workOrderNumber && (
                      <div className="flex items-center justify-between">
                        <span className="text-neutral-500 font-medium">Work Order No:</span>
                        <span className="font-mono font-bold text-blue-700">{project.workOrderNumber}</span>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}

            {/* Clean Operational Package Metrics */}
            <div className="grid grid-cols-3 gap-2 border-t border-line pt-2.5">
              <MetricTile
                label="Packages"
                value={String(totalPackages).padStart(2, '0')}
                unit="Total"
              />
              <MetricTile
                label="Active Scope"
                value={String(activePackages).padStart(2, '0')}
                unit="Operational"
              />
              <MetricTile
                label="Requisitions"
                value={String(query.data.orders.length).padStart(2, '0')}
                unit="Orders"
              />
            </div>
          </Surface>

          {/* Packages List Section */}
          <div>
            <SectionHeader
              title={t.projects.packages}
              action={
                <span className="text-caption font-semibold text-ink-muted">
                  {activePackages} Active of {totalPackages} Total
                </span>
              }
            />

            {query.data.packages.length === 0 ? (
              <EmptyState
                icon={<Boxes size={22} />}
                title={t.projects.noPackages}
                description={t.projects.noPackagesBody}
                action={
                  <button
                    type="button"
                    onClick={() => navigate(ROUTES.createPackage(project.id))}
                    className="inline-flex items-center gap-1.5 rounded-xl bg-primary-600 px-4 py-2 text-caption font-bold text-white shadow-xs hover:bg-primary-700"
                  >
                    Create First Package
                  </button>
                }
              />
            ) : (
              <ListGroup className="border-y border-line">
                {query.data.packages.map((pkg) => (
                  <ListRow
                    key={pkg.id}
                    leading={<Boxes size={17} />}
                    leadingTone={pkg.status === 'ACTIVE' ? 'primary' : 'neutral'}
                    title={pkg.name}
                    subtitle={`${pkg.siteAddress.taluka}, ${pkg.siteAddress.district}`}
                    detail={pkg.code}
                    meta={<StatusBadge {...statusPresentation.package(pkg.status)} size="sm" />}
                    onClick={() => navigate(ROUTES.packageDetails(project.id, pkg.id))}
                  />
                ))}
              </ListGroup>
            )}
          </div>
        </div>
      )}
    </Screen>
  );
}
