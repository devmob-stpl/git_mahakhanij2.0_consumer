import type { ReactNode } from 'react';
import { Plus } from 'lucide-react';
import { cn } from '../utils/cn';

export interface FloatingActionButtonProps {
  onClick: () => void;
  icon?: ReactNode;
  label?: string;
  ariaLabel?: string;
  className?: string;
}

/**
 * High-priority primary floating action button (FAB) positioned at the bottom right.
 * Provides rapid, thumb-accessible creation of Projects and Packages.
 */
export function FloatingActionButton({
  onClick,
  icon = <Plus size={22} strokeWidth={2.5} />,
  label,
  ariaLabel = 'Add',
  className,
}: FloatingActionButtonProps) {
  return (
    <div className="absolute bottom-5 right-4 z-30 pointer-events-auto">
      <button
        type="button"
        onClick={onClick}
        aria-label={label ?? ariaLabel}
        className={cn(
          'group flex items-center justify-center gap-2 rounded-full',
          'bg-primary-600 text-white shadow-e3 transition-all duration-200',
          'hover:bg-primary-700 active:scale-95 hover:shadow-xl focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
          label
            ? 'px-4 py-3 text-body-sm font-semibold'
            : 'h-14 w-14 p-3.5',
          className,
        )}
      >
        <span className="shrink-0 transition-transform duration-200 group-hover:rotate-90">
          {icon}
        </span>
        {label && <span className="font-semibold tracking-wide">{label}</span>}
      </button>
    </div>
  );
}
