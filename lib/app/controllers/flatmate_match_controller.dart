import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

// Import the RequestStatus enum for consistency
import '../screens/user/flatmate/home/_pages/flatmate_detail_screen.dart';

class FlatmateMatchController extends GetxController {
  // Map to track request status for all flatmates
  final flatmateRequestStatus = <String, RequestStatus>{}.obs;

  // Original list of all potential flatmates
  final allFlatmates = <Map<String, dynamic>>[].obs;

  // List of available flats for rent
  final flats = <Map<String, dynamic>>[].obs;

  // Filtered lists based on status
  // - unknown: candidates to view campaign (status: none)
  // - pending: matches with pending requests (status: pending)
  // - accepted: confirmed flatmates (status: accepted)
  // - declined: rejected flatmates (status: declined)

  // List of flatmate matches (potential flatmates, status: none)
  final matches = <Map<String, dynamic>>[].obs;

  // List of pending match requests (status: pending)
  final pendingMatches = <Map<String, dynamic>>[].obs;

  // List of accepted flatmates (status: accepted)
  final myFlatmates = <Map<String, dynamic>>[].obs;

  // List of declined flatmates (status: declined)
  final declinedMatches = <Map<String, dynamic>>[].obs;

  // Current flatmate (selected from any list)
  final Rx<Map<String, dynamic>> currentFlatmate = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    // Load all sample data
    loadAllFlatmates();
    loadFlats();

