import React, { useState, useRef, useEffect } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import type { Libraries } from '@react-google-maps/api';
import { MapPin, Search, Loader2 } from 'lucide-react';
import axios from 'axios';

export interface LocationData {
  address: string;
  location: string;
  latitude: number;
  longitude: number;
}

interface MapPickerProps {
  onLocationSelect: (location: LocationData) => void;
  initialLocation?: LocationData;
  className?: string;
}

interface NominatimResult {
  place_id: number;
  lat: string;
  lon: string;
  display_name: string;
  address?: {
    road?: string;
    suburb?: string;
    city?: string;
    state?: string;
    province?: string;
    country?: string;
  };
}

const GOOGLE_MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY || '';
const LIBRARIES: Libraries = [];

const MAP_CONTAINER_STYLE = {
  width: '100%',
  height: '400px',
};

const MAP_OPTIONS = {
  disableDefaultUI: false,
  zoomControl: true,
  streetViewControl: false,
  mapTypeControl: true,
  fullscreenControl: true,
};

const DEFAULT_CENTER = {
  lat: 16.0544, // Da Nang, Vietnam
  lng: 108.2022,
};

const MapPicker: React.FC<MapPickerProps> = ({
  onLocationSelect,
  initialLocation,
  className = '',
}) => {
  const [selectedPosition, setSelectedPosition] = useState<google.maps.LatLngLiteral | null>(
    initialLocation ? { lat: initialLocation.latitude, lng: initialLocation.longitude } : null
  );
  const [address, setAddress] = useState(initialLocation?.address || '');
  const [location, setLocation] = useState(initialLocation?.location || '');
  const [searchInput, setSearchInput] = useState('');
  const [searchResults, setSearchResults] = useState<NominatimResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [showResults, setShowResults] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);
  const resultsRef = useRef<HTMLDivElement>(null);

  // Debounce search
  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchInput.trim().length > 2) {
        searchNominatim(searchInput);
      } else {
        setSearchResults([]);
        setShowResults(false);
      }
    }, 500);

    return () => clearTimeout(timer);
  }, [searchInput]);

  // Click outside to close results
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (resultsRef.current && !resultsRef.current.contains(event.target as Node) &&
          searchInputRef.current && !searchInputRef.current.contains(event.target as Node)) {
        setShowResults(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const searchNominatim = async (query: string) => {
    setIsSearching(true);
    try {
      const response = await axios.get('https://nominatim.openstreetmap.org/search', {
        params: {
          q: query,
          format: 'json',
          'accept-language': 'vi',
          countrycodes: 'vn',
          limit: 5,
        },
        headers: {
          'User-Agent': 'TripfinitySupplier/1.0',
        },
      });
      setSearchResults(response.data);
      setShowResults(true);
    } catch (error) {
      console.error('Nominatim search error:', error);
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const extractLocation = (nominatimAddress?: NominatimResult['address']): string => {
    if (!nominatimAddress) return '';
    // Priority: city > state > province
    return nominatimAddress.city || nominatimAddress.state || nominatimAddress.province || '';
  };

  const selectSearchResult = (result: NominatimResult) => {
    const position = {
      lat: parseFloat(result.lat),
      lng: parseFloat(result.lon),
    };
    const extractedLocation = extractLocation(result.address);
    
    setSelectedPosition(position);
    setAddress(result.display_name);
    setLocation(extractedLocation);
    setSearchInput(result.display_name);
    setShowResults(false);

    onLocationSelect({
      address: result.display_name,
      location: extractedLocation,
      latitude: position.lat,
      longitude: position.lng,
    });
  };

  const onMapClick = async (e: google.maps.MapMouseEvent) => {
    if (e.latLng) {
      const lat = e.latLng.lat();
      const lng = e.latLng.lng();
      const position = { lat, lng };

      setSelectedPosition(position);

      // Reverse geocoding with Nominatim
      try {
        const response = await axios.get('https://nominatim.openstreetmap.org/reverse', {
          params: {
            lat: lat,
            lon: lng,
            format: 'json',
            'accept-language': 'vi',
          },
          headers: {
            'User-Agent': 'TripfinitySupplier/1.0',
          },
        });

        const addressText = response.data.display_name || `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
        const extractedLocation = extractLocation(response.data.address);
        
        setAddress(addressText);
        setLocation(extractedLocation);
        setSearchInput(addressText); // Update search input với địa chỉ từ map

        onLocationSelect({
          address: addressText,
          location: extractedLocation,
          latitude: lat,
          longitude: lng,
        });
      } catch (error) {
        console.error('Reverse geocoding error:', error);
        const fallbackAddress = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
        setAddress(fallbackAddress);
        setLocation('');
        setSearchInput(fallbackAddress); // Update search input với tọa độ

        onLocationSelect({
          address: fallbackAddress,
          location: '',
          latitude: lat,
          longitude: lng,
        });
      }
    }
  };

  return (
    <div className={`flex flex-col gap-4 ${className}`}>
      <LoadScript
        googleMapsApiKey={GOOGLE_MAPS_API_KEY}
        libraries={LIBRARIES}
        preventGoogleFontsLoading
        loadingElement={
          <div className="flex items-center justify-center h-[400px] border theme-border rounded-lg bg-light-secondary dark:bg-dark-secondary">
            <Loader2 className="w-8 h-8 animate-spin icon-brand" />
          </div>
        }
      >
        <div className="flex flex-col gap-3">
          {/* Search Box with Nominatim */}
          <div className="relative">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 icon-secondary pointer-events-none" />
              <input
                ref={searchInputRef}
                type="text"
                value={searchInput}
                onChange={(e) => setSearchInput(e.target.value)}
                onFocus={() => searchResults.length > 0 && setShowResults(true)}
                placeholder="Tìm kiếm địa điểm..."
                className="w-full pl-10 pr-4 py-2.5 rounded-lg border theme-border bg-light-surface dark:bg-dark-surface theme-text-primary placeholder-light-text-tertiary dark:placeholder-dark-text-tertiary focus:outline-none focus:ring-2 focus:ring-brand-primary focus:border-transparent"
              />
              {isSearching && (
                <Loader2 className="absolute right-3 top-1/2 transform -translate-y-1/2 w-5 h-5 animate-spin icon-brand" />
              )}
            </div>

            {/* Search Results Dropdown */}
            {showResults && searchResults.length > 0 && (
              <div
                ref={resultsRef}
                className="absolute top-full left-0 right-0 mt-1 bg-white dark:bg-gray-800 border theme-border rounded-lg shadow-xl z-50 max-h-60 overflow-y-auto"
                style={{ backgroundColor: 'var(--color-surface, #ffffff)' }}
              >
                {searchResults.map((result) => (
                  <button
                    key={result.place_id}
                    onClick={() => selectSearchResult(result)}
                    className="w-full px-4 py-3 text-left bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 border-b theme-border last:border-b-0 transition-colors"
                  >
                    <div className="flex items-start gap-2">
                      <MapPin className="w-4 h-4 icon-brand mt-0.5 flex-shrink-0" />
                      <p className="text-body2-mobile theme-text-primary">{result.display_name}</p>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Instruction text */}
          <div className="p-3 rounded-lg bg-light-secondary dark:bg-dark-secondary border theme-border">
            <p className="text-body2-mobile sm:text-body2-tablet theme-text-primary font-medium">
              📍 Chọn vị trí trên bản đồ
            </p>
            <p className="text-caption-mobile sm:text-caption-tablet theme-text-secondary mt-1">
              Tìm kiếm địa điểm hoặc click trực tiếp trên bản đồ
            </p>
          </div>

          {/* Map */}
          <div className="border theme-border rounded-lg overflow-hidden">
            <GoogleMap
              mapContainerStyle={MAP_CONTAINER_STYLE}
              center={selectedPosition || DEFAULT_CENTER}
              zoom={selectedPosition ? 15 : 6}
              onClick={onMapClick}
              options={MAP_OPTIONS}
            >
              {selectedPosition && <Marker position={selectedPosition} />}
            </GoogleMap>
          </div>

          {/* Selected location info */}
          {selectedPosition && (
            <div className="flex items-start gap-2 p-3 rounded-lg bg-light-secondary dark:bg-dark-secondary border theme-border">
              <MapPin className="w-5 h-5 icon-brand mt-0.5 flex-shrink-0" />
              <div className="flex flex-col gap-1">
                <p className="font-medium theme-text-primary text-body2-mobile sm:text-body2-tablet">
                  Vị trí đã chọn:
                </p>
                {location && (
                  <p className="theme-text-secondary text-caption-mobile sm:text-caption-tablet">
                    <strong>Khu vực:</strong> {location}
                  </p>
                )}
                <p className="theme-text-secondary text-caption-mobile sm:text-caption-tablet">
                  <strong>Địa chỉ:</strong> {address}
                </p>
                <p className="theme-text-tertiary text-caption-mobile">
                  Latitude: {selectedPosition.lat.toFixed(6)}, Longitude: {selectedPosition.lng.toFixed(6)}
                </p>
              </div>
            </div>
          )}
        </div>
      </LoadScript>
    </div>
  );
};

export default MapPicker;
