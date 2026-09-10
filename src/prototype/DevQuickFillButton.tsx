import { Sparkles, Zap } from 'lucide-react';
import { cn } from '@/design-system';
import { triggerDevQuickFill } from './useDevFill';

export interface DevQuickFillButtonProps {
  onFill?: () => void;
  label?: string;
  className?: string;
  variant?: 'inline' | 'floating' | 'chip';
  size?: 'sm' | 'md';
}

/**
 * PROTOTYPE / DEV ONLY: A convenient button to auto-fill form data instantly.
 */
export function DevQuickFillButton({
  onFill,
  label = 'Quick Fill Demo',
  className = '',
  variant = 'inline',
  size = 'sm',
}: DevQuickFillButtonProps) {
  // Only render in dev or prototype mode
  const isDev = import.meta.env.DEV || Boolean(import.meta.env.VITE_PROTOTYPE);
  if (!isDev) return null;

  const handleClick = () => {
    if (onFill) {
      onFill();
    } else {
      triggerDevQuickFill();
    }
  };

  if (variant === 'floating') {
    return (
      <div className={cn('fixed bottom-20 left-4 z-50', className)}>
        <button
          type="button"
          onClick={handleClick}
          title="⚡ Quick Fill Form with Demo Data"
          className="flex items-center gap-1.5 rounded-full bg-gradient-to-r from-amber-500 to-amber-600 px-3.5 py-2 text-[12px] font-bold text-white shadow-lg ring-2 ring-white/20 transition-all hover:scale-105 active:scale-95 cursor-pointer"
        >
          <Zap size={14} className="animate-pulse" />
          <span>{label}</span>
        </button>
      </div>
    );
  }

  if (variant === 'chip') {
    return (
      <button
        type="button"
        onClick={handleClick}
        title="Auto fill sample data"
        className={cn(
          'inline-flex items-center gap-1 rounded-md border border-amber-300 bg-amber-50 px-2 py-0.5 text-[11px] font-semibold text-amber-900 hover:bg-amber-100 active:scale-95 transition-all cursor-pointer shadow-xs',
          className
        )}
      >
        <Zap size={12} className="text-amber-600" />
        <span>{label}</span>
      </button>
    );
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      className={cn(
        'group inline-flex items-center gap-1.5 rounded-lg border border-amber-300/80 bg-gradient-to-r from-amber-50 to-orange-50 px-3 py-1.5 text-caption font-bold text-amber-900 shadow-xs transition-all hover:border-amber-400 hover:bg-amber-100 hover:shadow-sm active:scale-95 cursor-pointer',
        size === 'sm' ? 'py-1 text-[11.5px]' : 'py-2 text-[13px]',
        className
      )}
    >
      <Sparkles size={14} className="text-amber-600 group-hover:rotate-12 transition-transform" />
      <span>{label}</span>
      <span className="rounded bg-amber-200/80 px-1 py-0.2 text-[10px] uppercase tracking-wider text-amber-800">
        Dev
      </span>
    </button>
  );
}
