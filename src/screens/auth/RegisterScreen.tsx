import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Building2, CheckCircle2, Landmark, Loader2, ShieldCheck, User as UserIcon } from 'lucide-react';
import type { UserType } from '@/domain';
import {
  Button,
  DocumentUpload,
  Input,
  StepProgress,
  type UploadedFile,
  cn,
} from '@/design-system';
import { ROUTES } from '@/navigation';
import {
  GST_LENGTH,
  MOBILE_LENGTH,
  type AddressRegistrationDetails,
  type OrganizationRegistrationDetails,
  formatAadhaar,
  isValidAadhaar,
  isValidGst,
  isValidMobile,
  isValidPan,
  isValidPincode,
  normalizeAadhaar,
  normalizeGst,
  normalizeMobile,
  normalizePan,
  registrationStepCount,
} from '@/rules';
import { useAuthFlowStore } from '@/state';
import { useCopy } from '@/content';
import { useDevQuickFill } from '@/prototype';
import { AuthLayout } from './AuthLayout';

/**
 * REGISTRATION — Streamlined 2-Step KYC Flow:
 *
 * 1. Step 1 (Basic & Address details):
 *    - Individual: Full name, mobile number, and address
 *    - Organization: Authorized representative name, mobile number, org name, GSTIN (verified), and address
 * 2. Step 2 (KYC Verification):
 *    - Individual: Aadhaar card number + Aadhaar document upload (OTP dispatched to Aadhaar-linked mobile)
 *    - Organization: PAN card number + PAN document upload (OTP dispatched to PAN-linked mobile)
 * 3. Step 3 (OTP Verification on /verify):
 *    - Entering the OTP verifies KYC, creates the account, and automatically signs the user in.
 */
