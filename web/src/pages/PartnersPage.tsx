import { useState, useEffect } from 'react';
import { partnerAPI } from '../services/api';
import { Partner } from '../types';
import { MapPin, Phone, Mail, CheckCircle, AlertCircle, Filter, Navigation, Loader } from 'lucide-react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';

delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

const typeColors: Record<string, string> = {
  SCA: 'bg-blue-100 text-blue-700 border-blue-200',
  PSB: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  RRB: 'bg-amber-100 text-amber-700 border-amber-200',
  'NBFC-MFI': 'bg-purple-100 text-purple-700 border-purple-200',
};

const typeMarkerColors: Record<string, string> = {
  SCA: '#3b82f6', PSB: '#10b981', RRB: '#f59e0b', 'NBFC-MFI': '#a855f7',
};

function createIcon(color: string) {
  return L.divIcon({
    className: '',
    html: `<div style="width:28px;height:28px;background:${color};border-radius:50%;border:3px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.3);"></div>`,
    iconSize: [28, 28], iconAnchor: [14, 14],
  });
}

function userIcon() {
  return L.divIcon({
    className: '',
    html: `<div style="width:20px;height:20px;background:#ef4444;border-radius:50%;border:3px solid white;box-shadow:0 2px 8px rgba(239,68,68,0.5);"></div>`,
    iconSize: [20, 20], iconAnchor: [10, 10],
  });
}

// Component to recenter map
function Recenter({ center }: { center: [number, number] }) {
  const map = useMap();
  useEffect(() => { map.setView(center, 10); }, [center, map]);
  return null;
}

