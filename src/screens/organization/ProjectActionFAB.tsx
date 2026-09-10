import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ChevronRight, Plus, X } from 'lucide-react';
import { ROUTES } from '@/navigation';
import { cn } from '@/design-system';

export interface ProjectActionFABProps {
  projectId?: string;
  packageId?: string;
  mode?: 'project' | 'project-details' | 'package';
  className?: string;
}

/**
 * Universal Speed Dial Floating Action Button for the Project & Package Operational Flow.
 * - In Package Mode: Displays 3 options (Find Mineral Places, Receive Mineral, Transfer Stock)
 * - In Project Details / Package Screen Mode: Displays only the Create Package option
 * - In Projects List Mode: Displays only the Create Project option
 */
export function ProjectActionFAB({
  projectId: propProjectId,
  packageId: propPackageId,
  mode: propMode,
  className,
}: ProjectActionFABProps) {
  const [isOpen, setIsOpen] = useState(false);
  const navigate = useNavigate();
  const routeParams = useParams<{ projectId?: string; packageId?: string }>();
  const activeProjectId = propProjectId || routeParams.projectId || 'proj-001';

  const effectiveMode =
    propMode ||
    (Boolean(propPackageId || routeParams.packageId)
      ? 'package'
      : Boolean(propProjectId || routeParams.projectId)
        ? 'project-details'
        : 'project');

  const packageActionItems = [
    {
      id: 'find-mineral-places',
      title: 'Find Mineral Places',
      onClick: () => navigate(ROUTES.stockPoints),
    },
    {
      id: 'receive-mineral',
      title: 'Receive Mineral',
      onClick: () => navigate(ROUTES.receive),
    },
    {
      id: 'transfer-stock',
      title: 'Transfer Stock',
      onClick: () => navigate(ROUTES.transfers),
    },
  ];

  const projectDetailsActionItems = [
    {
      id: 'create-package',
      title: 'Create New Package',
      onClick: () => navigate(ROUTES.createPackage(activeProjectId)),
    },
  ];

  const projectActionItems = [
    {
      id: 'create-project',
      title: 'Create Project',
      onClick: () => navigate(ROUTES.createProject),
    },
  ];

  const actionItems =
    effectiveMode === 'package'
      ? packageActionItems
      : effectiveMode === 'project-details'
        ? projectDetailsActionItems
        : projectActionItems;

  return (
    <>
      {/* Backdrop overlay when open */}
      {isOpen && (
        <div
          onClick={() => setIsOpen(false)}
          className="fixed inset-0 z-40 bg-slate-950/40 backdrop-blur-[2px] transition-opacity animate-in fade-in duration-200"
          aria-hidden="true"
        />
      )}

      {/* FAB Container */}
      <div className={cn('absolute bottom-5 right-4 z-50 pointer-events-auto', className)}>
        {/* Speed Dial Menu Popover */}
        {isOpen && (
          <div
            className="absolute bottom-16 right-0 w-[210px] rounded-2xl border border-neutral-200/90 bg-white p-1.5 shadow-2xl animate-in fade-in slide-in-from-bottom-5 duration-200"
            role="menu"
            aria-label="Actions menu"
          >
            <div className="space-y-0.5">
              {actionItems.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => {
                    setIsOpen(false);
                    item.onClick();
                  }}
                  className="group flex w-full items-center justify-between rounded-xl px-3 py-2.5 text-left text-body-sm font-semibold text-ink hover:bg-neutral-100 hover:text-primary-700 active:bg-neutral-200 transition-colors cursor-pointer"
                  role="menuitem"
                >
                  <span>{item.title}</span>
                  <ChevronRight
                    size={14}
                    className="text-neutral-400 transition-transform group-hover:translate-x-0.5 group-hover:text-primary-600 shrink-0"
                  />
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Primary Floating Action Button */}
        <button
          type="button"
          onClick={() => setIsOpen((prev) => !prev)}
          aria-expanded={isOpen}
          aria-label={isOpen ? 'Close actions menu' : 'Open project actions'}
          className={cn(
            'flex size-14 items-center justify-center rounded-full text-white shadow-xl transition-all duration-300 active:scale-95 cursor-pointer',
            isOpen
              ? 'bg-neutral-800 hover:bg-neutral-900 rotate-90 ring-4 ring-neutral-400/20'
              : 'bg-[#1241a6] hover:bg-[#0e3488] ring-4 ring-blue-600/20 shadow-blue-900/30'
          )}
        >
          {isOpen ? (
            <X size={24} strokeWidth={2.5} className="transition-transform duration-200" />
          ) : (
            <Plus size={26} strokeWidth={2.5} className="transition-transform duration-200" />
          )}
        </button>
      </div>
    </>
  );
}
