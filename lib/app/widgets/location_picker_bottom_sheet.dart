import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geolocator/geolocator.dart';
import '../config/app_constants.dart';

/// Result returned when user confirms a location.
class LocationPickerResult {
  final String address;
  final double? latitude;
  final double? longitude;

  const LocationPickerResult({
    required this.address,
    this.latitude,
    this.longitude,
  });
}

/// Default fallback for result (Lagos, Nigeria).
const _defaultLat = 6.5244;
const _defaultLng = 3.3792;

/// Shows a bottom sheet with Places autocomplete for picking an address.
/// Use for wallet, home owner property address, campaign location, etc.
///
/// Returns [LocationPickerResult] with address and optional lat/lng, or null if dismissed.
Future<LocationPickerResult?> showLocationPicker({
  required BuildContext context,
  String? initialAddress,
  double? initialLat,
  double? initialLng,
  String hintText = 'Search address or place...',
  String confirmLabel = 'Use this location',
  List<String>? countries,
}) async {
  return showModalBottomSheet<LocationPickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => _LocationPickerSheet(
          initialAddress: initialAddress,
          initialLat: initialLat,
          initialLng: initialLng,
          hintText: hintText,
          confirmLabel: confirmLabel,
          countries: countries ?? ['NG'],
        ),
  );
}

class _LocationPickerSheet extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;
  final String hintText;
  final String confirmLabel;
  final List<String> countries;

  const _LocationPickerSheet({
    this.initialAddress,
    this.initialLat,
    this.initialLng,
    required this.hintText,
    required this.confirmLabel,
    required this.countries,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late TextEditingController _searchController;
  FlutterGooglePlacesSdk? _places;
  List<AutocompletePrediction> _predictions = [];
  bool _isSearching = false;
  Timer? _debounce;
  double? _latitude;
  double? _longitude;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialAddress);
    _latitude = widget.initialLat;
    _longitude = widget.initialLng;
    _selectedAddress = widget.initialAddress ?? '';
    _initPlaces();
  }

  Future<void> _initPlaces() async {
    final key = AppConstants.googleMapsApiKey;
    if (key.isEmpty) return;
    try {
      _places = FlutterGooglePlacesSdk(key);
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchPlaces(value),
    );
  }

  Future<void> _searchPlaces(String query) async {
    if (_places == null || query.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final result = await _places!.findAutocompletePredictions(
        query,
        countries: widget.countries,
      );
      if (mounted) {
        setState(() {
          _predictions = result.predictions;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectPlace(AutocompletePrediction prediction) async {
    if (_places == null) return;
    setState(() => _predictions = []);
    try {
      final place = await _places!.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Location, PlaceField.Address],
      );
      if (!mounted) return;
      if (place.place?.latLng != null) {
        final loc = place.place!.latLng!;
        setState(() {
          _latitude = loc.lat;
          _longitude = loc.lng;
          _selectedAddress = prediction.fullText;
          _searchController.text = prediction.fullText;
        });
      } else {
        setState(() {
          _selectedAddress = prediction.fullText;
          _searchController.text = prediction.fullText;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedAddress = prediction.fullText;
          _searchController.text = prediction.fullText;
        });
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        if (_selectedAddress.isEmpty)
          _selectedAddress = '${pos.latitude}, ${pos.longitude}';
        _searchController.text = _selectedAddress;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    }
  }

  void _confirm() {
    final address =
        _searchController.text.trim().isEmpty
            ? _selectedAddress
            : _searchController.text.trim();
    Navigator.of(context).pop(
      LocationPickerResult(
        address:
            address.isNotEmpty
                ? address
                : '${_latitude ?? _defaultLat}, ${_longitude ?? _defaultLng}',
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title and close
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Choose location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'ProductSans',
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon:
                          _isSearching
                              ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 16,
                    ),
                  ),
                ),
                // Predictions list (suggestions below search bar)
                if (_predictions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _predictions.length,
                      separatorBuilder:
                          (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final p = _predictions[index];
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            p.primaryText,
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle:
                              p.secondaryText.isNotEmpty
                                  ? Text(
                                    p.secondaryText,
                                    style: TextStyle(
                                      fontFamily: 'ProductSans',
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                  : null,
                          onTap: () => _selectPlace(p),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Use current location — styled button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _useCurrentLocation,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade50,
                              Colors.cyan.shade100.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.cyan.shade200.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.my_location_rounded,
                              size: 22,
                              color: Colors.cyan.shade700,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Use current location',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.cyan.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.confirmLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
