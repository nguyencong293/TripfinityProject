import React, { useState, useCallback, useRef } from "react";
import {
  GoogleMap,
  LoadScript,
  Marker,
  Autocomplete,
} from "@react-google-maps/api";
import { MapPin, Loader2, Search } from "lucide-react";

const GOOGLE_MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY || "AIzaSyBEHT1sEuXBrx5zV5KG2nUOAXV1EtqbLB0";
const LIBRARIES: ("places")[] = ["places"];

// Default center (Vietnam)
const DEFAULT_CENTER = {
  lat: 16.0544,
  lng: 108.2022,
};

const MAP_CONTAINER_STYLE = {
  width: "100%",
  height: "400px",
  borderRadius: "8px",
};

const MAP_OPTIONS = {
  disableDefaultUI: false,
  zoomControl: true,
  streetViewControl: false,
  mapTypeControl: true,
  fullscreenControl: true,
};

export interface LocationData {
  address: string;
  latitude: number;
  longitude: number;
}

interface MapPickerProps {
  onLocationSelect: (data: LocationData) => void;
  initialLocation?: LocationData | null;
  className?: string;
}

const MapPicker: React.FC<MapPickerProps> = ({
  onLocationSelect,
  initialLocation,
  className = "",
}) => {
  const [selectedPosition, setSelectedPosition] = useState<{
    lat: number;
    lng: number;
  } | null>(
    initialLocation
      ? { lat: initialLocation.latitude, lng: initialLocation.longitude }
      : null
  );

  const [address, setAddress] = useState<string>(
    initialLocation?.address || ""
  );
  
  const [searchInput, setSearchInput] = useState<string>("");
  const [autocomplete, setAutocomplete] = useState<google.maps.places.Autocomplete | null>(null);
  const searchInputRef = useRef<HTMLInputElement>(null);

  // Setup Autocomplete
  const onLoadAutocomplete = useCallback((autocompleteInstance: google.maps.places.Autocomplete) => {
    setAutocomplete(autocompleteInstance);
  }, []);

  const onPlaceChanged = useCallback(() => {
    if (autocomplete) {
      const place = autocomplete.getPlace();
      
      if (place.geometry && place.geometry.location) {
        const lat = place.geometry.location.lat();
        const lng = place.geometry.location.lng();
        const formattedAddress = place.formatted_address || "";

        setSelectedPosition({ lat, lng });
        setAddress(formattedAddress);
        setSearchInput(formattedAddress);

        onLocationSelect({
          address: formattedAddress,
          latitude: lat,
          longitude: lng,
        });

        console.log("✅ Đã chọn địa điểm:", formattedAddress, lat, lng);
      }
    }
  }, [autocomplete, onLocationSelect]);

  // Handle map click
  const onMapClick = useCallback(
    (e: google.maps.MapMouseEvent) => {
      if (e.latLng) {
        const lat = e.latLng.lat();
        const lng = e.latLng.lng();

        setSelectedPosition({ lat, lng });

        // Sử dụng Geocoding API để lấy địa chỉ
        const geocoder = new google.maps.Geocoder();
        geocoder.geocode({ location: { lat, lng } }, (results, status) => {
          if (status === "OK" && results && results[0]) {
            const formattedAddress = results[0].formatted_address;
            setAddress(formattedAddress);
            setSearchInput(formattedAddress);

            onLocationSelect({
              address: formattedAddress,
              latitude: lat,
              longitude: lng,
            });

            console.log("✅ Đã chọn vị trí:", formattedAddress, lat, lng);
          } else {
            // Fallback nếu Geocoding API lỗi
            const coordsText = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
            setAddress(coordsText);
            setSearchInput(coordsText);

            onLocationSelect({
              address: coordsText,
              latitude: lat,
              longitude: lng,
            });

            console.warn("⚠️ Không lấy được địa chỉ, dùng tọa độ:", coordsText);
          }
        });
      }
    },
    [onLocationSelect]
  );

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
          {/* Search Box */}
          <div className="relative">
            <Autocomplete
              onLoad={onLoadAutocomplete}
              onPlaceChanged={onPlaceChanged}
            >
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 icon-secondary pointer-events-none" />
                <input
                  ref={searchInputRef}
                  type="text"
                  value={searchInput}
                  onChange={(e) => setSearchInput(e.target.value)}
                  placeholder="Tìm kiếm địa điểm..."
                  className="w-full pl-10 pr-4 py-2.5 rounded-lg border theme-border bg-light-surface dark:bg-dark-surface theme-text-primary placeholder-light-text-tertiary dark:placeholder-dark-text-tertiary focus:outline-none focus:ring-2 focus:ring-brand-primary focus:border-transparent"
                />
              </div>
            </Autocomplete>
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
                <p className="theme-text-secondary text-caption-mobile sm:text-caption-tablet">
                  {address}
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
