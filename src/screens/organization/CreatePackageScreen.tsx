import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Boxes, Building2, Check, Landmark, MapPin, UserCheck } from 'lucide-react';
import type { GeoPoint, SupervisorInfo } from '@/domain';
import { Button, Input, Select, Surface, cn } from '@/design-system';
import { packageRepository, projectRepository, useAsync } from '@/data';
import { useCurrentOrganization } from '@/state';
import { ROUTES, Screen } from '@/navigation';
import { LocationMapOverlay } from '../excavation/LocationMapOverlay';

const STATE_CENTRE: GeoPoint = { latitude: 19.7515, longitude: 75.7139 };

export function CreatePackageScreen() {
  const navigate = useNavigate();
  const { projectId } = useParams<{ projectId: string }>();
  const organization = useCurrentOrganization();

  const [name, setName] = useState('');
  const [category, setCategory] = useState<'URBAN' | 'RURAL'>('RURAL');
  const [city, setCity] = useState('');
  const [village, setVillage] = useState('');
  const [line1, setLine1] = useState('');
  const [taluka, setTaluka] = useState('');
  const [district, setDistrict] = useState('');
  const [state, setState] = useState('Maharashtra');
  const [pincode, setPincode] = useState('');
  const [selectedSupervisorCode, setSelectedSupervisorCode] = useState('');
  const [siteGeo, setSiteGeo] = useState<GeoPoint | null>(null);
  const [mapOpen, setMapOpen] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  /* Load registered supervisors list */
  const supervisors = useAsync(() => packageRepository.listSupervisors(), []);

  /* Pre-populate location details from parent project if available */
  useEffect(() => {
    if (!projectId) return;
    void projectRepository.getById(projectId).then((project) => {
      if (project?.location) {
        setTaluka(project.location.taluka || '');
        setDistrict(project.location.district || '');
        setState(project.location.state || 'Maharashtra');
        setPincode(project.location.pincode || '');
      }
      if (project?.geo) {
        setSiteGeo(project.geo);
      }
    });
  }, [projectId]);

  const selectedSupervisor = supervisors.data?.find(
    (s) => s.employeeCode === selectedSupervisorCode,
  );

  function validate() {
    const errs: Record<string, string> = {};
    if (!name.trim()) errs.name = 'Enter the package name.';
    if (!line1.trim()) errs.line1 = 'Enter the package address.';
    if (category === 'URBAN') {
      if (!city.trim() && !taluka.trim()) errs.city = 'Enter the city or taluka.';
    } else {
      if (!taluka.trim()) errs.taluka = 'Enter the taluka.';
    }
    if (!district.trim()) errs.district = 'Enter the district.';
    if (!pincode.trim()) errs.pincode = 'Enter the PIN code.';

    setErrors(errs);
    return Object.keys(errs).length === 0;
  }

  async function handleSubmit() {
    if (!organization || !projectId) return;
    if (!validate()) return;

    setSubmitting(true);
    try {
      const project = await projectRepository.getById(projectId);
      if (!project) return;

      const formattedTaluka =
        category === 'URBAN'
          ? city.trim()
            ? taluka.trim()
              ? `${city.trim()} (${taluka.trim()})`
              : city.trim()
            : taluka.trim()
          : village.trim()
            ? `${taluka.trim()}, ${village.trim()}`
            : taluka.trim();

      await packageRepository.create(project.id, organization.id, {
        name: name.trim(),
        code: `PKG-${project.id.slice(-4).toUpperCase()}-${String(Date.now()).slice(-4)}`,
        siteAddress: {
          line1: line1.trim(),
          taluka: formattedTaluka,
          district: district.trim(),
          state: state.trim() || 'Maharashtra',
          pincode: pincode.trim(),
        },
        siteGeo: siteGeo ?? project.geo ?? STATE_CENTRE,
        supervisor: selectedSupervisor,
      });

      navigate(ROUTES.projectDetails(project.id), { replace: true });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <Screen title="Create package" onBack>
      <div className="space-y-4 pb-12">
        {/* Banner */}
        <Surface className="border-y border-line px-4 py-4">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary-50 text-primary-600 shadow-2xs">
              <Boxes size={20} />
            </div>
            <div>
              <p className="text-overline uppercase tracking-wider text-ink-muted">Package</p>
              <h2 className="text-title-lg font-bold text-ink">Create a package</h2>
            </div>
          </div>
          <p className="mt-2 text-body-sm text-ink-secondary">
            Add a package site and assign a registered supervisor to monitor material delivery, receipt inspection, and local consumption.
          </p>
        </Surface>

        {/* Form Container */}
        <Surface className="border-y border-line px-4 py-5 space-y-4">
          {/* Package Name */}
          <Input
            label="Package name"
            required
            value={name}
            onChange={(event) => {
              setName(event.target.value);
              setErrors((prev) => ({ ...prev, name: '' }));
            }}
            placeholder="e.g. North excavation block / Package A"
            {...(errors.name ? { error: errors.name } : {})}
          />

          {/* ------------------------------------------------------------- */}
          {/* LOCATION & SITE JURISDICTION (Urban/Rural first, then Address) */}
          {/* ------------------------------------------------------------- */}
          <div className="pt-2 border-t border-line space-y-3.5">
            <div className="flex items-center justify-between">
              <span className="text-caption font-bold uppercase tracking-wider text-ink-muted">
                Package Location & Jurisdiction
              </span>
            </div>

            {/* 1) Area Classification (Urban vs Rural) UPFRONT */}
            <div>
              <label className="mb-1.5 block text-caption font-semibold text-ink">
                Area Classification
              </label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setCategory('URBAN')}
                  className={cn(
                    'flex h-11 items-center justify-center gap-2 rounded-xl border text-body-sm font-semibold transition-all cursor-pointer',
                    category === 'URBAN'
                      ? 'border-primary-600 bg-primary-50/70 text-primary-700 font-bold shadow-xs ring-1 ring-primary-300/40'
                      : 'border-line bg-surface text-ink-muted hover:border-neutral-300',
                  )}
                >
                  <Building2 size={16} />
                  <span>Urban (City / PMC)</span>
                </button>

                <button
                  type="button"
                  onClick={() => setCategory('RURAL')}
                  className={cn(
                    'flex h-11 items-center justify-center gap-2 rounded-xl border text-body-sm font-semibold transition-all cursor-pointer',
                    category === 'RURAL'
                      ? 'border-primary-600 bg-primary-50/70 text-primary-700 font-bold shadow-xs ring-1 ring-primary-300/40'
                      : 'border-line bg-surface text-ink-muted hover:border-neutral-300',
                  )}
                >
                  <Landmark size={16} />
                  <span>Rural (Gram Panchayat)</span>
                </button>
              </div>
            </div>

            {/* 2) Administrative Hierarchy (District & Taluka / City / Village) */}
            <div className="space-y-3">
              <Input
                label="District"
                required
                value={district}
                onChange={(event) => {
                  setDistrict(event.target.value);
                  setErrors((prev) => ({ ...prev, district: '' }));
                }}
                placeholder="District"
                {...(errors.district ? { error: errors.district } : {})}
              />

              {category === 'URBAN' ? (
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
                    value={taluka}
                    {...(errors.taluka ? { error: errors.taluka } : {})}
                    onChange={(event) => {
                      setTaluka(event.target.value);
                      setErrors((prev) => ({ ...prev, taluka: '' }));
                    }}
                  />
                </div>
              ) : (
                <div className="grid grid-cols-2 gap-3">
                  <Input
                    label="Taluka"
                    required
                    placeholder="e.g. Haveli / Daund"
                    value={taluka}
                    {...(errors.taluka ? { error: errors.taluka } : {})}
                    onChange={(event) => {
                      setTaluka(event.target.value);
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

            {/* 3) Package Address with Location Icon inside rightSlot */}
            <Input
              label="Package site address / chainage"
              required
              value={line1}
              onChange={(event) => {
                setLine1(event.target.value);
                setErrors((prev) => ({ ...prev, line1: '' }));
              }}
              placeholder="Plot, chainage (KM), building or road address"
              {...(errors.line1 ? { error: errors.line1 } : {})}
              rightSlot={
                <button
                  type="button"
                  aria-label="Select location on map"
                  title="Select location on map"
                  onClick={() => setMapOpen(true)}
                  className="flex size-8 items-center justify-center rounded-lg text-primary-700 hover:bg-primary-100/70 transition-colors cursor-pointer"
                >
                  <MapPin size={18} />
                </button>
              }
            />

            {/* 4) PIN code & State */}
            <div className="grid grid-cols-2 gap-3">
              <Input
                label="PIN code"
                required
                inputMode="numeric"
                maxLength={6}
                value={pincode}
                onChange={(event) => {
                  setPincode(event.target.value.replace(/\D/g, '').slice(0, 6));
                  setErrors((prev) => ({ ...prev, pincode: '' }));
                }}
                placeholder="400001"
                {...(errors.pincode ? { error: errors.pincode } : {})}
              />
              <Input
                label="State"
                value={state}
                onChange={(event) => setState(event.target.value)}
                placeholder="Maharashtra"
              />
            </div>
          </div>

          {/* Assign Supervisor Dropdown */}
          <div className="rounded-xl border border-line bg-surface-raised p-3.5 space-y-3 pt-3">
            <div className="flex items-center gap-2">
              <UserCheck size={16} className="text-primary-600" />
              <label className="text-caption font-bold uppercase tracking-wider text-ink">
                Assign Supervisor
              </label>
            </div>

            <Select
              label="Select Registered Supervisor"
              placeholder="Choose a registered supervisor"
              value={selectedSupervisorCode}
              options={(supervisors.data ?? []).map((s: SupervisorInfo) => ({
                value: s.employeeCode,
                label: `${s.name} (${s.employeeCode} · ${s.mobileNumber})`,
              }))}
              onChange={(event) => setSelectedSupervisorCode(event.target.value)}
            />

            {selectedSupervisor && (
              <div className="flex items-center justify-between rounded-lg border border-primary-200 bg-primary-50/60 p-2.5 text-body-sm animate-in fade-in duration-150">
                <div>
                  <p className="font-semibold text-ink">{selectedSupervisor.name}</p>
                  <p className="text-caption text-ink-muted">
                    ID: {selectedSupervisor.employeeCode} · Mobile: {selectedSupervisor.mobileNumber}
                  </p>
                </div>
                <span className="flex size-6 items-center justify-center rounded-full bg-primary-600 text-white shadow-2xs">
                  <Check size={13} strokeWidth={2.5} />
                </span>
              </div>
            )}
          </div>
        </Surface>

        {/* Submit Button */}
        <div className="px-4">
          <Button
            size="lg"
            fullWidth
            onClick={handleSubmit}
            loading={submitting}
            leftIcon={<Boxes size={18} />}
          >
            Save package
          </Button>
        </div>
      </div>

      {/* Interactive Map Picker Overlay */}
      {mapOpen && (
        <LocationMapOverlay
          centre={siteGeo ?? STATE_CENTRE}
          value={siteGeo}
          onChange={setSiteGeo}
          onClose={() => setMapOpen(false)}
          onSave={(point) => {
            setSiteGeo(point);
            if (!line1.trim()) {
              setLine1(`Package Site (${point.latitude.toFixed(5)}, ${point.longitude.toFixed(5)})`);
            }
            setMapOpen(false);
          }}
        />
      )}
    </Screen>
  );
}
