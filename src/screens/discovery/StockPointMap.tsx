import { useEffect, useRef } from 'react';
import { Circle, MapContainer, Marker, Popup, TileLayer, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { GeoPoint, StockPointSearchResult } from '@/domain';

export interface StockPointMapProps {
  origin: GeoPoint;
  originLabel: string;
  results: StockPointSearchResult[];
  selectedId?: string | null;
  onSelect: (stockPointId: string) => void;
  mineralName: (mineralId: string) => string;
  onViewDetails: (stockPointId: string) => void;
  userLocation?: GeoPoint | null;
  locateTrigger?: number;
}

function makePointIcon(color: string, index: number, selected: boolean) {
  return L.divIcon({
    className: 'stock-point-map-pin',
    html: `
      <div style="
        width: 22px;
        height: 22px;
        border-radius: 9999px;
        background: ${color};
        border: 2px solid #ffffff;
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.22);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 10px;
        font-weight: 700;
        color: white;
        transform: ${selected ? 'scale(1.15)' : 'scale(1)'};
      ">${index}</div>
    `,
    iconSize: [22, 22],
    iconAnchor: [11, 11],
    popupAnchor: [0, -12],
  });
}

function makeOriginIcon(isLiveLocation = false) {
  return L.divIcon({
    className: 'stock-point-origin-pin',
    html: `
      <div style="
        width: 18px;
        height: 18px;
        border-radius: 9999px;
        background: ${isLiveLocation ? '#0284c7' : '#16a34a'};
        border: 3px solid ${isLiveLocation ? 'rgba(2,132,199,0.2)' : 'rgba(22,163,74,0.18)'};
        box-shadow: 0 0 0 5px ${isLiveLocation ? 'rgba(14,165,233,0.2)' : 'rgba(34,197,94,0.12)'};
      "></div>
    `,
    iconSize: [18, 18],
    iconAnchor: [9, 9],
  });
}

function FitMapBounds({
  origin,
  results,
  selectedId,
  userLocation,
  locateTrigger,
}: {
  origin: GeoPoint;
  results: StockPointSearchResult[];
  selectedId?: string | null;
  userLocation?: GeoPoint | null;
  locateTrigger?: number;
}) {
  const map = useMap();
  const prevTrigger = useRef(locateTrigger);

  useEffect(() => {
    if (locateTrigger && locateTrigger !== prevTrigger.current) {
      prevTrigger.current = locateTrigger;
      const target = userLocation ?? origin;
      map.flyTo([target.latitude, target.longitude], 13, {
        animate: true,
        duration: 0.9,
      });
    }
  }, [locateTrigger, userLocation, origin, map]);

  useEffect(() => {
    const points = results.map((result) => [result.stockPoint.geo.latitude, result.stockPoint.geo.longitude] as [number, number]);
    if (points.length === 0) {
      map.setView([origin.latitude, origin.longitude], 11);
      return;
    }

    const selected = selectedId
      ? results.find((result) => result.stockPoint.id === selectedId)
      : null;

    if (selected) {
      map.flyTo([selected.stockPoint.geo.latitude, selected.stockPoint.geo.longitude], 12, {
        animate: true,
        duration: 0.8,
      });
      return;
    }

    const bounds = L.latLngBounds(points);
    bounds.extend([origin.latitude, origin.longitude]);
    map.fitBounds(bounds.pad(0.3), { animate: true, maxZoom: 12 });
  }, [map, origin, results, selectedId]);

  return null;
}

export function StockPointMap({
  origin,
  originLabel,
  results,
  selectedId,
  onSelect,
  mineralName,
  onViewDetails,
  userLocation,
  locateTrigger,
}: StockPointMapProps) {
  const center: [number, number] = [origin.latitude, origin.longitude];
  const activeOrigin = userLocation ?? origin;
  const isCustomUserLoc = Boolean(userLocation);

  return (
    <div className="stock-point-map h-full w-full">
      <MapContainer
        center={center}
        zoom={11}
        scrollWheelZoom
        zoomControl={false}
        className="h-full w-full"
        style={{ height: '100%', width: '100%' }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />

        <Marker
          position={[activeOrigin.latitude, activeOrigin.longitude]}
          icon={makeOriginIcon(isCustomUserLoc)}
        >
          <Popup>{isCustomUserLoc ? 'Your Current Location' : originLabel}</Popup>
        </Marker>

        {results.map((result, index) => {
          const stockPoint = result.stockPoint;
          const selected = stockPoint.id === selectedId;
          const position: [number, number] = [stockPoint.geo.latitude, stockPoint.geo.longitude];

          return (
            <Marker
              key={stockPoint.id}
              position={position}
              icon={makePointIcon(selected ? '#0f766e' : '#2563eb', index + 1, selected)}
              eventHandlers={{
                click: () => onSelect(stockPoint.id),
              }}
            >
              <Popup>
                <div className="min-w-[160px] text-left">
                  <p className="text-body-sm font-semibold text-ink">{stockPoint.name}</p>
                  <p className="mt-1 text-body-sm text-ink-secondary">
                    {stockPoint.address.taluka}, {stockPoint.address.district}
                  </p>
                  <div className="mt-2 border-t border-line pt-2">
                    <p className="text-caption font-medium text-ink">Available minerals</p>
                    <div className="mt-1 space-y-0.5">
                      {stockPoint.minerals.map((mineral) => (
                        <p key={mineral.mineralId} className="text-caption text-ink-secondary">
                          {mineralName(mineral.mineralId)}: {mineral.availableQuantity.value}{' '}
                          {mineral.availableQuantity.unit}
                        </p>
                      ))}
                    </div>
                  </div>
                  <p className="mt-2 text-caption text-ink-muted">{result.distanceKm.toFixed(1)} km away</p>
                  <div className="mt-3 flex gap-2">
                    <button
                      type="button"
                      onClick={() => onViewDetails(stockPoint.id)}
                      className="flex-1 rounded-md bg-primary-600 px-2 py-1.5 text-caption font-medium text-white hover:bg-primary-700"
                    >
                      See details
                    </button>
                    <a
                      href={`tel:${stockPoint.contact.mobileNumber}`}
                      className="flex-1 rounded-md border border-line px-2 py-1.5 text-center text-caption font-medium text-primary-700 hover:bg-primary-50"
                    >
                      Call
                    </a>
                  </div>
                </div>
              </Popup>
            </Marker>
          );
        })}

        <Circle
          center={[activeOrigin.latitude, activeOrigin.longitude]}
          radius={3000}
          pathOptions={{
            color: isCustomUserLoc ? '#0284c7' : '#22c55e',
            fillOpacity: 0.08,
            weight: 1,
          }}
        />
        <FitMapBounds
          origin={origin}
          results={results}
          selectedId={selectedId}
          userLocation={userLocation}
          locateTrigger={locateTrigger}
        />
      </MapContainer>
    </div>
  );
}
