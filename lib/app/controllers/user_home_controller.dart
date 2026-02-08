import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class UserHomeController extends GetxController {
  // Featured properties
  final PageController featuredPageController = PageController();
  final RxInt currentFeaturedIndex = 0.obs;
  Timer? autoScrollTimer;

  // Property list
  final PageController propertyListPageController = PageController();
  final RxInt currentPropertyListPage = 0.obs;
  // Data for the featured properties
  final List<Map<String, dynamic>> featuredProperties = [
    {
      'images': [
        'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=1000',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1000',
        'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?q=80&w=1000',
      ],
      'name': 'Modern Villa',
      'address': '123 Luxury Lane, Lekki',
      'price': '350,000,000',
      'size': '450 sqm',
      'type': 'Duplex',
      'mapCoordinates': {'latitude': 6.4281, 'longitude': 3.4219},
      'features': [
        {'name': '450 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Modern Villa is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'Victor Charles',
        'level': 'Lv1 2 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 3.5,
      'reviews': 1050,
      'discount': '15% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=1000',
        'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000',
      ],
      'name': 'Penthouse Suite',
      'address': '456 Elite Avenue, Ikoyi',
      'price': '420,000,000',
      'size': '380 sqm',
      'type': 'Apartment',
      'mapCoordinates': {'latitude': 6.4548, 'longitude': 3.4737},
      'features': [
        {'name': '380 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Penthouse Suite is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'Sarah Johnson',
        'level': 'Lv2 3 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 4.2,
      'reviews': 820,
      'discount': '10% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?q=80&w=1000',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?q=80&w=1000',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?q=80&w=1000',
      ],
      'name': 'Garden Estate',
      'address': '789 Green Way, Abuja',
      'price': '280,000,000',
      'size': '520 sqm',
      'type': 'Bungalow',
      'mapCoordinates': {'latitude': 9.0765, 'longitude': 7.3986},
      'features': [
        {'name': '520 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Garden Estate is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'Michael Obi',
        'level': 'Lv3 5 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 4.8,
      'reviews': 1250,
      'discount': '12% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600047509358-9dc75507daeb?q=80&w=1000',
      ],
      'name': 'Skyline Residence',
      'address': '321 Tower Street, Victoria Island',
      'price': '500,000,000',
      'size': '420 sqm',
      'type': 'Penthouse',
      'mapCoordinates': {'latitude': 6.4281, 'longitude': 3.4219},
      'rating': 4.5,
      'reviews': 950,
      'discount': '18% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=1000',
      ],
      'name': 'Coastal Haven',
      'address': '654 Beach Road, Lekki Phase 1',
      'price': '380,000,000',
      'size': '500 sqm',
      'type': 'Villa',
      'mapCoordinates': {'latitude': 6.4474, 'longitude': 3.4700},
      'rating': 4.7,
      'reviews': 1100,
      'discount': '14% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600566753151-384129cf4e3e?q=80&w=1000',
      ],
      'name': 'Urban Oasis',
      'address': '987 City Center, Ikeja GRA',
      'price': '320,000,000',
      'size': '390 sqm',
      'type': 'Duplex',
      'mapCoordinates': {'latitude': 6.5833, 'longitude': 3.3500},
      'rating': 4.3,
      'reviews': 880,
      'discount': '11% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600607687644-c7171b42498f?q=80&w=1000',
      ],
      'name': 'Royal Mansion',
      'address': '147 Kings Avenue, Banana Island',
      'price': '750,000,000',
      'size': '600 sqm',
      'type': 'Mansion',
      'mapCoordinates': {'latitude': 6.4474, 'longitude': 3.4219},
      'rating': 4.9,
      'reviews': 1500,
      'discount': '20% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000',
      ],
      'name': 'Serene Heights',
      'address': '258 Hill Top, Maitama',
      'price': '450,000,000',
      'size': '480 sqm',
      'type': 'Duplex',
      'mapCoordinates': {'latitude': 9.0820, 'longitude': 7.4951},
      'rating': 4.6,
      'reviews': 1020,
      'discount': '16% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600585154363-67eb9e2e2099?q=80&w=1000',
      ],
      'name': 'Paradise Court',
      'address': '369 Palm Drive, Ajah',
      'price': '290,000,000',
      'size': '410 sqm',
      'type': 'Terrace',
      'mapCoordinates': {'latitude': 6.4698, 'longitude': 3.5852},
      'rating': 4.1,
      'reviews': 720,
      'discount': '9% off',
    },
  ];

  // Data for the recently added properties
  final List<Map<String, dynamic>> recentlyAddedProperties = [
    {
      'images': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1000',
        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?q=80&w=1000',
      ],
      'name': 'Luxury Apartment',
      'address': '123 Main St, Lagos',
      'price': '250,000,000',
      'size': '350 sqm',
      'type': 'Apartment',
      'mapCoordinates': {'latitude': 6.5244, 'longitude': 3.3792},
      'features': [
        {'name': '350 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Luxury Apartment is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'Amaka Nwosu',
        'level': 'Lv2 4 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 4.0,
      'reviews': 750,
      'discount': '8% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000',
        'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?q=80&w=1000',
      ],
      'name': 'Modern Villa',
      'address': '456 Park Ave, Abuja',
      'price': '180,000,000',
      'size': '400 sqm',
      'type': 'Villa',
      'mapCoordinates': {'latitude': 9.0765, 'longitude': 7.3986},
      'features': [
        {'name': '400 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Modern Villa is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'John Adewale',
        'level': 'Lv2 3 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 4.2,
      'reviews': 620,
      'discount': '10% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000',
        'https://images.unsplash.com/photo-1600047509782-20d39509de23?q=80&w=1000',
      ],
      'name': 'Family Home',
      'address': '789 Beach Rd, Lagos',
      'price': '220,000,000',
      'size': '380 sqm',
      'type': 'House',
      'mapCoordinates': {'latitude': 6.4698, 'longitude': 3.5852},
      'features': [
        {'name': '380 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Family Home is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'Chioma Eze',
        'level': 'Lv3 5 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 4.5,
      'reviews': 890,
      'discount': '12% off',
    },
    {
      'images': [
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=1000',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?q=80&w=1000',
      ],
      'name': 'Penthouse Suite',
      'address': '101 Sky Tower, Abuja',
      'price': '320,000,000',
      'size': '420 sqm',
      'type': 'Penthouse',
      'mapCoordinates': {'latitude': 9.0579, 'longitude': 7.4951},
      'features': [
        {'name': '420 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
        {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
        {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
        {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
        {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
      ],
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
      'description':
          'Penthouse Suite is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
      'sellerProfile': {
        'name': 'David Okonkwo',
        'level': 'Lv2 4 Seller',
        'isVerified': true,
        'avatar':
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
      },
      'rating': 4.3,
      'reviews': 720,
      'discount': '10% off',
    },
  ];

  // Data for location properties
  final Map<String, List<Map<String, dynamic>>> locationProperties = {
    'Lagos': [
      {
        'images': [
          'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=1000',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1000',
        ],
        'name': 'Oceanview Apartment',
        'address': '10 Marina Drive, Lagos',
        'price': '180,000,000',
        'size': '280',
        'type': 'Apartment',
        'mapCoordinates': {'latitude': 6.4550, 'longitude': 3.3941},
        'features': [
          {'name': '280 Square meters', 'icon': 'assets/icons/sqm.svg'},
          {
            'name': 'Certificate of Occupancy',
            'icon': 'assets/icons/document.svg',
          },
          {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
          {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
          {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
          {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
          {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
          {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
        ],
        'landmarks': [
          'New International Airport',
          'International Stadium',
          'Dangote refinery',
          'Samsung support center',
          'MTN Office',
        ],
        'description':
            'Oceanview Apartment is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
        'sellerProfile': {
          'name': 'Tunde Bakare',
          'level': 'Lv2 3 Seller',
          'isVerified': true,
          'avatar':
              'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
        },
        'rating': 4.1,
        'reviews': 680,
        'discount': '8% off',
      },
      {
        'images': [
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=1000',
        ],
        'name': 'Victoria Garden',
        'address': '24 VGC, Lagos',
        'price': '220,000,000',
        'size': '320',
        'type': 'Duplex',
        'mapCoordinates': {'latitude': 6.5505, 'longitude': 3.3642},
        'features': [
          {'name': '320 Square meters', 'icon': 'assets/icons/sqm.svg'},
          {
            'name': 'Certificate of Occupancy',
            'icon': 'assets/icons/document.svg',
          },
          {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
          {'name': '247 Security', 'icon': 'assets/icons/247.svg'},
          {'name': 'CCTV Surveillance', 'icon': 'assets/icons/cctv.svg'},
          {'name': 'Swimming Pool', 'icon': 'assets/icons/pool.svg'},
          {'name': 'Car Park', 'icon': 'assets/icons/car.svg'},
          {'name': 'Solar System', 'icon': 'assets/icons/solar.svg'},
        ],
        'landmarks': [
          'New International Airport',
          'International Stadium',
          'Dangote refinery',
          'Samsung support center',
          'MTN Office',
        ],
        'description':
            'Victoria Garden is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area...',
        'sellerProfile': {
          'name': 'Funke Akindele',
          'level': 'Lv3 5 Seller',
          'isVerified': true,
          'avatar':
              'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=256',
        },
        'rating': 4.7,
        'reviews': 950,
        'discount': '12% off',
      },
      {
        'images': [
          'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?q=80&w=1000',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1000',
        ],
        'name': 'Lekki Heights',
        'address': '5 Admiralty Way, Lekki',
        'price': '150,000,000',
        'size': '260',
        'type': 'Flat',
      },
    ],
    'Abuja': [
      {
        'images': [
          'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=1000',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=1000',
        ],
        'name': 'Montero Estate',
        'address': '15 Elite Close, Abuja',
        'price': '250,000,000',
        'size': '500',
        'type': 'Residential',
      },
      {
        'images': [
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=1000',
        ],
        'name': 'Maitama Mansion',
        'address': '7 Maitama District, Abuja',
        'price': '320,000,000',
        'size': '450',
        'type': 'Mansion',
      },
      {
        'images': [
          'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?q=80&w=1000',
          'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?q=80&w=1000',
        ],
        'name': 'Asokoro Villa',
        'address': '3 Asokoro Heights, Abuja',
        'price': '290,000,000',
        'size': '420',
        'type': 'Villa',
      },
    ],
    'Port Harcourt': [
      {
        'images': [
          'https://images.unsplash.com/photo-1600047509782-20d39509de23?q=80&w=1000',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1000',
        ],
        'name': 'Riverside Residence',
        'address': '9 Waterfront, Port Harcourt',
        'price': '145,000,000',
        'size': '300',
        'type': 'Duplex',
      },
      {
        'images': [
          'https://images.unsplash.com/photo-1600210492493-0946911123ea?q=80&w=1000',
          'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?q=80&w=1000',
        ],
        'name': 'Garden City Home',
        'address': '12 GRA Phase 2, Port Harcourt',
        'price': '180,000,000',
        'size': '340',
        'type': 'Bungalow',
      },
      {
        'images': [
          'https://images.unsplash.com/photo-1600585154526-990dced4db0d?q=80&w=1000',
          'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?q=80&w=1000',
        ],
        'name': 'Exclusive Estate',
        'address': '18 Trans Amadi, Port Harcourt',
        'price': '210,000,000',
        'size': '380',
        'type': 'Mansion',
      },
    ],
  };

  // Currently selected location
  final RxString selectedLocation = 'Lagos'.obs;

  @override
  void onInit() {
    super.onInit();
    startAutoScroll();
    featuredPageController.addListener(_onFeaturedPageChanged);
    propertyListPageController.addListener(_onPropertyListPageChanged);
  }

  @override
  void onClose() {
    stopAutoScroll();
    featuredPageController.dispose();
    propertyListPageController.dispose();
    super.onClose();
  }

  void _onFeaturedPageChanged() {
    if (featuredPageController.hasClients && featuredPageController.page != null) {
      currentFeaturedIndex.value = featuredPageController.page!.round();
    }
  }

  void _onPropertyListPageChanged() {
    if (propertyListPageController.hasClients &&
        propertyListPageController.page != null) {
      currentPropertyListPage.value = propertyListPageController.page!.round();
    }
  }

  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!featuredPageController.hasClients) return;
      if (currentFeaturedIndex.value < featuredProperties.length - 1) {
        featuredPageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      } else {
        featuredPageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  void stopAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = null;
  }

  void changeLocation(String location) {
    selectedLocation.value = location;
  }

  // Navigation methods
  void navigateToSearch() {
    Get.toNamed('/search');
  }

  void navigateToFeaturedProperties() {
    Get.toNamed('/featured-properties');
  }

  void navigateToRecentlyAddedProperties() {
    Get.toNamed('/recently-added');
  }

  void navigateToLocationProperties(String location) {
    Get.toNamed('/location-properties', arguments: location);
  }

  void navigateToPropertyDetail(Map<String, dynamic> property) {
    Get.toNamed('/property-detail', arguments: property);
  }
}
