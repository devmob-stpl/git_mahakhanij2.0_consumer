import { useSearchParams } from 'react-router-dom';
import { Button, ErrorState, LoadingState, StepProgress, Surface } from '@/design-system';
import { OrganizationContextBar, Screen } from '@/navigation';
import { mineralRepository, projectRepository, useAsync } from '@/data';
import { useCurrentOrganization, useCurrentUser, useOperatingContext } from '@/state';
import { useCopy } from '@/content';
import { useApplicationForm } from './useApplicationForm';
import { ApplicantStep } from './steps/ApplicantStep';
import { ExcavationStep } from './steps/ExcavationStep';
import { LocationStep } from './steps/LocationStep';
import { DocumentsStep } from './steps/DocumentsStep';
import { ReviewStep } from './steps/ReviewStep';

export function NewApplicationScreen() {
  const organization = useCurrentOrganization();
  const user = useCurrentUser();
  const context = useOperatingContext();
  const [searchParams] = useSearchParams();
  const draftId = searchParams.get('draftId');
  const t = useCopy();

  const form = useApplicationForm({ user, organization, context, draftId });
  const minerals = useAsync(() => mineralRepository.listAll(), []);
  const projects = useAsync(
    () =>
      organization
        ? projectRepository.listByOrganization(organization.id)
        : user
        ? projectRepository.listForConsumer(user.id)
        : projectRepository.listByOrganization('org-001'),
    [organization?.id, user?.id],
  );

  const isReview = form.step === 'REVIEW';
  const heading = HEADINGS[form.step];

  return (
    <Screen
      title={draftId ? 'Resume Application' : t.excavation.newApplication}
      onBack={() => {
        if (!form.back()) {
          form.saveAndExit();
        }
      }}
      context={<OrganizationContextBar showChange={false} />}
      actions={
        <button
          type="button"
          disabled={form.submitting}
          onClick={() => form.saveAndExit()}
          className="text-[12px] font-bold text-primary-700 bg-primary-50 hover:bg-primary-100 px-3 py-1.5 rounded-lg border border-primary-200/60 transition-colors cursor-pointer disabled:opacity-50"
        >
          Save & Exit
        </button>
      }
      footer={
        isReview ? (
          <div className="space-y-2">
            <Button
              size="lg"
              fullWidth
              loading={form.submitting}
              onClick={() => form.persist(true)}
            >
              {form.submitting ? t.excavation.submitting : t.excavation.payAndSubmit}
            </Button>
            <Button
              variant="ghost"
              fullWidth
              disabled={form.submitting}
              onClick={() => form.saveAndExit()}
            >
              {t.excavation.saveDraft}
            </Button>
          </div>
        ) : (
          <div className="space-y-2">
            <Button size="lg" fullWidth onClick={form.next}>
              {t.actions.continue}
            </Button>
            <button
              type="button"
              disabled={form.submitting}
              onClick={() => form.saveAndExit()}
              className="w-full text-center py-1.5 text-caption font-semibold text-neutral-500 hover:text-neutral-800 transition-colors cursor-pointer"
            >
              Save as draft and exit
            </button>
          </div>
        )
      }
    >
      {minerals.loading && <LoadingState variant="screen" />}
      {minerals.error && <ErrorState onRetry={minerals.reload} />}

      {minerals.data && (
        <>
          <div className="border-b border-line bg-surface px-4 py-2.5 flex items-center justify-between">
            <div className="flex-1 mr-4">
              <StepProgress current={form.stepIndex + 1} total={form.totalSteps} />
            </div>
            <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200/80 shrink-0">
              {form.saveStatus === 'saving' ? 'Saving...' : 'Auto-saved ✓'}
            </span>
          </div>

          <div className="px-4 py-5">
            <h2 className="text-title-lg text-ink">{t.excavation[heading.title]}</h2>
            <p className="mt-1 text-body-sm text-ink-secondary">{t.excavation[heading.hint]}</p>
          </div>

          <Surface className="border-y border-line px-4 py-4">
            {form.step === 'APPLICANT' && (
              <ApplicantStep draft={form.draft} errors={form.errors} update={form.update} />
            )}

            {form.step === 'EXCAVATION' && (
              <ExcavationStep
                draft={form.draft}
                errors={form.errors}
                update={form.update}
                minerals={minerals.data}
                projects={projects.data ?? []}
              />
            )}

            {form.step === 'LOCATION' && (
              <LocationStep
                draft={form.draft}
                errors={form.errors}
                update={form.update}
                patch={form.patch}
              />
            )}

            {form.step === 'DOCUMENTS' && (
              <DocumentsStep
                documents={form.documents}
                attachedKinds={form.attachedKinds}
                errors={form.errors}
                onAttach={(kind, label, docNum) => form.attach(kind, label, docNum)}
                onRemove={form.detach}
              />
            )}

            {isReview && (
              <ReviewStep
                draft={form.draft}
                errors={form.errors}
                documents={form.documents}
                minerals={minerals.data}
                onDeclarationChange={(accepted) => form.update('declarationAccepted', accepted)}
                onEdit={form.goToStep}
              />
            )}
          </Surface>
        </>
      )}
    </Screen>
  );
}

/** Step heading and sub-heading, keyed by step. Copy lives in @/content. */
const HEADINGS = {
  APPLICANT: { title: 'stepApplicant', hint: 'stepApplicantHint' },
  EXCAVATION: { title: 'stepExcavation', hint: 'stepExcavationHint' },
  LOCATION: { title: 'stepLocation', hint: 'stepLocationHint' },
  DOCUMENTS: { title: 'stepDocuments', hint: 'stepDocumentsHint' },
  REVIEW: { title: 'stepReview', hint: 'stepReviewHint' },
} as const;
