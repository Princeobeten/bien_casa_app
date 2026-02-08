// Mock data for property listings
class PropertyData {
  static final Map<String, dynamic> defaultProperty = {
    // HouseLease required fields
    'id': 'lease_001',
    'title': 'Blue Ocean Estate',
    'description':
        'Blue Ocean Estate is a premium real estate development offering a perfect blend of luxury, tranquility, and modern living. Strategically located in a prime area with easy access to major landmarks including New International Airport, International Stadium, and Dangote refinery.',
    'category': 'House',
    'propertyType': 'Rent',
    'price': 110000000,
    'depositAmount': 22000000,
    'holdAmount': 5000000,
    'leaseDuration': 'Yearly',
    'location': {
      'address': '101 Jesse Jackson Street, Abuja 798302',
      'city': 'Abuja',
      'state': 'FCT',
      'district': 'Maitama',
      'coordinates': {'latitude': 9.0579, 'longitude': 7.4951},
    },
    'photos': [
      'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=1000',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=1000',
      'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?q=80&w=1000',
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?q=80&w=1000',
    ],
    'videoUrl': null,
    'negotiationRange': {'min': 100000000, 'max': 120000000},
    'status': 'Active',
    'propertyStatus': 'Available',
    'ownerId': 'owner_001',
    'realtorId': 'realtor_001',
    'createdAt': '2024-01-15T10:30:00Z',
    'updatedAt': '2024-11-01T14:20:00Z',
    'deletedAt': null,
    'bedrooms': 5,
    'bathrooms': 4,
    'squareFeet': 5382.0,
    'amenities': [
      'Certificate of Occupancy',
      'Fenced',
      '24/7 Security',
      'CCTV Surveillance',
      'Swimming Pool',
      'Car Park',
      'Solar System',
    ],
    'features': {
      'size': '500 sqm',
      'type': 'Duplex',
      'landmarks': [
        'New International Airport',
        'International Stadium',
        'Dangote refinery',
        'Samsung support center',
        'MTN Office',
      ],
    },
    
    // Additional UI fields (not part of HouseLease model)
    'sellerProfile': {
      'name': 'Victor Charles',
      'level': 'Lv1 2 Seller',
      'isVerified': true,
      'avatar': 'assets/image/agent_avatar.png',
    },
    'rating': 3.5,
    'reviews': 1050,
    'discount': '15% off',
  };

  static final List<Map<String, dynamic>> featuredProperties = [
    defaultProperty,
    {
      'name': 'Green Valley Estate',
      'address': '45 Ahmadu Bello Way, Lagos',
      'price': '85,000,000',
      'images': [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=1000',
        'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?q=80&w=1000',
      ],
      'size': '350 sqm',
      'type': 'Bungalow',
      'mapCoordinates': {'latitude': 6.4550, 'longitude': 3.3841},
      'features': [
        {'name': '350 Square meters', 'icon': 'assets/icons/sqm.svg'},
        {
          'name': 'Certificate of Occupancy',
          'icon': 'assets/icons/document.svg',
        },
        {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        {'name': '24/7 Security', 'icon': 'assets/icons/247.svg'},
      ],
      'landmarks': ['Shopping Mall', 'Hospital', 'School'],
      'description':
          'Green Valley Estate offers a serene environment with modern amenities for comfortable living...',
      'sellerProfile': {
        'name': 'Sarah Johnson',
        'level': 'Lv2 Seller',
        'isVerified': true,
        'avatar': 'assets/image/agent.png',
      },
      'rating': 4.2,
      'reviews': 820,
      'discount': '5% off',
    },
  ];

  static final Map<String, List<Map<String, dynamic>>> locationProperties = {
    'Lagos': [
      {
        'name': 'Lekki Paradise',
        'address': '12 Admiralty Way, Lekki Phase 1',
        'price': '120,000,000',
        'images': [
          'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?q=80&w=1000',
          'https://images.unsplash.com/photo-1600210492493-0946911123ea?q=80&w=1000',
          'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?q=80&w=1000',
        ],
        'size': '450 sqm',
        'type': 'Apartment',
        'mapCoordinates': {'latitude': 6.4281, 'longitude': 3.4219},
        'features': [
          {'name': '450 Square meters', 'icon': 'assets/icons/sqm.svg'},
          {
            'name': 'Certificate of Occupancy',
            'icon': 'assets/icons/document.svg',
          },
          {'name': 'Fenced', 'icon': 'assets/icons/fence.svg'},
        ],
        'landmarks': ['Beach', 'Shopping Mall', 'Restaurant'],
        'description':
            'Lekki Paradise offers luxury living with a beautiful view of the Atlantic Ocean...',
        'sellerProfile': {
          'name': 'Michael Obi',
          'level': 'Lv3 Seller',
          'isVerified': true,
          'avatar': 'assets/image/agent_avatar.png',
        },
        'rating': 4.8,
        'reviews': 1500,
        'discount': '10% off',
      },
    ],
    'Abuja': [defaultProperty],
  };
}