    // Distribute into appropriate lists based on status
    updateFlatmateLists();
  }

  // Method to load all flatmates data
  void loadAllFlatmates() {
    // Combine all flatmates into one list
    allFlatmates.value = [
      // Previously unknown flatmates (matches)
      {
        'id': '1',
        'name': 'Isaac Isà',
        'age': 29,
        'gender': 'Male',
        'religion': 'Islam',
        'occupation': 'ICT',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        'isVerified': true,
        'bio':
            'Tech enthusiast with a passion for clean living spaces. I enjoy quiet evenings and maintain a tidy home environment.',
        'company': 'Tech Solutions Ltd',
        'languages': ['English', 'Hausa', 'Arabic'],
      },
      {
        'id': '2',
        'name': 'Peace Jay',
        'age': 25,
        'gender': 'Female',
        'religion': 'Christian',
        'occupation': 'Stylist',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce',
        'isVerified': true,
        'bio':
            'Creative and organized. I love fashion and making spaces beautiful. Looking for a peaceful living arrangement.',
        'company': 'StyleHouse',
        'languages': ['English', 'Yoruba'],
      },
      {
        'id': '3',
        'name': 'Kate Kali',
        'age': 26,
        'gender': 'Female',
        'religion': 'Christian',
        'occupation': 'Writer',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
        'isVerified': true,
        'bio':
            'I am a writer who appreciates quiet spaces to work. I am clean, respectful of shared spaces, and enjoy deep conversations.',
        'company': 'Freelance Writer',
        'languages': ['English', 'French'],
      },

      // For pending matches
      {
        'id': '4',
        'name': 'Joe Sam',
        'age': 32,
        'gender': 'Male',
        'religion': 'Christian',
        'occupation': 'Lawyer',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
        'isVerified': true,
        'bio':
            'Professional lawyer with regular hours. I enjoy cooking and occasional social gatherings. I value cleanliness and respect.',
        'company': 'Legal Partners Associates',
        'languages': ['English', 'Igbo'],
      },
      {
        'id': '5',
        'name': 'Tony Abdul',
        'age': 25,
        'gender': 'Male',
        'religion': 'Islam',
        'occupation': 'Designer',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7',
        'isVerified': true,
        'bio':
            'Creative designer with a passion for aesthetics. I enjoy collaborative spaces but also value my private time.',
        'company': 'Creative Hub',
        'languages': ['English', 'Hausa'],
      },

      // Previously accepted flatmates
      {
        'id': '6',
        'name': 'Jane Sam',
        'age': 25,
        'gender': 'Female',
        'religion': 'Christian',
        'occupation': 'Fashion',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce',
        'isVerified': true,
        'bio':
            'Fashion designer who loves creating beautiful spaces. I am clean, organized and enjoy good conversation.',
        'languages': ['English', 'Yoruba'],
        'company': 'Style Studio',
      },
      {
        'id': '7',
        'name': 'Simeon Jay',
        'age': 27,
        'gender': 'Male',
        'religion': 'Christian',
        'occupation': 'ICT',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        'isVerified': true,
        'bio':
            'Tech enthusiast who enjoys a clean living environment. I am respectful of shared spaces.',
        'languages': ['English', 'Hausa'],
        'company': 'Tech Inc',
      },

      // For declined flatmates
      {
        'id': '8',
        'name': 'Santus Roy',
        'age': 30,
        'gender': 'Male',
        'religion': 'Christian',
        'occupation': 'Engineer',
        'budget': '550k - 600k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
        'isVerified': true,
        'bio':
            'Engineer who enjoys problem-solving and structured living. I am neat, organized, and respect shared spaces and privacy.',
        'company': 'BuildTech Engineering',
        'languages': ['English', 'Yoruba', 'Pidgin'],
      },
      {
        'id': '9',
        'name': 'Joseph Kay',
        'age': 23,
        'gender': 'Male',
        'religion': 'Christian',
        'occupation': 'Driver',
        'budget': '400k - 500k/yr',
        'location': 'Abuja',
        'image': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7',
        'isVerified': true,
        'bio':
            'Professional driver who is rarely home during the day. I enjoy peaceful evenings and am very tidy.',
        'languages': ['English', 'Igbo'],
        'company': 'RideShare Co',
      },
    ];

    // Set initial status for flatmates
    // IDs 1-3: none (unknown)
    // IDs 4-5: pending
    // IDs 6-7: accepted
    // IDs 8-9: declined

    // Set status for unknown flatmates (1-3)
    for (int i = 1; i <= 3; i++) {
      flatmateRequestStatus['$i'] = RequestStatus.none;
    }

    // Set status for pending matches (4-5)
    for (int i = 4; i <= 5; i++) {
      flatmateRequestStatus['$i'] = RequestStatus.pending;
    }

    // Set status for accepted flatmates (6-7)
    for (int i = 6; i <= 7; i++) {
      flatmateRequestStatus['$i'] = RequestStatus.accepted;
    }

    // Set status for declined flatmates (8-9)
    for (int i = 8; i <= 9; i++) {
      flatmateRequestStatus['$i'] = RequestStatus.declined;
    }
  }

  // Update all flatmate lists based on current status values
  void updateFlatmateLists() {
    // Clear all lists first
    matches.clear();
    pendingMatches.clear();
    myFlatmates.clear();
    declinedMatches.clear();

    // Distribute flatmates based on their status
    for (final flatmate in allFlatmates) {
      final id = flatmate['id'] as String;
      final status = flatmateRequestStatus[id] ?? RequestStatus.none;

      switch (status) {
        case RequestStatus.none:
          matches.add(flatmate);
          break;
        case RequestStatus.pending:
          pendingMatches.add(flatmate);
          break;
        case RequestStatus.accepted:
          myFlatmates.add(flatmate);
          break;
        case RequestStatus.declined:
          declinedMatches.add(flatmate);
          break;
      }
    }
  }

  // Filter matches by criteria
  void filterMatches({String? gender, String? religion, String? location}) {
    // Implementation for future filter functionality
  }

  // View match details
  void viewMatchDetails(Map<String, dynamic> match) {
    final id = match['id'] as String;
    final status = flatmateRequestStatus[id] ?? RequestStatus.none;

    // Create an arguments map with the match data and its current status
    final arguments = {'data': match, 'status': status};

    // Navigate to the flatmate detail screen with the match data and status
    Get.toNamed('/flatmate-detail', arguments: arguments);
  }

  // Initialize chat with a match
  void startChat(Map<String, dynamic> match) {
    // Implementation to start chat with match
  }

  // Update a flatmate's request status
  void updateFlatmateStatus(String flatmateId, RequestStatus newStatus) {
    // Update the status in the map
    flatmateRequestStatus[flatmateId] = newStatus;

    // Redistribute flatmates into the appropriate lists
    updateFlatmateLists();

    // Show appropriate notification based on new status
    String message;
    Color backgroundColor;

    switch (newStatus) {
      case RequestStatus.pending:
        message = 'Request sent! Waiting for response...';
        backgroundColor = Colors.amber.withOpacity(0.7);
        break;
      case RequestStatus.accepted:
        message = 'Match accepted! They are now your flatmate.';
        backgroundColor = const Color(0xff29BCA2).withOpacity(0.7);
        break;
      case RequestStatus.declined:
        message = 'Request declined.';
        backgroundColor = const Color(0xffDC3545).withOpacity(0.7);
        break;
      default:
        // Don't show notifications for returning to unknown status
        return;
    }

    // Show notification
    Get.snackbar(
      'Status Updated',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Accept a pending match
  void acceptMatch(Map<String, dynamic> match) {
    final id = match['id'] as String;

    // Update status to accepted
    updateFlatmateStatus(id, RequestStatus.accepted);

    // Navigate back
    Get.back();
  }

  // Decline a pending match
  void declineMatch(Map<String, dynamic> match) {
    final id = match['id'] as String;

    // Update status to declined
    updateFlatmateStatus(id, RequestStatus.declined);

    // Navigate back
    Get.back();
  }

  // Send a match request (from none to pending)
  void sendMatchRequest(Map<String, dynamic> match) {
    final id = match['id'] as String;

    // Update status to pending
    updateFlatmateStatus(id, RequestStatus.pending);
  }

  // Get current flatmate data
  Map<String, dynamic> getCurrentFlatmateData() {
    // If we have a current flatmate, return it
    if (currentFlatmate.value.isNotEmpty) {
      return currentFlatmate.value;
    }

    // If we have my flatmates, return the first one
    if (myFlatmates.isNotEmpty) {
      currentFlatmate.value = myFlatmates.first;
      return myFlatmates.first;
    }

    // Otherwise, return default data
    return {
      'name': 'John Doe',
      'age': 28,
      'gender': 'Male',
      'religion': 'Christianity',
      'occupation': 'Software Developer',
      'location': 'Abuja, Nigeria',
      'budget': '400,000 - 600,000/year',
      'bio':
          'Easygoing and friendly. I appreciate a clean and organized space filled with good vibes.',
      'isVerified': true,
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      'languages': ['English', 'Hausa', 'Yoruba'],
      'company': 'Tech Solutions Ltd',
    };
  }

  // Set current flatmate
  void setCurrentFlatmate(Map<String, dynamic> flatmate) {
    currentFlatmate.value = flatmate;
  }

  // Load sample flats data
  void loadFlats() {
    flats.value = [
      {
        'id': 'f1',
        'bedrooms': 4,
        'image': 'https://images.unsplash.com/photo-1560185127-6ed189bf02f4',
        'price': '1m',
        'location': 'Abuja',
        'rating': 4,
        'isFavorite': false,
        'amenities': ['Swimming Pool', 'Gym', 'Security', 'Parking'],
        'description':
            'Spacious 4 bedroom flat in a serene environment, perfect for sharing with flatmates.',
      },
      {
        'id': 'f2',
        'bedrooms': 2,
        'image': 'https://images.unsplash.com/photo-1531835551805-16d864c8d311',
        'price': '550k',
        'location': 'Abuja',
        'rating': 4,
        'isFavorite': false,
        'amenities': ['Security', 'Parking', 'Standby Generator'],
        'description':
            'Modern 2 bedroom apartment with great amenities and a strategic location.',
      },
      {
        'id': 'f3',
        'bedrooms': 2,
        'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        'price': '550k',
        'location': 'Abuja',
        'rating': 5,
        'isFavorite': true,
        'amenities': ['Swimming Pool', 'Gym', 'Security', 'Parking'],
        'description':
            'Luxury 2 bedroom flat with modern interior design and top-notch facilities.',
      },
      {
        'id': 'f4',
        'bedrooms': 2,
        'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        'price': '550k',
        'location': 'Abuja',
        'rating': 5,
        'isFavorite': false,
        'amenities': ['Security', 'Parking', 'Constant Water Supply'],
        'description':
            'Elegant 2 bedroom flat in a quiet neighborhood, perfect for professionals.',
      },
      {
        'id': 'f5',
        'bedrooms': 3,
        'image': 'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
        'price': '750k',
        'location': 'Lagos',
        'rating': 4,
        'isFavorite': false,
        'amenities': ['Security', 'Parking', 'Standby Generator'],
        'description':
            'Spacious 3 bedroom flat with modern amenities and great neighborhood.',
      },
      {
        'id': 'f6',
        'bedrooms': 3,
        'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        'price': '800k',
        'location': 'Abuja',
        'rating': 5,
        'isFavorite': false,
        'amenities': ['Swimming Pool', 'Gym', 'Security', 'Parking'],
        'description':
            'Premium 3 bedroom flat with excellent facilities in a prestigious location.',
      },
      {
        'id': 'f7',
        'bedrooms': 1,
        'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        'price': '350k',
        'location': 'Lagos',
        'rating': 3,
        'isFavorite': false,
        'amenities': ['Security', 'Parking'],
        'description':
            'Cozy 1 bedroom flat perfect for singles or couples in a vibrant area.',
      },
      {
        'id': 'f8',
        'bedrooms': 5,
        'image': 'https://images.unsplash.com/photo-1516156008625-3a9d6067fab5',
        'price': '1.5m',
        'location': 'Abuja',
        'rating': 5,
        'isFavorite': true,
        'amenities': [
          'Swimming Pool',
          'Gym',
          'Security',
          'Parking',
          'Tennis Court',
        ],
        'description':
            'Luxury 5 bedroom duplex with excellent facilities for a large family or group of flatmates.',
      },
      {
        'id': 'f9',
        'bedrooms': 2,
        'image': 'https://images.unsplash.com/photo-1484154218962-a197022b5858',
        'price': '480k',
        'location': 'Port Harcourt',
        'rating': 4,
        'isFavorite': false,
        'amenities': ['Security', 'Parking', 'Constant Water Supply'],
        'description':
            'Modern 2 bedroom flat with stylish interior and all essential amenities.',
      },
      {
        'id': 'f10',
        'bedrooms': 3,
        'image': 'https://images.unsplash.com/photo-1517541866997-7c5e31363d0f',
        'price': '620k',
        'location': 'Kano',
        'rating': 4,
        'isFavorite': false,
        'amenities': ['Security', 'Parking', 'Standby Generator', 'Garden'],
        'description':
            'Spacious 3 bedroom flat with a beautiful garden in a quiet neighborhood.',
      },
    ];
  }

  // View my flatmate details
  void viewMyFlatmateDetails(Map<String, dynamic> flatmate) {
    setCurrentFlatmate(flatmate);

    // Get the status for this flatmate
    final id = flatmate['id'] as String;
    final status = flatmateRequestStatus[id] ?? RequestStatus.none;

    // Navigate to the detail screen with data and status
    Get.toNamed(
      AppRoutes.FLATMATE_DETAIL,
      arguments: {'data': flatmate, 'status': status},
    );
  }

  // Toggle favorite status for a flat
  void toggleFlatFavorite(String flatId) {
    // Find the flat by id
    final flatIndex = flats.indexWhere((flat) => flat['id'] == flatId);
    if (flatIndex != -1) {
      // Toggle the favorite status
      final currentStatus = flats[flatIndex]['isFavorite'] as bool? ?? false;
      flats[flatIndex] = {...flats[flatIndex], 'isFavorite': !currentStatus};

      // Show feedback
      final message =
          !currentStatus ? 'Added to favorites' : 'Removed from favorites';
      Get.snackbar(
        'Favorites',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF29BCA2).withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }
}