export function RegisterScreen() {
  const navigate = useNavigate();
  const startRegistration = useAuthFlowStore((state) => state.startRegistration);
  const t = useCopy();
  const totalSteps = registrationStepCount(); // 2 steps in form + OTP screen
  const [step, setStep] = useState(0); // 0 = Choose Account Type, 1 = Details, 2 = KYC

  // Account Type: Individual (NORMAL_CONSUMER) by default, or ORGANIZATION
  const [userType, setUserType] = useState<UserType>('NORMAL_CONSUMER');

  // Step 1: Personal / Representative & Contact Details
  const [fullName, setFullName] = useState('');
  const [mobile, setMobile] = useState('');

  // Step 1: Address Details (Unified for both Individual & Organization)
  const [areaClassification, setAreaClassification] = useState<'URBAN' | 'RURAL'>('URBAN');
  const [city, setCity] = useState('');
  const [village, setVillage] = useState('');
  const [address, setAddress] = useState<AddressRegistrationDetails>({
    addressLine: '',
    taluka: '',
    district: '',
    pincode: '',
  });

  // Step 1: Organization Specific Details
  const [organization, setOrganization] = useState<OrganizationRegistrationDetails>({
    organizationName: '',
    organizationType: 'OTHER',
    gstNumber: '',
    registrationNumber: '',
  });

  // GST Verification State
  const [gstStatus, setGstStatus] = useState<'idle' | 'verifying' | 'verified' | 'error'>('idle');
  const [gstDetails, setGstDetails] = useState<{
    tradeName: string;
    taxpayerType: string;
    state: string;
  } | null>(null);
  const [noGst, setNoGst] = useState(false);

  // Step 2: KYC Details
  const [aadhaarNumber, setAadhaarNumber] = useState('');
  const [panNumber, setPanNumber] = useState('');
  const [kycFile, setKycFile] = useState<UploadedFile | null>(null);
  const [panFile, setPanFile] = useState<UploadedFile | null>(null);
  const [aadhaarFile, setAadhaarFile] = useState<UploadedFile | null>(null);

  const [errors, setErrors] = useState<Record<string, string>>({});

  function handleUserTypeChange(type: UserType) {
    if (type === userType) return;
    setUserType(type);
    setErrors({});
    // Reset KYC if type switches
    setKycFile(null);
    setPanFile(null);
    setAadhaarFile(null);
  }

  function handleVerifyGst(gstInput?: string) {
    const clean = normalizeGst(gstInput ?? organization.gstNumber ?? '');
    if (!clean) {
      setErrors((prev) => ({ ...prev, gstNumber: t.auth.gstNumberRequired }));
      return;
    }
    if (!isValidGst(clean)) {
      setErrors((prev) => ({ ...prev, gstNumber: t.auth.gstNumberInvalid }));
      setGstStatus('error');
      return;
    }

    setGstStatus('verifying');
    setErrors((prev) => {
      const copy = { ...prev };
      delete copy.gstNumber;
      return copy;
    });

    // Simulate GST Portal Lookup
    setTimeout(() => {
      setGstStatus('verified');
      const sampleTradeName =
        organization.organizationName.trim() || 'Sahyadri Infra & Construction Ltd';
      setGstDetails({
        tradeName: sampleTradeName,
        taxpayerType: 'Regular Taxpayer',
        state: 'Maharashtra (27)',
      });

      if (!organization.organizationName.trim()) {
        setOrganization((prev) => ({
          ...prev,
          organizationName: sampleTradeName,
        }));
      }
    }, 450);
  }

  function handleQuickFill() {
    setErrors({});
    if (step === 0) {
      setStep(1);
    }
    if (userType === 'ORGANIZATION') {
      setFullName('Rajesh Patil');
      setMobile('9822014576');
      setAddress({
        addressLine: 'Survey No. 42/1, Wagholi-Kesnand Road',
        taluka: 'Haveli',
        district: 'Pune',
        pincode: '412207',
      });
      setOrganization({
        organizationName: 'Shree Infra & Constructions Pvt Ltd',
        organizationType: 'OTHER',
        gstNumber: '27ABCDE1234F1Z5',
        registrationNumber: 'MH-2024-ORG-9988',
      });
      setGstStatus('verified');
      setGstDetails({
        tradeName: 'Shree Infra & Constructions Pvt Ltd',
        taxpayerType: 'Regular Taxpayer',
        state: 'Maharashtra (27)',
      });
      setPanNumber('ABCDE1234F');
      setAadhaarNumber('4532 1098 4532');
      setPanFile({
        name: 'Company_PAN_ABCDE1234F.pdf',
        size: 1024 * 240,
        url: '',
      });
      setAadhaarFile({
        name: 'Signatory_Aadhaar.pdf',
        size: 1024 * 180,
        url: '',
      });
    } else {
      setFullName('Amit Deshmukh');
      setMobile('9730845120');
      setAreaClassification('URBAN');
      setCity('Pune City (PMC)');
      setVillage('');
      setAddress({
        addressLine: 'Flat 402, Shivajinagar Heights',
        taluka: 'Haveli',
        district: 'Pune',
        pincode: '411005',
      });
      setAadhaarNumber('9876 5432 1098');
      setKycFile({
        name: 'Aadhaar_Card_Amit_Deshmukh.pdf',
        size: 1024 * 310,
        url: '',
      });
    }
  }

  useDevQuickFill(handleQuickFill);

  function back() {
    setErrors({});
    if (step === 0) {
      navigate(ROUTES.welcome);
    } else if (step === 1) {
      setStep(0);
    } else {
      setStep((value) => value - 1);
    }
  }

  function next() {
    const found = validateStep();
    setErrors(found);
    if (Object.keys(found).length > 0) return;

    if (step < totalSteps) {
      setStep((value) => value + 1);
      return;
    }

    // Step 2 completed: initiate registration and proceed to OTP verification
    const normalizedMobile = normalizeMobile(mobile);
    const isIndividual = userType === 'NORMAL_CONSUMER';

    const formattedTaluka =
      areaClassification === 'URBAN'
        ? city.trim()
          ? address.taluka.trim()
            ? `${city.trim()} (${address.taluka.trim()})`
            : city.trim()
          : address.taluka.trim()
        : village.trim()
          ? `${address.taluka.trim()}, ${village.trim()}`
          : address.taluka.trim();

    startRegistration({
      userType,
      fullName: fullName.trim(),
      mobileNumber: normalizedMobile,
      address: {
        addressLine: address.addressLine.trim(),
        taluka: formattedTaluka,
        district: address.district.trim(),
        pincode: address.pincode.trim(),
      },
      delivery: {
        addressLine: address.addressLine.trim(),
        taluka: formattedTaluka,
        district: address.district.trim(),
        pincode: address.pincode.trim(),
      },
      organization:
        userType === 'ORGANIZATION'
          ? {
              organizationName: organization.organizationName.trim(),
              organizationType: organization.organizationType || 'OTHER',
              gstNumber: !noGst && organization.gstNumber ? normalizeGst(organization.gstNumber) : undefined,
              registrationNumber: !noGst && organization.gstNumber ? normalizeGst(organization.gstNumber) : normalizePan(panNumber),
            }
          : undefined,
      kyc: {
        documentKind: 'AADHAAR',
        documentNumber: normalizeAadhaar(aadhaarNumber),
        fileName: isIndividual
          ? (kycFile?.name || 'aadhaar_card.pdf')
          : (aadhaarFile?.name || 'signatory_aadhaar_card.pdf'),
        fileSize: isIndividual ? kycFile?.size : aadhaarFile?.size,
        fileUrl: isIndividual ? kycFile?.url : aadhaarFile?.url,
      },
    });

    navigate(ROUTES.verify);
  }

  function validateStep(): Record<string, string> {
    const found: Record<string, string> = {};

    if (step === 1) {
      if (!fullName.trim()) found.fullName = t.auth.required;
      if (!isValidMobile(mobile)) found.mobile = t.auth.mobileInvalid;

      if (!address.addressLine.trim()) found.addressLine = t.auth.required;
      if (areaClassification === 'URBAN') {
        if (!city.trim() && !address.taluka.trim()) found.city = t.auth.required;
      } else {
        if (!address.taluka.trim()) found.taluka = t.auth.required;
      }
      if (!address.district.trim()) found.district = t.auth.required;
      if (!isValidPincode(address.pincode)) found.pincode = t.auth.pincodeInvalid;

      if (userType === 'ORGANIZATION') {
        if (!organization.organizationName.trim()) found.organizationName = t.auth.required;
        if (!noGst) {
          if (!organization.gstNumber?.trim()) {
            found.gstNumber = t.auth.gstNumberRequired;
          } else if (!isValidGst(organization.gstNumber)) {
            found.gstNumber = t.auth.gstNumberInvalid;
          }
        }
      }
    }

    if (step === 2) {
      if (userType === 'NORMAL_CONSUMER') {
        if (!isValidAadhaar(aadhaarNumber)) {
          found.aadhaarNumber = t.auth.aadhaarInvalid;
        }
        if (!kycFile) {
          found.kycFile = t.auth.kycDocRequired;
        }
      } else {
        if (!isValidPan(panNumber)) {
          found.panNumber = t.auth.panInvalid;
        }
        if (!panFile) {
          found.panFile = t.auth.kycDocRequired;
        }
        if (!isValidAadhaar(aadhaarNumber)) {
          found.aadhaarNumber = t.auth.aadhaarInvalid;
        }
        if (!aadhaarFile) {
          found.aadhaarFile = t.auth.kycDocRequired;
        }
      }
    }

    return found;
  }

  const isIndividual = userType === 'NORMAL_CONSUMER';

  return (
    <AuthLayout
      onBack={back}
      header={step > 0 ? <StepProgress current={step} total={totalSteps} /> : undefined}
      title={
        step === 0
          ? 'Choose Account Type'
          : step === 1
          ? isIndividual
            ? t.auth.stepDetailsTitle
            : 'Representative & Organization Details'
          : t.auth.stepKycTitle
      }
      description={
        step === 0
          ? 'Select your account category to continue'
          : step === 1
          ? isIndividual
            ? t.auth.stepDetailsHelpIndividual
            : 'Enter representative contact, company name, and registered site address'
          : isIndividual
          ? t.auth.kycDescIndividual
          : t.auth.kycDescOrganization
      }
      footer={
        step === 0 ? (
          <Button size="lg" fullWidth onClick={() => setStep(1)}>
            {`Continue as ${isIndividual ? 'Individual' : 'Organization'}`}
          </Button>
        ) : (
          <Button size="lg" fullWidth onClick={next}>
            {step === 1 ? t.auth.continueToKyc : t.auth.verifyAndSendOtp}
          </Button>
        )
      }
    >
      <div className={step === 0 ? 'mt-3 pb-2' : 'mt-4 pb-4'}>
        {/* Step 0: Dedicated Account Type Selection */}
        {step === 0 && (
          <div className="space-y-3 pt-0.5">
            {/* 1. Individual Card */}
            <div
              role="button"
              tabIndex={0}
              onClick={() => handleUserTypeChange('NORMAL_CONSUMER')}
              onKeyDown={(e) => e.key === 'Enter' && handleUserTypeChange('NORMAL_CONSUMER')}
              className={`group relative rounded-2xl border p-3.5 transition-all cursor-pointer text-left ${
                isIndividual
                  ? 'border-primary-600 bg-primary-50/50 shadow-sm ring-2 ring-primary-500/20'
                  : 'border-line bg-surface hover:border-neutral-300 hover:bg-surface-sunken/30'
              }`}
            >
              <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-3">
                  <div
                    className={`flex size-10 shrink-0 items-center justify-center rounded-xl transition-colors ${
                      isIndividual
                        ? 'bg-primary-600 text-white'
                        : 'bg-neutral-100 text-neutral-600 group-hover:bg-neutral-200'
                    }`}
                  >
                    <UserIcon size={18} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="text-body font-bold text-ink">Individual</h3>
                      <span className="text-caption text-ink-muted">(व्यक्तिगत)</span>
                    </div>
                    <span
                      className={`inline-block rounded-full px-2 py-0.5 text-[11px] font-semibold ${
                        isIndividual
                          ? 'bg-primary-100 text-primary-900 border border-primary-200/60'
                          : 'bg-neutral-100 text-neutral-600 border border-neutral-200/60'
                      }`}
                    >
                      Personal Use
                    </span>
                  </div>
                </div>

                <span
                  className={`size-5 shrink-0 rounded-full border flex items-center justify-center transition-all ${
                    isIndividual
                      ? 'border-primary-600 bg-primary-600 text-white'
                      : 'border-neutral-300 bg-white'
                  }`}
                >
                  {isIndividual && <span className="size-2 rounded-full bg-white" />}
                </span>
              </div>

              <p className="mt-2.5 text-body-sm text-ink-secondary leading-snug">
                For citizens & home owners ordering sand, aggregate, or minerals for private construction.
              </p>

              <div className="mt-2.5 flex items-center gap-1.5 pt-2 border-t border-line/60 text-caption text-ink-muted">
                <ShieldCheck size={14} className={isIndividual ? 'text-primary-600' : 'text-neutral-400'} />
                <span>KYC: <strong className="text-ink-secondary font-medium">Aadhaar Card + OTP</strong></span>
              </div>
            </div>

            {/* 2. Organization Card */}
            <div
              role="button"
              tabIndex={0}
              onClick={() => handleUserTypeChange('ORGANIZATION')}
              onKeyDown={(e) => e.key === 'Enter' && handleUserTypeChange('ORGANIZATION')}
              className={`group relative rounded-2xl border p-3.5 transition-all cursor-pointer text-left ${
                !isIndividual
                  ? 'border-primary-600 bg-primary-50/50 shadow-sm ring-2 ring-primary-500/20'
                  : 'border-line bg-surface hover:border-neutral-300 hover:bg-surface-sunken/30'
              }`}
            >
              <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-3">
                  <div
                    className={`flex size-10 shrink-0 items-center justify-center rounded-xl transition-colors ${
                      !isIndividual
                        ? 'bg-primary-600 text-white'
                        : 'bg-neutral-100 text-neutral-600 group-hover:bg-neutral-200'
                    }`}
                  >
                    <Building2 size={18} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="text-body font-bold text-ink">Organization</h3>
                      <span className="text-caption text-ink-muted">(संस्था / कंत्राटदार)</span>
                    </div>
                    <span
                      className={`inline-block rounded-full px-2 py-0.5 text-[11px] font-semibold ${
                        !isIndividual
                          ? 'bg-primary-100 text-primary-900 border border-primary-200/60'
                          : 'bg-neutral-100 text-neutral-600 border border-neutral-200/60'
                      }`}
                    >
                      Commercial & Projects
                    </span>
                  </div>
                </div>

                <span
                  className={`size-5 shrink-0 rounded-full border flex items-center justify-center transition-all ${
                    !isIndividual
                      ? 'border-primary-600 bg-primary-600 text-white'
                      : 'border-neutral-300 bg-white'
                  }`}
                >
                  {!isIndividual && <span className="size-2 rounded-full bg-white" />}
                </span>
              </div>

              <p className="mt-2.5 text-body-sm text-ink-secondary leading-snug">
                For contractors & companies executing projects, commercial orders, permits & DigiTPs.
              </p>

              <div className="mt-2.5 flex items-center gap-1.5 pt-2 border-t border-line/60 text-caption text-ink-muted">
                <ShieldCheck size={14} className={!isIndividual ? 'text-primary-600' : 'text-neutral-400'} />
                <span>KYC: <strong className="text-ink-secondary font-medium">PAN & optional GSTIN</strong></span>
              </div>
            </div>
          </div>
        )}

        {/* Step 1: Basic & Address Details */}
        {step === 1 && (
          <div className="space-y-4">
            {/* Account Type Summary Pill with Change Button */}
            <div className="flex items-center justify-between rounded-xl bg-primary-50/70 p-3 border border-primary-100 mb-1">
              <div className="flex items-center gap-2.5">
                <div className="flex size-8 items-center justify-center rounded-lg bg-primary-600 text-white">
                  {isIndividual ? <UserIcon size={15} /> : <Building2 size={15} />}
                </div>
                <div>
                  <p className="text-body-sm font-bold text-ink">
                    {isIndividual ? 'Individual (व्यक्तिगत)' : 'Organization (संस्था / कंत्राटदार)'}
                  </p>
                  <p className="text-[11px] text-ink-secondary">
                    {isIndividual ? 'Personal & Home Construction' : 'Commercial Projects & Permits'}
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setStep(0)}
                className="rounded-lg bg-white px-3 py-1.5 text-caption font-semibold text-primary-700 border border-primary-200 shadow-2xs hover:bg-primary-50 active:scale-95 transition-all cursor-pointer"
              >
                Change
              </button>
            </div>

            {/* Basic Details */}
            <Input
              label={isIndividual ? t.auth.fullNameLabel : t.auth.repFullNameLabel}
              autoComplete="name"
              autoFocus
              placeholder="e.g. Ramesh Patil"
              value={fullName}
              {...(errors.fullName ? { error: errors.fullName } : {})}
              onChange={(event) => setFullName(event.target.value)}
            />

            <Input
              label={t.auth.mobileLabel}
              type="tel"
              inputMode="numeric"
              autoComplete="tel"
              maxLength={MOBILE_LENGTH}
              placeholder={t.auth.mobilePlaceholder}
              value={mobile}
              leftIcon={<span className="text-body text-ink-secondary tabular">+91</span>}
              hint={t.auth.mobileHint}
              {...(errors.mobile ? { error: errors.mobile } : {})}
              onChange={(event) =>
                setMobile(event.target.value.replace(/\D/g, '').slice(0, MOBILE_LENGTH))
              }
            />

            {/* Organization specifics */}
            {!isIndividual && (
              <>
                <Input
                  label={t.auth.organizationNameLabel}
                  placeholder="e.g. Sahyadri Builders Pvt Ltd"
                  value={organization.organizationName}
                  {...(errors.organizationName ? { error: errors.organizationName } : {})}
                  onChange={(event) =>
                    setOrganization((prev) => ({ ...prev, organizationName: event.target.value }))
                  }
                />

                {/* GSTIN Section with Optional Toggle */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <label className="text-body-sm font-semibold text-ink">
                      {t.auth.gstNumberLabel}{' '}
                      {!noGst && <span className="text-danger-500">*</span>}
                    </label>
                    <label className="flex items-center gap-1.5 text-caption text-ink-secondary cursor-pointer select-none">
                      <input
                        type="checkbox"
                        checked={noGst}
                        onChange={(e) => {
                          setNoGst(e.target.checked);
                          if (e.target.checked) {
                            setGstStatus('idle');
                            setGstDetails(null);
                            setErrors((prev) => {
                              const copy = { ...prev };
                              delete copy.gstNumber;
                              return copy;
                            });
                          }
                        }}
                        className="rounded border-line text-primary-600 focus:ring-primary-500 size-3.5"
                      />
                      <span>I don't have GSTIN (Add later)</span>
                    </label>
                  </div>

                  {!noGst ? (
                    <>
                      <Input
                        placeholder={t.auth.gstNumberPlaceholder}
                        maxLength={GST_LENGTH}
                        value={organization.gstNumber || ''}
                        hint={gstStatus === 'verified' ? undefined : t.auth.gstNumberHint}
                        {...(errors.gstNumber ? { error: errors.gstNumber } : {})}
                        onChange={(event) => {
                          const raw = normalizeGst(event.target.value).slice(0, GST_LENGTH);
                          setOrganization((prev) => ({ ...prev, gstNumber: raw }));
                          if (gstStatus === 'verified' || gstStatus === 'error') {
                            setGstStatus('idle');
                            setGstDetails(null);
                          }
                          if (errors.gstNumber) {
                            setErrors((prev) => {
                              const copy = { ...prev };
                              delete copy.gstNumber;
                              return copy;
                            });
                          }
                        }}
                        rightSlot={
                          gstStatus === 'verified' ? (
                            <span className="flex items-center gap-1 text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                              <CheckCircle2 size={13} className="text-emerald-600" />
                              <span>Verified</span>
                            </span>
                          ) : gstStatus === 'verifying' ? (
                            <span className="flex items-center gap-1 text-caption text-primary-700">
                              <Loader2 size={13} className="animate-spin" />
                              <span>{t.auth.verifyingGst}</span>
                            </span>
                          ) : (
                            <button
                              type="button"
                              onClick={() => handleVerifyGst()}
                              className="rounded px-2 py-0.5 text-caption font-semibold text-primary-700 hover:bg-primary-50 active:bg-primary-100 transition-colors cursor-pointer border border-primary-200"
                            >
                              {t.auth.verifyGst}
                            </button>
                          )
                        }
                      />

                      {gstStatus === 'verified' && gstDetails && (
                        <div className="rounded-xl border border-emerald-200 bg-emerald-50/50 p-3 text-body-sm animate-fadeIn">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-1.5 text-emerald-800 font-semibold text-caption">
                              <CheckCircle2 size={15} className="text-emerald-600" />
                              <span>{t.auth.gstVerified}</span>
                            </div>
                            <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-[10px] font-bold text-emerald-800 uppercase tracking-wide">
                              Active
                            </span>
                          </div>
                          <div className="mt-2 space-y-1 text-caption text-ink-secondary border-t border-emerald-100 pt-2">
                            <div className="flex justify-between">
                              <span className="text-ink-muted">Trade Name:</span>
                              <span className="font-semibold text-ink">{gstDetails.tradeName}</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-ink-muted">Taxpayer Type:</span>
                              <span className="font-medium text-ink">{gstDetails.taxpayerType}</span>
                            </div>
                            <div className="flex justify-between">
                              <span className="text-ink-muted">Jurisdiction:</span>
                              <span className="font-medium text-ink">{gstDetails.state}</span>
                            </div>
                          </div>
                        </div>
                      )}
                    </>
                  ) : (
                    <p className="rounded-lg bg-neutral-100 px-3 py-2 text-caption text-ink-secondary">
                      ℹ️ You can continue registration without a GSTIN. Business PAN and signatory KYC will be used for account verification.
                    </p>
                  )}
                </div>
              </>
            )}

            {/* Address Details */}
            <div className="pt-2 border-t border-line/60">
              <p className="mb-3 text-caption font-bold tracking-wide text-ink-muted uppercase">
                {isIndividual ? t.auth.deliveryTitle : t.auth.orgAddressLabel}
              </p>

              <div className="space-y-3.5">
                {/* 1) Area Classification (Urban vs Rural) UPFRONT */}
                <div>
                  <label className="mb-1.5 block text-caption font-semibold text-ink">
                    Area Classification
                  </label>
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      onClick={() => setAreaClassification('URBAN')}
                      className={cn(
                        'flex h-11 items-center justify-center gap-2 rounded-xl border text-body-sm font-semibold transition-all cursor-pointer',
                        areaClassification === 'URBAN'
                          ? 'border-primary-600 bg-primary-50/70 text-primary-700 font-bold shadow-xs ring-1 ring-primary-300/40'
                          : 'border-line bg-surface text-ink-muted hover:border-neutral-300',
                      )}
                    >
                      <Building2 size={16} />
                      <span>Urban (City)</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => setAreaClassification('RURAL')}
                      className={cn(
                        'flex h-11 items-center justify-center gap-2 rounded-xl border text-body-sm font-semibold transition-all cursor-pointer',
                        areaClassification === 'RURAL'
                          ? 'border-primary-600 bg-primary-50/70 text-primary-700 font-bold shadow-xs ring-1 ring-primary-300/40'
                          : 'border-line bg-surface text-ink-muted hover:border-neutral-300',
                      )}
                    >
                      <Landmark size={16} />
                      <span>Rural (Village)</span>
                    </button>
                  </div>
                </div>

                {/* 2) Administrative Hierarchy (District & Taluka / City / Village) */}
                <div className="space-y-3">
                  <Input
                    label={t.auth.districtLabel}
                    placeholder="e.g. Pune / Thane / Mumbai"
                    value={address.district}
                    {...(errors.district ? { error: errors.district } : {})}
                    onChange={(event) => {
                      setAddress((prev) => ({ ...prev, district: event.target.value }));
                      setErrors((prev) => ({ ...prev, district: '' }));
                    }}
                  />

                  {areaClassification === 'URBAN' ? (
                    <div className="grid grid-cols-2 gap-3">
                      <Input
                        label="City / Corporation"
                        placeholder="e.g. Pune City (PMC)"
                        value={city}
                        {...(errors.city ? { error: errors.city } : {})}
                        onChange={(event) => {
                          setCity(event.target.value);
                          setErrors((prev) => ({ ...prev, city: '' }));
                        }}
                      />
                      <Input
                        label="Taluka / Zone (CTSO)"
                        placeholder="e.g. Haveli"
                        value={address.taluka}
                        {...(errors.taluka ? { error: errors.taluka } : {})}
                        onChange={(event) => {
                          setAddress((prev) => ({ ...prev, taluka: event.target.value }));
                          setErrors((prev) => ({ ...prev, taluka: '' }));
                        }}
                      />
                    </div>
                  ) : (
                    <div className="grid grid-cols-2 gap-3">
                      <Input
                        label={t.auth.talukaLabel}
                        placeholder="e.g. Haveli / Daund"
                        value={address.taluka}
                        {...(errors.taluka ? { error: errors.taluka } : {})}
                        onChange={(event) => {
                          setAddress((prev) => ({ ...prev, taluka: event.target.value }));
                          setErrors((prev) => ({ ...prev, taluka: '' }));
                        }}
                      />
                      <Input
                        label="Village / Gram Panchayat"
                        placeholder="e.g. Wagholi / Kesnand"
                        value={village}
                        {...(errors.village ? { error: errors.village } : {})}
                        onChange={(event) => {
                          setVillage(event.target.value);
                          setErrors((prev) => ({ ...prev, village: '' }));
                        }}
                      />
                    </div>
                  )}
                </div>

                {/* 3) Registered / Delivery Street Address */}
                <Input
                  label={t.auth.addressLabel}
                  placeholder="Plot / House No., Building, Area / Road"
                  value={address.addressLine}
                  {...(errors.addressLine ? { error: errors.addressLine } : {})}
                  onChange={(event) => {
                    setAddress((prev) => ({ ...prev, addressLine: event.target.value }));
                    setErrors((prev) => ({ ...prev, addressLine: '' }));
                  }}
                />

                {/* 4) PIN code */}
                <Input
                  label={t.auth.pincodeLabel}
                  inputMode="numeric"
                  maxLength={6}
                  placeholder="6-digit PIN code"
                  value={address.pincode}
                  {...(errors.pincode ? { error: errors.pincode } : {})}
                  onChange={(event) => {
                    setAddress((prev) => ({
                      ...prev,
                      pincode: event.target.value.replace(/\D/g, '').slice(0, 6),
                    }));
                    setErrors((prev) => ({ ...prev, pincode: '' }));
                  }}
                />
              </div>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-5">
            {isIndividual ? (
              <>
                {/* Individual: Aadhaar KYC */}
                <Input
                  label={t.auth.aadhaarLabel}
                  inputMode="numeric"
                  autoFocus
                  placeholder={t.auth.aadhaarPlaceholder}
                  maxLength={14}
                  value={formatAadhaar(aadhaarNumber)}
                  {...(errors.aadhaarNumber ? { error: errors.aadhaarNumber } : {})}
                  onChange={(event) => {
                    const raw = event.target.value.replace(/\D/g, '').slice(0, 12);
                    setAadhaarNumber(raw);
                  }}
                />

                <DocumentUpload
                  label={t.auth.uploadAadhaarLabel}
                  description={t.auth.uploadAadhaarHint}
                  file={kycFile}
                  onFileSelect={setKycFile}
                  onRemove={() => setKycFile(null)}
                  error={errors.kycFile}
                  required
                  sampleFileName="aadhaar_card_front.pdf"
                />

                {/* Aadhaar Notice Banner */}
                <div className="flex items-start gap-3 rounded-xl border border-primary-200 bg-primary-50/60 p-3.5 text-primary-950">
                  <ShieldCheck size={20} className="mt-0.5 shrink-0 text-primary-700" />
                  <p className="text-body-sm leading-relaxed text-ink">
                    {t.auth.kycNoticeIndividual}
                  </p>
                </div>
              </>
            ) : (
              <>
                {/* 1. Organization: Company PAN KYC */}
                <div className="space-y-3">
                  <p className="text-caption font-bold tracking-wider text-ink-muted uppercase">
                    1. Company PAN Card Verification
                  </p>
                  <Input
                    label={t.auth.panLabel}
                    autoFocus
                    placeholder={t.auth.panPlaceholder}
                    maxLength={10}
                    value={panNumber}
                    {...(errors.panNumber ? { error: errors.panNumber } : {})}
                    onChange={(event) => {
                      const raw = normalizePan(event.target.value).slice(0, 10);
                      setPanNumber(raw);
                    }}
                  />

                  <DocumentUpload
                    label={t.auth.uploadPanLabel}
                    description={t.auth.uploadPanHint}
                    file={panFile}
                    onFileSelect={setPanFile}
                    onRemove={() => setPanFile(null)}
                    error={errors.panFile}
                    required
                    sampleFileName="company_pan_card.pdf"
                  />
                </div>

                {/* 2. Authorized Signatory Aadhaar KYC */}
                <div className="space-y-3 pt-2">
                  <p className="text-caption font-bold tracking-wider text-ink-muted uppercase">
                    2. Authorized Signatory Aadhaar Verification
                  </p>
                  <Input
                    label="Authorized Signatory Aadhaar Number"
                    inputMode="numeric"
                    placeholder="12-digit Aadhaar Number"
                    maxLength={14}
                    value={formatAadhaar(aadhaarNumber)}
                    {...(errors.aadhaarNumber ? { error: errors.aadhaarNumber } : {})}
                    onChange={(event) => {
                      const raw = event.target.value.replace(/\D/g, '').slice(0, 12);
                      setAadhaarNumber(raw);
                    }}
                  />

                  <DocumentUpload
                    label="Upload Signatory Aadhaar Document"
                    description="Clear copy of authorized signatory's Aadhaar (front & back)"
                    file={aadhaarFile}
                    onFileSelect={setAadhaarFile}
                    onRemove={() => setAadhaarFile(null)}
                    error={errors.aadhaarFile}
                    required
                    sampleFileName="signatory_aadhaar_card.pdf"
                  />
                </div>

                {/* PAN & Aadhaar Notice Banner */}
                <div className="flex items-start gap-3 rounded-xl border border-primary-200 bg-primary-50/60 p-3.5 text-primary-950">
                  <ShieldCheck size={20} className="mt-0.5 shrink-0 text-primary-700" />
                  <p className="text-body-sm leading-relaxed text-ink">
                    {t.auth.kycNoticeOrganization}
                  </p>
                </div>
              </>
            )}
          </div>
        )}
      </div>
    </AuthLayout>
  );
}
