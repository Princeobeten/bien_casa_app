import 'dart:math';
import 'package:bien_casa/app/screens/user/home/heart_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places_sdk;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Flag to track if map loading failed
  final bool _mapLoadingFailed = false;
  late GoogleMapController _mapController;
  late TextEditingController _searchController;
  late LatLng _propertyLocation;
  late String _propertyName;
  late String _propertyAddress;
  late String? _propertyImage;
  late String _propertyType;
  late String _propertySize;
  late String _propertyPrice;
  late List<dynamic> _landmarks;

  // Heart icon state
  final bool _isFavorite = false;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  // Store landmark positions for cards
  final List<Map<String, dynamic>> _landmarkPositions = [];

  // Google Places SDK
  places_sdk.FlutterGooglePlacesSdk? _placesClient;
  List<places_sdk.AutocompletePrediction> _predictions = [];
  bool _showPredictions = false;

  @override
  void initState() {
    super.initState();

    // Get arguments passed from property detail screen first
    final args = Get.arguments as Map<String, dynamic>;

    // Initialize property data from arguments
    _propertyLocation = LatLng(
      args['latitude'] as double,
      args['longitude'] as double,
    );
    _propertyName = args['propertyName'] as String;
    _propertyAddress = args['propertyAddress'] as String;
    _propertyImage = args['propertyImage'] as String?;
    _propertyType = args['propertyType'] as String;
    _propertySize = args['propertySize'] as String;
    _propertyPrice = args['propertyPrice'] as String;
    _landmarks = args['landmarks'] as List<dynamic>;

    // Initialize controllers after property data is set
    _searchController = TextEditingController();
    _searchController.text = _propertyName; // Now safe to use _propertyName

    // Initialize Google Places SDK
    _initPlacesClient();

    // Create markers and circles
    _setupMarkers();
  }

  // Initialize Google Places SDK client
  Future<void> _initPlacesClient() async {
    try {
      // Use the same API key as in Google Maps
      _placesClient = places_sdk.FlutterGooglePlacesSdk(
        'AIzaSyDZaLuHJN_mn01DBjNjsEEsl-DdQdvYzwM',
      );
      // Note: Newer version doesn't require explicit initialization
    } catch (e) {
      print('Error initializing Places SDK: $e');
    }
  }

  // Get place predictions based on search query
  Future<void> _getPlacePredictions(String query) async {
    if (_placesClient == null || query.isEmpty) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    try {
      final places_sdk.FindAutocompletePredictionsResponse response =
          await _placesClient!.findAutocompletePredictions(query);

      setState(() {
        _predictions = response.predictions;
        _showPredictions = _predictions.isNotEmpty;
      });
    } catch (e) {
      print('Error getting place predictions: $e');
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
    }
  }

  // Handle selection of a place prediction
  Future<void> _selectPlace(
    places_sdk.AutocompletePrediction prediction,
  ) async {
    try {
      final places_sdk.FetchPlaceResponse response = await _placesClient!
          .fetchPlace(
            prediction.placeId,
            fields: [places_sdk.PlaceField.Location],
          );

      final location = response.place?.latLng;
      if (location != null) {
        final newLatLng = LatLng(location.lat, location.lng);

        // Update map camera position
        _mapController.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 15));

        setState(() {
          _searchController.text = prediction.primaryText;
          _showPredictions = false;
        });
      } else {
        print('Place location data is null');
        setState(() {
          _searchController.text = prediction.primaryText;
          _showPredictions = false;
        });
      }
    } catch (e) {
      print('Error fetching place details: $e');
      // Still update the search text and hide predictions even if there's an error
      setState(() {
        _searchController.text = prediction.primaryText;
        _showPredictions = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Note: Newer version of Places SDK doesn't have a dispose method
    super.dispose();
  }

  // Build landmark cards to display on map
  List<Widget> _buildLandmarkCards() {
    List<Widget> cards = [];

    // Create a card for each landmark
    for (int i = 0; i < _landmarkPositions.length; i++) {
      // Calculate position - distribute cards around the map
      // This is a simple distribution method for demo purposes
      final double left = 20.0 + (i % 2) * 180.0;
      final double top = 120.0 + (i ~/ 2) * 100.0;

      // Generate a random distance in km (1-20)
      final int distance = Random().nextInt(20) + 1;

      cards.add(
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: 150,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Landmark image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                  child: Container(
                    width: 50,
                    height: double.infinity,
                    color: const Color(0xFF333333).withValues(alpha: 0.2),
                    child: Center(
                      child: Icon(
                        _getLandmarkIcon(_landmarkPositions[i]['name']),
                        color: const Color(0xFF000000),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Landmark details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Landmark name
                        Text(
                          _landmarkPositions[i]['name'],
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Distance
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 8.5,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$distance Km',
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 8.5,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return cards;
  }

  // Helper method to get appropriate icon for landmark type
  IconData _getLandmarkIcon(String landmarkName) {
    final name = landmarkName.toLowerCase();

    if (name.contains('school') ||
        name.contains('university') ||
        name.contains('college')) {
      return Icons.school;
    } else if (name.contains('hospital') ||
        name.contains('clinic') ||
        name.contains('medical')) {
      return Icons.local_hospital;
    } else if (name.contains('park') || name.contains('garden')) {
      return Icons.park;
    } else if (name.contains('mall') ||
        name.contains('shop') ||
        name.contains('store')) {
      return Icons.shopping_cart;
    } else if (name.contains('restaurant') ||
        name.contains('cafe') ||
        name.contains('food')) {
      return Icons.restaurant;
    } else if (name.contains('gym') || name.contains('fitness')) {
      return Icons.fitness_center;
    } else if (name.contains('bank') || name.contains('atm')) {
      return Icons.account_balance;
    } else if (name.contains('bus') ||
        name.contains('train') ||
        name.contains('station')) {
      return Icons.directions_bus;
    } else if (name.contains('airport')) {
      return Icons.flight;
    } else {
      return Icons.location_on;
    }
  }

  void _setupMarkers() {
    // Add marker for the property location
    _markers.add(
      Marker(
        markerId: const MarkerId('property_location'),
        position: _propertyLocation,
        infoWindow: InfoWindow(title: _propertyName),
      ),
    );

    // Add circles for radius visualization
    _circles.add(
      Circle(
        circleId: const CircleId('inner_circle'),
        center: _propertyLocation,
        radius: 300, // 300 meters radius
        fillColor: Colors.black.withOpacity(0.3),
        strokeWidth: 0,
      ),
    );

    _circles.add(
      Circle(
        circleId: const CircleId('outer_circle'),
        center: _propertyLocation,
        radius: 600, // 600 meters radius
        fillColor: Colors.black.withOpacity(0.1),
        strokeWidth: 0,
      ),
    );

    // Add markers for landmarks (randomly positioned around property)
    if (_landmarks.isNotEmpty) {
      // Define a radius around the property for landmarks (in degrees)
      const double landmarkRadius = 0.005; // ~500m

      // Create a random number generator
      final random = Random();

      // Clear previous landmark positions
      _landmarkPositions.clear();

      // Add markers for each landmark
      for (int i = 0; i < _landmarks.length; i++) {
        // Generate random offset within the radius
        final double latOffset = (random.nextDouble() * 2 - 1) * landmarkRadius;
        final double lngOffset = (random.nextDouble() * 2 - 1) * landmarkRadius;

        // Create landmark position
        final landmarkPosition = LatLng(
          _propertyLocation.latitude + latOffset,
          _propertyLocation.longitude + lngOffset,
        );

        // Store landmark position and name for card display
        _landmarkPositions.add({
          'position': landmarkPosition,
          'name': _landmarks[i].toString(),
        });

        // Add marker
        _markers.add(
          Marker(
            markerId: MarkerId('landmark_$i'),
            position: landmarkPosition,
            infoWindow: InfoWindow(title: _landmarks[i].toString()),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to verify data
    print('MapScreen build - Property Location: $_propertyLocation');
    print('MapScreen build - Markers: ${_markers.length}');
    print('MapScreen build - Circles: ${_circles.length}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Map with error handling
          _mapLoadingFailed
              ? Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Map loading failed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: $_propertyAddress',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _propertyLocation,
                  zoom: 15.0,
                ),
                markers: _markers,
                circles: _circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  print('Map created successfully!');
                  _mapController = controller;
                },
              ),

          // Landmark cards on map
          ..._buildLandmarkCards(),

          // Back button
          Positioned(
            top: 60,
            left: 28,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
          ),

          // Search bar with predictions
          Positioned(
            top: 50,
            left: 70,
            right: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search input field
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/search icon.svg',
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search location',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          onChanged: (value) {
                            // Get predictions as user types
                            _getPlacePredictions(value);
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _predictions = [];
                            _showPredictions = false;
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.black),
                      ),
                    ],
                  ),
                ),

                // Predictions list
                if (_showPredictions)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            prediction.primaryText,
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            prediction.secondaryText ?? '',
                            style: const TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () => _selectPlace(prediction),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Property card at bottom - styled like LocationPropertyCard
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Center map on property location when card is tapped
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(_propertyLocation, 15),
                );
              },
              child: Container(
                height: 127,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x26000000),
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Property image with heart icon overlay
                    Stack(
                      children: [
                        // Property image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: SizedBox(
                            width: 136,
                            height: double.infinity,
                            child:
                                _propertyImage != null
                                    ? _propertyImage!.startsWith('http')
                                        ? Image.network(
                                          _propertyImage!,
                                          width: 136,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 136,
                                              height: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        )
                                        : Image.asset(
                                          _propertyImage!,
                                          width: 136,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 136,
                                              height: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        )
                                    : Container(
                                      width: 136,
                                      height: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.home,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                          ),
                        ),
                        // Heart icon overlay
                        Positioned(
                          top: 10,
                          left: 10,
                          child: HeartIcon(isWhite: false),
                        ),
                      ],
                    ),
                    // Property details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Property name
                            Text(
                              _propertyName,
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Address with location icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.black,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _propertyAddress,
                                    style: const TextStyle(
                                      fontFamily: 'ProductSans',
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Property type and size
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/sqm.svg',
                                  height: 14,
                                  width: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_propertySize - $_propertyType',
                                  style: const TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Price
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/naira.svg',
                                  width: 13,
                                  height: 13,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _propertyPrice,
                                  style: const TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
