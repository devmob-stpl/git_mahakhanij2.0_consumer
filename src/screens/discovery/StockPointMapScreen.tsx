import { useState } from 'react';

import { useNavigate } from 'react-router-dom';
import { ChevronUp, Crosshair, SlidersHorizontal, Warehouse, X } from 'lucide-react';
import type { GeoPoint, ID, StockPointSearchResult } from '@/domain';
import { formatQuantity, statusPresentation } from '@/rules';
import {
  BottomSheet,
  Button,
  EmptyState,
  ErrorState,
  ListGroup,
  ListRow,
  SearchInput,
  Select,
  StatusBadge,
  Surface,
} from '@/design-system';
import { ROUTES, Screen } from '@/navigation';
import { mineralRepository, stockPointRepository, useAsync } from '@/data';
import { useOperatingContext } from '@/state';
import { useCopy } from '@/content';
import { StockPointMap } from './StockPointMap';

const DISTANCE_OPTIONS = [
  { value: '', label: 'Any distance' },
  { value: '25', label: 'Within 25 km' },
  { value: '50', label: 'Within 50 km' },
  { value: '100', label: 'Within 100 km' },
];

const SEARCH_LOCATIONS = [
  { name: 'mumbai', latitude: 19.076, longitude: 72.8777 },
  { name: 'pune', latitude: 18.5204, longitude: 73.8567 },
  { name: 'nagpur', latitude: 21.1458, longitude: 79.0882 },
  { name: 'nashik', latitude: 19.9975, longitude: 73.7898 },
  { name: 'thane', latitude: 19.2183, longitude: 72.9781 },
  { name: 'kalyan', latitude: 19.2403, longitude: 73.1305 },
  { name: 'dombivli', latitude: 19.2184, longitude: 73.0867 },
  { name: 'navi mumbai', latitude: 19.033, longitude: 73.0297 },
  { name: 'chhatrapati sambhajinagar', latitude: 19.8762, longitude: 75.3433 },
  { name: 'aurangabad', latitude: 19.8762, longitude: 75.3433 },
  { name: 'solapur', latitude: 17.6599, longitude: 75.9064 },
  { name: 'kolhapur', latitude: 16.705, longitude: 74.2433 },
  { name: 'satara', latitude: 17.6805, longitude: 74.0183 },
  { name: 'ahilyanagar', latitude: 19.0948, longitude: 74.748 },
  { name: 'ahmednagar', latitude: 19.0948, longitude: 74.748 },
  { name: 'amravati', latitude: 20.9374, longitude: 77.7796 },
  { name: 'nanded', latitude: 19.1383, longitude: 77.321 },
  { name: 'jalgaon', latitude: 21.0077, longitude: 75.5626 },
  { name: 'haveli', latitude: 18.4908, longitude: 73.9142 },
  { name: 'delhi', latitude: 28.6139, longitude: 77.209 },
];

function locationFromSearch(value: string) {
  const normalized = value.trim().toLowerCase();
  if (!normalized) return null;

  const nearMatch = normalized.match(/\bnear\s+([a-z]+(?:\s+[a-z]+)*)/);
  if (nearMatch) {
    const locationName = nearMatch[1].trim();
    const found = SEARCH_LOCATIONS.find(
      (location) =>
        locationName === location.name || locationName.startsWith(`${location.name} `),
    );
    if (found) return found;
  }

  return (
    SEARCH_LOCATIONS.find(
      (loc) =>
        normalized === loc.name ||
        normalized.includes(loc.name),
    ) ?? null
  );
}

