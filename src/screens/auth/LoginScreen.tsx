import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Input } from '@/design-system';
import { ROUTES } from '@/navigation';
import { MOBILE_LENGTH, isValidMobile, normalizeMobile } from '@/rules';
import { useAuthFlowStore } from '@/state';
import { useCopy } from '@/content';
import { useDevQuickFill } from '@/prototype';
import { AuthLayout } from './AuthLayout';

/**
 * Mobile number entry.
 *
 * One field, one action. Validation is deferred until submit rather than
 * firing on every keystroke — telling someone their number is invalid while
 * they are still typing it is noise, not help.
 */
export function LoginScreen() {
  const [mobile, setMobile] = useState('');
  const [error, setError] = useState<string | null>(null);
  const startSignIn = useAuthFlowStore((state) => state.startSignIn);
  const navigate = useNavigate();
  const t = useCopy();

  function fillNumber(num: string) {
    setMobile(num);
    setError(null);
  }

  useDevQuickFill(() => fillNumber('9822014576'));

  function handleSubmit() {
    if (!isValidMobile(mobile)) {
      setError(t.auth.mobileInvalid);
      return;
    }

    startSignIn(normalizeMobile(mobile));
    navigate(ROUTES.verify);
  }

  return (
    <AuthLayout
      title={t.auth.signIn}
      description={t.auth.mobileHint}
      onBack={true}
      footer={
        <Button size="lg" fullWidth onClick={handleSubmit} disabled={mobile.length === 0}>
          {t.actions.continue}
        </Button>
      }
    >

      <form
        className="mt-4"
        onSubmit={(event) => {
          event.preventDefault();
          handleSubmit();
        }}
      >
        <Input
          label={t.auth.mobileLabel}
          type="tel"
          inputMode="numeric"
          autoComplete="tel"
          autoFocus
          maxLength={MOBILE_LENGTH}
          placeholder={t.auth.mobilePlaceholder}
          value={mobile}
          leftIcon={<span className="text-body text-ink-secondary tabular">+91</span>}
          {...(error ? { error } : {})}
          onChange={(event) => {
            setMobile(event.target.value.replace(/\D/g, '').slice(0, MOBILE_LENGTH));
            setError(null);
          }}
        />
      </form>

      <p className="mt-6 text-body-sm text-ink-secondary">
        {t.auth.noAccountYet}{' '}
        <button
          type="button"
          onClick={() => navigate(ROUTES.register)}
          className="font-medium text-primary-700 underline underline-offset-2"
        >
          {t.auth.createAccount}
        </button>
      </p>

      {/* ==== PROTOTYPE ONLY — quick fill account chips ==== */}
      <div className="mt-8 rounded-xl border border-dashed border-amber-300 bg-amber-50/60 p-3 space-y-2">
        <p className="text-caption font-bold text-amber-900 flex items-center justify-between">
          <span>⚡ Quick Fill Demo Numbers:</span>
          <span className="text-[10px] text-amber-700 font-normal">Tap to fill</span>
        </p>
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => fillNumber('9822014576')}
            className="inline-flex items-center gap-1.5 rounded-lg border border-amber-300 bg-white px-2.5 py-1 text-caption font-medium text-amber-900 shadow-xs hover:bg-amber-100 active:scale-95 transition-all cursor-pointer"
          >
            <span className="font-bold">9822014576</span>
            <span className="text-[11px] text-amber-700">(Organization)</span>
          </button>
          <button
            type="button"
            onClick={() => fillNumber('9730845120')}
            className="inline-flex items-center gap-1.5 rounded-lg border border-amber-300 bg-white px-2.5 py-1 text-caption font-medium text-amber-900 shadow-xs hover:bg-amber-100 active:scale-95 transition-all cursor-pointer"
          >
            <span className="font-bold">9730845120</span>
            <span className="text-[11px] text-amber-700">(Individual)</span>
          </button>
        </div>
      </div>
      {/* ==== end prototype block ==== */}
    </AuthLayout>
  );
}
