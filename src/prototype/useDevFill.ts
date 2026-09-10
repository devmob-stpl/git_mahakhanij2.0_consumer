import { useEffect } from 'react';

export const DEV_QUICK_FILL_EVENT = 'dev:quick-fill';

/**
 * Triggers a global dev quick-fill event that any active screen or form can listen to.
 */
export function triggerDevQuickFill() {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent(DEV_QUICK_FILL_EVENT));
  }
}

/**
 * Hook to register a quick-fill handler on any screen or form.
 */
export function useDevQuickFill(onFill: () => void) {
  useEffect(() => {
    const handleEvent = () => {
      onFill();
    };

    window.addEventListener(DEV_QUICK_FILL_EVENT, handleEvent);
    return () => {
      window.removeEventListener(DEV_QUICK_FILL_EVENT, handleEvent);
    };
  }, [onFill]);
}