export function StockPointMapScreen() {
  const context = useOperatingContext();
  const navigate = useNavigate();
  const t = useCopy();

  const [search, setSearch] = useState('');
  const [selectedMineralIds, setSelectedMineralIds] = useState<ID[]>([]);
  const [maxDistance, setMaxDistance] = useState('');
  const [inStockOnly, setInStockOnly] = useState(false);
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [selectedOnMap, setSelectedOnMap] = useState<ID | null>(null);
  const [drawerOpen, setDrawerOpen] = useState(true);
  const [noResultsDismissed, setNoResultsDismissed] = useState(false);

  // User live geolocation state
  const [userLocation, setUserLocation] = useState<GeoPoint | null>(null);
  const [locateTrigger, setLocateTrigger] = useState(0);
  const [isLocating, setIsLocating] = useState(false);

  const destination = context?.destination ?? null;
  const activeSearch = search.trim();
  const searchedLocation = locationFromSearch(activeSearch);
  const searchTerm = searchedLocation
    ? activeSearch
        .replace(/\bnear\s+[a-z]+(?:\s+[a-z]+)*/i, '')
        .replace(new RegExp(`\\b${searchedLocation.name}\\b`, 'i'), '')
        .replace(/\bstock\s*points?\b/i, '')
        .trim()
    : activeSearch;
  const defaultOrigin = destination?.geo ?? { latitude: 19.076, longitude: 72.877 };
  const searchRadiusKm = maxDistance
    ? Number(maxDistance)
    : searchedLocation
      ? 150
      : 100;

  const minerals = useAsync(() => mineralRepository.listAll(), []);

  const results = useAsync(
    () =>
      stockPointRepository.search({
        ...(searchTerm ? { search: searchTerm } : {}),
        ...(selectedMineralIds.length > 0 ? { mineralIds: selectedMineralIds } : {}),
        near: userLocation
          ? userLocation
          : searchedLocation
          ? { latitude: searchedLocation.latitude, longitude: searchedLocation.longitude }
          : defaultOrigin,
        maxDistanceKm: searchRadiusKm,
        ...(inStockOnly ? { availableOnly: true } : {}),
      }),
    [
      searchTerm,
      selectedMineralIds,
      maxDistance,
      inStockOnly,
      userLocation?.latitude,
      userLocation?.longitude,
      defaultOrigin.latitude,
      defaultOrigin.longitude,
      searchedLocation?.latitude,
      searchedLocation?.longitude,
    ],
  );

  const activeFilters =
    (selectedMineralIds.length > 0 ? 1 : 0) + (maxDistance ? 1 : 0) + (inStockOnly ? 1 : 0);
  const mineralName = (id: ID) =>
    minerals.data?.find((mineral) => mineral.id === id)?.name ?? 'Mineral';
  const mapOrigin = userLocation
    ? userLocation
    : searchedLocation
    ? { latitude: searchedLocation.latitude, longitude: searchedLocation.longitude }
    : defaultOrigin;
  const mapOriginLabel = userLocation
    ? 'Your Current Location'
    : searchedLocation?.name
    ? `${searchedLocation.name[0].toUpperCase()}${searchedLocation.name.slice(1)}`
    : destination?.label ?? 'Current location';

  function handleLocateMe() {
    setIsLocating(true);
    if (typeof navigator !== 'undefined' && navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setIsLocating(false);
          const loc: GeoPoint = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
          };
          setUserLocation(loc);
          setLocateTrigger((prev) => prev + 1);
        },
        () => {
          setIsLocating(false);
          // Fallback to active destination / default origin
          setUserLocation(defaultOrigin);
          setLocateTrigger((prev) => prev + 1);
        },
        { enableHighAccuracy: true, timeout: 6000 },
      );
    } else {
      setIsLocating(false);
      setUserLocation(defaultOrigin);
      setLocateTrigger((prev) => prev + 1);
    }
  }

  // Dynamic bottom sheet title
  const resultCount = results.data?.length ?? 0;
  const selectedMineralLabels = selectedMineralIds.map(mineralName).join(', ');
  
  let drawerTitle = 'Nearby mineral places';
  if (activeSearch && searchedLocation) {
    drawerTitle = `Mineral places near ${searchedLocation.name[0].toUpperCase()}${searchedLocation.name.slice(1)}`;
  } else if (activeSearch) {
    drawerTitle = `Results for "${activeSearch}"`;
  } else if (selectedMineralIds.length > 0) {
    drawerTitle = `Mineral places with ${selectedMineralLabels}`;
  } else if (userLocation) {
    drawerTitle = 'Mineral places near your location';
  }

  return (
    <Screen
      title={t.discovery.title}
      onBack
      className="relative flex min-h-0 flex-1 flex-col overflow-hidden"
    >
      <div className="absolute inset-0 z-0 overflow-hidden bg-neutral-100">
        <StockPointMap
          origin={mapOrigin}
          originLabel={mapOriginLabel}
          results={results.data ?? []}
          selectedId={selectedOnMap}
          onSelect={(id) => {
            setSelectedOnMap(id);
            setDrawerOpen(true);
          }}
          mineralName={mineralName}
          onViewDetails={(stockPointId) => navigate(ROUTES.stockPointDetails(stockPointId))}
          userLocation={userLocation}
          locateTrigger={locateTrigger}
        />
      </div>

      <div className="absolute inset-x-3 top-3 z-10 space-y-2">
        <form
          onSubmit={(event) => {
            event.preventDefault();
            setNoResultsDismissed(false);
            setDrawerOpen(true);
          }}
        >
          <SearchInput
            value={search}
            onChange={(val) => {
              setSearch(val);
              setNoResultsDismissed(false);
            }}
            onClear={() => setSearch('')}
            placeholder={t.discovery.searchPlaceholder}
            className="rounded-2xl border border-line/80 shadow-e3"
            endAdornment={
              <button
                type="button"
                aria-label={t.discovery.filters}
                onClick={() => setFiltersOpen(true)}
                className={[
                  'relative flex size-8 shrink-0 items-center justify-center rounded-full',
                  'text-ink-muted transition-colors hover:bg-neutral-200',
                  activeFilters > 0 ? 'text-primary-700' : '',
                ].join(' ')}
              >
                <SlidersHorizontal size={16} aria-hidden />
                {activeFilters > 0 && (
                  <span className="absolute right-0.5 top-0.5 size-1.5 rounded-full bg-primary-600" />
                )}
              </button>
            }
          />
        </form>

        {/* Selected Mineral Filter Chips */}
        {selectedMineralIds.length > 0 && (
          <div className="flex flex-wrap gap-1.5 px-0.5">
            {selectedMineralIds.map((id) => (
              <span
                key={id}
                className="inline-flex items-center gap-1 rounded-full bg-surface/95 px-2.5 py-1 text-[11px] font-semibold text-primary-800 shadow-xs border border-primary-200 backdrop-blur"
              >
                <span>{mineralName(id)}</span>
                <button
                  type="button"
                  onClick={() =>
                    setSelectedMineralIds((prev) => prev.filter((item) => item !== id))
                  }
                  className="rounded-full p-0.5 hover:bg-primary-100 text-primary-600"
                >
                  <X size={12} />
                </button>
              </span>
            ))}
          </div>
        )}
      </div>

      {results.loading && (
        <div className="absolute left-1/2 top-36 z-10 -translate-x-1/2 rounded-full bg-surface px-3.5 py-1.5 text-caption font-medium text-ink-secondary shadow-e2 border border-line flex items-center gap-2">
          <span className="size-2 rounded-full bg-primary-600 animate-ping" />
          Searching mineral places…
        </div>
      )}

      {results.error && (
        <div className="absolute inset-x-4 top-36 z-10">
          <ErrorState onRetry={results.reload} />
        </div>
      )}

      {results.data && results.data.length === 0 && !noResultsDismissed && (
        <div className="absolute inset-x-4 top-40 z-10">
          <Surface className="relative p-4 shadow-e2">
            <button
              type="button"
              aria-label="Close no results message"
              onClick={() => setNoResultsDismissed(true)}
              className="absolute right-3 top-3 flex size-8 items-center justify-center rounded-full text-ink-muted transition-colors hover:bg-neutral-100"
            >
              <X size={17} aria-hidden />
            </button>
            <EmptyState
              icon={<Warehouse size={22} />}
              title={t.discovery.noResults}
              description={t.discovery.noResultsBody}
              action={
                <Button
                  variant="secondary"
                  onClick={() => {
                    setSelectedMineralIds([]);
                    setMaxDistance('');
                    setInStockOnly(false);
                    setSearch('');
                    setNoResultsDismissed(false);
                  }}
                >
                  {t.discovery.clearAll}
                </Button>
              }
            />
          </Surface>
        </div>
      )}

      {/* Floating Current Location Button on Right Bottom */}
      <div
        className={[
          'absolute right-4 z-10 transition-all duration-300',
          drawerOpen && results.data && results.data.length > 0 ? 'bottom-[calc(50%+16px)]' : 'bottom-20',
        ].join(' ')}
      >
        <button
          type="button"
          onClick={handleLocateMe}
          title="See current location"
          aria-label="See current location"
          className="flex size-12 items-center justify-center rounded-full border border-line-strong bg-surface/95 text-primary-700 shadow-e3 backdrop-blur transition-all hover:bg-primary-50 active:scale-95 cursor-pointer ring-1 ring-black/5"
        >
          <Crosshair
            size={22}
            className={isLocating ? 'animate-spin text-primary-600' : 'text-primary-700'}
          />
        </button>
      </div>

      {results.data && results.data.length > 0 && (
        <div
          className={[
            'absolute inset-x-0 bottom-0 z-10 overflow-hidden rounded-t-2xl border-t border-line bg-surface/95 shadow-e3 backdrop-blur transition-[max-height]',
            drawerOpen ? 'max-h-[50%]' : 'max-h-16',
          ].join(' ')}
        >
          <button
            type="button"
            onClick={() => setDrawerOpen((open) => !open)}
            className="flex w-full items-center justify-between gap-3 px-4 py-3 text-left hover:bg-neutral-50/80 transition-colors"
            aria-expanded={drawerOpen}
          >
            <div className="flex items-center gap-2 min-w-0">
              <span className="block text-label font-semibold text-ink truncate">
                {drawerTitle}
              </span>
              <span className="shrink-0 rounded-full bg-primary-100 px-2 py-0.5 text-[11px] font-bold text-primary-800">
                {resultCount} {resultCount === 1 ? 'place' : 'places'}
              </span>
            </div>
            <ChevronUp size={18} className={drawerOpen ? 'rotate-180 text-ink-muted' : 'text-ink-muted'} />
          </button>
          {drawerOpen && (
            <ListGroup className="max-h-[calc(50vh-64px)] overflow-y-auto px-2 pb-2">
              {results.data.map((result, index) => (
                <StockPointRow
                  key={result.stockPoint.id}
                  result={result}
                  index={index + 1}
                  showIndex
                  hasDestination={Boolean(destination || userLocation || searchedLocation)}
                  mineralName={mineralName}
                  highlighted={result.stockPoint.id === selectedOnMap}
                  selectedMineralIds={selectedMineralIds}
                  onOpen={() => navigate(ROUTES.stockPointDetails(result.stockPoint.id))}
                />
              ))}
            </ListGroup>
          )}
        </div>
      )}

      <BottomSheet
        open={filtersOpen}
        onClose={() => setFiltersOpen(false)}
        title={t.discovery.filters}
        footer={
          <div className="flex gap-2">
            <Button
              variant="secondary"
              fullWidth
              onClick={() => {
                setSelectedMineralIds([]);
                setMaxDistance('');
                setInStockOnly(false);
              }}
            >
              {t.discovery.clearAll}
            </Button>
            <Button fullWidth onClick={() => setFiltersOpen(false)}>
              {t.discovery.apply}
            </Button>
          </div>
        }
      >
        <div className="space-y-4 px-4 pb-4">
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="text-label font-semibold text-ink">
                {t.discovery.mineral}
                {selectedMineralIds.length > 0 && (
                  <span className="ml-1.5 rounded-full bg-primary-100 px-2 py-0.5 text-[11px] font-bold text-primary-800">
                    {selectedMineralIds.length} selected
                  </span>
                )}
              </label>
              {selectedMineralIds.length > 0 ? (
                <button
                  type="button"
                  onClick={() => setSelectedMineralIds([])}
                  className="text-caption font-semibold text-primary-700 hover:underline cursor-pointer"
                >
                  Clear
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => setSelectedMineralIds((minerals.data ?? []).map((m) => m.id))}
                  className="text-caption font-semibold text-primary-700 hover:underline cursor-pointer"
                >
                  Select all
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 gap-2 max-h-56 overflow-y-auto pr-1">
              {(minerals.data ?? []).map((mineral) => {
                const isSelected = selectedMineralIds.includes(mineral.id);
                return (
                  <label
                    key={mineral.id}
                    className={`flex items-center justify-between gap-2.5 rounded-xl border p-2.5 cursor-pointer transition-all ${
                      isSelected
                        ? 'border-primary-500 bg-primary-50/60 shadow-xs ring-1 ring-primary-300'
                        : 'border-line bg-surface hover:bg-neutral-50'
                    }`}
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => {
                          setSelectedMineralIds((prev) =>
                            isSelected
                              ? prev.filter((id) => id !== mineral.id)
                              : [...prev, mineral.id]
                          );
                        }}
                        className="size-4 rounded text-primary-600 accent-primary-600"
                      />
                      <span className="text-body-sm font-medium text-ink truncate">
                        {mineral.name}
                      </span>
                    </div>
                  </label>
                );
              })}
            </div>
          </div>

          <Select
            label={t.discovery.withinDistance}
            value={maxDistance}
            options={DISTANCE_OPTIONS}
            onChange={(event) => setMaxDistance(event.target.value)}
            disabled={!destination}
          />

          <label className="flex min-h-[var(--touch-min)] items-center justify-between gap-3">
            <span className="text-body text-ink">{t.discovery.inStockOnly}</span>
            <input
              type="checkbox"
              checked={inStockOnly}
              onChange={(event) => setInStockOnly(event.target.checked)}
              className="size-5 accent-[var(--color-primary-600)]"
            />
          </label>
        </div>
      </BottomSheet>
    </Screen>
  );
}