export default function PartnersPage() {
  const [allPartners, setAllPartners] = useState<Partner[]>([]);
  const [nearbyPartners, setNearbyPartners] = useState<Partner[]>([]);
  const [loading, setLoading] = useState(true);
  const [nearbyLoading, setNearbyLoading] = useState(false);
  const [filter, setFilter] = useState('all');
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [locationError, setLocationError] = useState('');
  const [mapCenter, setMapCenter] = useState<[number, number]>([15, 78]);

  useEffect(() => {
    partnerAPI.list().then(r => { setAllPartners(r.partners); setLoading(false); });
    // Try to get geolocation
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const loc = { lat: pos.coords.latitude, lng: pos.coords.longitude };
          setUserLocation(loc);
          setMapCenter([loc.lat, loc.lng]);
        },
        () => setLocationError('Location access denied. Showing all partners.')
      );
    }
  }, []);

  // Auto-find nearby when location and schemes available
  useEffect(() => {
    if (userLocation && nearbyPartners.length === 0) {
      findNearby();
    }
  }, [userLocation]);

  const findNearby = async () => {
    if (!userLocation) return;
    setNearbyLoading(true);
    try {
      // Use MFS as default scheme for nearby search
      const r = await partnerAPI.nearby(userLocation.lat, userLocation.lng, 'MFS', 5);
      setNearbyPartners(r.partners || []);
    } catch (e) {
      console.error(e);
    } finally {
      setNearbyLoading(false);
    }
  };

  const filtered = filter === 'all' ? allPartners : allPartners.filter(p => p.type === filter);
  const partners = nearbyPartners.length > 0 ? nearbyPartners : filtered;

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-3xl font-bold text-surface-900">Channel Partners</h1>
        <p className="text-surface-500 mt-1">Find the nearest eligible lending partner</p>
      </div>

      {/* Location Bar */}
      <div className="card-elevated p-4 flex items-center gap-4 flex-wrap">
        <div className="flex items-center gap-2">
          <Navigation className="w-5 h-5 text-primary-500" />
          <span className="text-sm font-medium text-surface-700">
            {userLocation ? `${userLocation.lat.toFixed(4)}, ${userLocation.lng.toFixed(4)}` : 'Detecting location...'}
          </span>
        </div>
        {userLocation && (
          <button onClick={findNearby} disabled={nearbyLoading} className="btn-primary text-sm py-2 px-4 flex items-center gap-2">
            {nearbyLoading ? <Loader className="w-4 h-4 animate-spin" /> : <MapPin className="w-4 h-4" />}
            Find Nearby
          </button>
        )}
        {nearbyPartners.length > 0 && (
          <span className="badge-green">{nearbyPartners.length} nearby partners found</span>
        )}
        {locationError && <span className="text-xs text-amber-600">{locationError}</span>}
      </div>

      {/* Filter */}
      <div className="flex flex-wrap gap-2 items-center">
        <Filter className="w-4 h-4 text-surface-400" />
        {['all', 'SCA', 'PSB', 'RRB', 'NBFC-MFI'].map(t => (
          <button key={t} onClick={() => { setFilter(t); setNearbyPartners([]); }}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
              filter === t ? 'bg-primary-600 text-white shadow-md' : 'bg-surface-100 text-surface-600 hover:bg-surface-200'
            }`}>
            {t === 'all' ? 'All Partners' : t}
          </button>
        ))}
        <span className="ml-2 text-sm text-surface-500">{partners.length} partners</span>
      </div>

      {/* Map */}
      <div className="card-elevated overflow-hidden" style={{ height: '400px' }}>
        <MapContainer center={mapCenter} zoom={userLocation ? 10 : 5} style={{ height: '100%', width: '100%' }} scrollWheelZoom={true}>
          <TileLayer attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          <Recenter center={mapCenter} />
          {userLocation && <Marker position={[userLocation.lat, userLocation.lng]} icon={userIcon()}>
            <Popup><strong>You are here</strong></Popup>
          </Marker>}
          {partners.map(p => (
            <Marker key={p.id} position={[p.latitude, p.longitude]} icon={createIcon(typeMarkerColors[p.type] || '#666')}>
              <Popup>
                <div className="p-1">
                  <p className="font-semibold text-sm">{p.name}</p>
                  <p className="text-xs text-gray-500">{p.type} — {p.address}</p>
                  {p.distance !== undefined && <p className="text-xs mt-1 font-medium text-blue-600">📍 {p.distance} km away</p>}
                  <p className="text-xs mt-1">Fund: {p.fund_utilization}% | NPA: {p.npa_rate}%</p>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>

      {/* Legend */}
      <div className="flex flex-wrap gap-4 text-sm">
        {Object.entries(typeMarkerColors).map(([type, color]) => (
          <div key={type} className="flex items-center gap-2">
            <div className="w-4 h-4 rounded-full border-2 border-white shadow" style={{ background: color }} />
            <span className="text-surface-600">{type}</span>
          </div>
        ))}
      </div>

      {/* Partner Cards */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3].map(i => <div key={i} className="card p-6 animate-pulse"><div className="h-6 bg-surface-100 rounded w-3/4 mb-3" /><div className="h-4 bg-surface-100 rounded w-full" /></div>)}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {partners.map((partner, i) => (
            <div key={partner.id} className="card p-5 hover:shadow-lg transition-all duration-300 animate-slide-up" style={{ animationDelay: `${i * 50}ms` }}>
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-surface-900 text-sm leading-tight">{partner.name}</h3>
                  <span className={`inline-flex items-center mt-1 px-2 py-0.5 rounded-full text-xs font-semibold border ${typeColors[partner.type] || 'bg-surface-100 text-surface-600'}`}>
                    {partner.type}
                  </span>
                </div>
                {partner.is_eligible ? (
                  <span className="badge-green flex items-center gap-1"><CheckCircle className="w-3 h-3" /> Eligible</span>
                ) : (
                  <span className="badge-red flex items-center gap-1"><AlertCircle className="w-3 h-3" /> Restricted</span>
                )}
              </div>
              <div className="space-y-2 text-sm">
                <div className="flex items-start gap-2 text-surface-500">
                  <MapPin className="w-4 h-4 mt-0.5 shrink-0" />
                  <span className="line-clamp-2">{partner.address}</span>
                </div>
                {partner.distance !== undefined && (
                  <div className="flex items-center gap-2 text-primary-600 font-medium">
                    <Navigation className="w-4 h-4 shrink-0" />
                    <span>{partner.distance} km away</span>
                  </div>
                )}
                <div className="flex items-center gap-2 text-surface-500">
                  <Phone className="w-4 h-4 shrink-0" />
                  <span>{partner.phone}</span>
                </div>
                <div className="flex items-center gap-2 text-surface-500">
                  <Mail className="w-4 h-4 shrink-0" />
                  <span className="truncate">{partner.email}</span>
                </div>
              </div>
              <div className="mt-4 pt-3 border-t border-surface-100 grid grid-cols-2 gap-2 text-xs">
                <div>
                  <span className="text-surface-400">Fund Utilization</span>
                  <div className="mt-1 h-2 bg-surface-100 rounded-full overflow-hidden">
                    <div className={`h-full rounded-full ${partner.fund_utilization >= 80 ? 'bg-emerald-500' : 'bg-amber-500'}`} style={{ width: `${Math.min(partner.fund_utilization, 100)}%` }} />
                  </div>
                  <span className="font-medium text-surface-700">{partner.fund_utilization}%</span>
                </div>
                <div>
                  <span className="text-surface-400">NPA Rate</span>
                  <div className="mt-1 h-2 bg-surface-100 rounded-full overflow-hidden">
                    <div className={`h-full rounded-full ${partner.npa_rate < 5 ? 'bg-emerald-500' : partner.npa_rate < 10 ? 'bg-amber-500' : 'bg-red-500'}`} style={{ width: `${Math.min(partner.npa_rate * 4, 100)}%` }} />
                  </div>
                  <span className="font-medium text-surface-700">{partner.npa_rate}%</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