function StockPointRow({
  result,
  index,
  showIndex,
  hasDestination,
  mineralName,
  highlighted,
  selectedMineralIds = [],
  onOpen,
}: {
  result: StockPointSearchResult;
  index: number;
  showIndex: boolean;
  hasDestination: boolean;
  mineralName: (id: ID) => string;
  highlighted: boolean;
  selectedMineralIds?: ID[];
  onOpen: () => void;
}) {
  const { stockPoint, distanceKm } = result;
  const status = statusPresentation.stockPoint(stockPoint.status);

  return (
    <ListRow
      className={[
        highlighted ? 'bg-primary-50/70 ring-1 ring-primary-300' : 'hover:bg-neutral-50/80',
        'rounded-xl transition-all cursor-pointer mb-1',
      ].join(' ')}
      leading={showIndex ? <span className="text-label font-semibold text-primary-800">{index}</span> : <Warehouse size={17} />}
      leadingTone={stockPoint.status === 'OPERATIONAL' ? 'primary' : 'neutral'}
      title={
        <div className="flex items-center justify-between gap-2">
          <span className="font-semibold text-ink truncate">{stockPoint.name}</span>
          {hasDestination && distanceKm > 0 && (
            <span className="shrink-0 text-caption font-semibold text-primary-700">
              {distanceKm.toFixed(1)} km away
            </span>
          )}
        </div>
      }
      subtitle={
        <div className="space-y-1">
          <p className="text-caption text-ink-secondary">
            {stockPoint.address.taluka}, {stockPoint.address.district}
          </p>
          <div className="flex flex-wrap gap-1 pt-0.5">
            {stockPoint.minerals.map((mineral) => {
              const isMatched = selectedMineralIds.includes(mineral.mineralId);
              return (
                <span
                  key={mineral.mineralId}
                  className={`inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 text-[11px] font-medium ${
                    isMatched
                      ? 'bg-primary-100 text-primary-800 ring-1 ring-primary-300 font-semibold'
                      : 'bg-neutral-100 text-ink-muted'
                  }`}
                >
                  <span>{mineralName(mineral.mineralId)}:</span>
                  <span className="font-semibold">{formatQuantity(mineral.availableQuantity)}</span>
                </span>
              );
            })}
          </div>
        </div>
      }
      meta={<StatusBadge label={status.label} tone={status.tone} size="sm" />}
      onClick={onOpen}
    />
  );
}
