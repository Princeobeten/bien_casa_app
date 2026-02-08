import 'package:get/get.dart';

class HomeOwnerController extends GetxController {
  // Properties Management
  final RxList<Map<String, dynamic>> _properties = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get properties => _properties;

  final RxList<String> _propertyStatuses = <String>[
    'Available',
    'Occupied',
    'Under Maintenance',
    'Unavailable'
  ].obs;
  List<String> get propertyStatuses => _propertyStatuses;

  // Requests Management
  final RxList<Map<String, dynamic>> _requests = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get requests => _requests;

  final RxList<String> _requestTypes = <String>[
    'Inspection',
    'Maintenance',
    'Repair',
    'Complaint',
    'General Inquiry'
  ].obs;
  List<String> get requestTypes => _requestTypes;

  final RxList<String> _requestStatuses = <String>[
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled'
  ].obs;
  List<String> get requestStatuses => _requestStatuses;

  // Messages Management
  final RxList<Map<String, dynamic>> _conversations = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get conversations => _conversations;

  final RxList<Map<String, dynamic>> _messages = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get messages => _messages;

  // Wallet Management
  final RxDouble _walletBalance = 0.0.obs;
  double get walletBalance => _walletBalance.value;

  final RxList<Map<String, dynamic>> _transactions = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get transactions => _transactions;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock Properties
    _properties.addAll([
      {
        'id': '1',
        'title': 'Modern 3BR Apartment',
        'description': 'Beautiful modern apartment with great amenities',
        'address': '15 Victoria Island, Lagos',
        'propertyType': 'Apartment',
        'rentAmount': 450000,
        'holdingAmount': 90000,
        'holdingDuration': 6,
        'holdingDurationType': 'Months',
        'bedrooms': 3,
        'bathrooms': 2,
        'status': 'Occupied',
        'images': ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2'],
        'amenities': ['Security', 'Parking', 'Generator', 'Water'],
        'tenant': {
          'name': 'John Doe',
          'phone': '+234 801 234 5678',
          'email': 'john.doe@email.com',
          'moveInDate': '2024-01-15',
        },
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'id': '2',
        'title': '2BR Duplex',
        'description': 'Spacious duplex in a quiet neighborhood',
        'address': '8 Lekki Phase 1, Lagos',
        'propertyType': 'Duplex',
        'rentAmount': 350000,
        'holdingAmount': 70000,
        'holdingDuration': 6,
        'holdingDurationType': 'Months',
        'bedrooms': 2,
        'bathrooms': 2,
        'status': 'Available',
        'images': ['https://images.unsplash.com/photo-1564013799919-ab600027ffc6'],
        'amenities': ['Security', 'Parking', 'Garden'],
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      },
    ]);

    // Mock Requests
    _requests.addAll([
      {
        'id': '1',
        'type': 'Maintenance',
        'title': 'Air Conditioner Repair',
        'description': 'The AC in the living room is not cooling properly',
        'status': 'Pending',
        'priority': 'High',
        'propertyId': '1',
        'propertyTitle': 'Modern 3BR Apartment',
        'tenantName': 'John Doe',
        'tenantPhone': '+234 801 234 5678',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'images': [],
      },
      {
        'id': '2',
        'type': 'Inspection',
        'title': 'Property Inspection Request',
        'description': 'Potential tenant wants to inspect the property',
        'status': 'In Progress',
        'priority': 'Medium',
        'propertyId': '2',
        'propertyTitle': '2BR Duplex',
        'tenantName': 'Jane Smith',
        'tenantPhone': '+234 802 345 6789',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'scheduledDate': DateTime.now().add(const Duration(days: 2)),
        'images': [],
      },
    ]);

    // Mock Conversations
    _conversations.addAll([
      {
        'id': '1',
        'participantName': 'John Doe',
        'participantAvatar': null,
        'propertyTitle': 'Modern 3BR Apartment',
        'lastMessage': 'Thank you for fixing the AC issue',
        'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 30)),
        'unreadCount': 0,
        'isOnline': true,
      },
      {
        'id': '2',
        'participantName': 'Jane Smith',
        'participantAvatar': null,
        'propertyTitle': '2BR Duplex',
        'lastMessage': 'When can I schedule the inspection?',
        'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
        'unreadCount': 2,
        'isOnline': false,
      },
    ]);

    // Mock Transactions
    _transactions.addAll([
      {
        'id': '1',
        'type': 'rent_received',
        'title': 'Rent Payment Received',
        'description': 'Monthly rent from John Doe - Modern 3BR Apartment',
        'amount': 450000.0,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'propertyTitle': 'Modern 3BR Apartment',
        'tenantName': 'John Doe',
        'status': 'Completed',
      },
      {
        'id': '2',
        'type': 'maintenance_expense',
        'title': 'Maintenance Expense',
        'description': 'AC repair cost for Modern 3BR Apartment',
        'amount': -25000.0,
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'propertyTitle': 'Modern 3BR Apartment',
        'vendor': 'Cool Air Services',
        'status': 'Completed',
      },
      {
        'id': '3',
        'type': 'security_deposit',
        'title': 'Security Deposit Received',
        'description': 'Security deposit from John Doe',
        'amount': 90000.0,
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'propertyTitle': 'Modern 3BR Apartment',
        'tenantName': 'John Doe',
        'status': 'Completed',
      },
    ]);

    _walletBalance.value = 515000.0; // Total from transactions
  }

  // Property Management Methods
  void addProperty(Map<String, dynamic> property) {
    property['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    property['createdAt'] = DateTime.now();
    _properties.add(property);
    update();
  }

  void updateProperty(String propertyId, Map<String, dynamic> updates) {
    final index = _properties.indexWhere((p) => p['id'] == propertyId);
    if (index != -1) {
      _properties[index] = {..._properties[index], ...updates};
      update();
    }
  }

  void deleteProperty(String propertyId) {
    _properties.removeWhere((p) => p['id'] == propertyId);
    update();
  }

  // Request Management Methods
  void addRequest(Map<String, dynamic> request) {
    request['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    request['createdAt'] = DateTime.now();
    _requests.add(request);
    update();
  }

  void updateRequestStatus(String requestId, String status) {
    final index = _requests.indexWhere((r) => r['id'] == requestId);
    if (index != -1) {
      _requests[index]['status'] = status;
      if (status == 'Completed') {
        _requests[index]['completedAt'] = DateTime.now();
      }
      update();
    }
  }

  void deleteRequest(String requestId) {
    _requests.removeWhere((r) => r['id'] == requestId);
    update();
  }

  // Message Management Methods
  void sendMessage(String conversationId, String message) {
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'conversationId': conversationId,
      'message': message,
      'senderId': 'home_owner',
      'senderName': 'You',
      'timestamp': DateTime.now(),
      'isRead': true,
    };
    
    _messages.add(newMessage);
    
    // Update conversation last message
    final conversationIndex = _conversations.indexWhere((c) => c['id'] == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex]['lastMessage'] = message;
      _conversations[conversationIndex]['lastMessageTime'] = DateTime.now();
    }
    
    update();
  }

  List<Map<String, dynamic>> getMessagesForConversation(String conversationId) {
    return _messages.where((m) => m['conversationId'] == conversationId).toList()
      ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
  }

  // Transaction Management Methods
  void addTransaction(Map<String, dynamic> transaction) {
    transaction['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    transaction['date'] = DateTime.now();
    _transactions.insert(0, transaction); // Add to beginning for latest first
    
    // Update wallet balance
    _walletBalance.value += transaction['amount'];
    update();
  }

  // Filter Methods
  List<Map<String, dynamic>> getPropertiesByStatus(String status) {
    return _properties.where((p) => p['status'] == status).toList();
  }

  List<Map<String, dynamic>> getRequestsByStatus(String status) {
    return _requests.where((r) => r['status'] == status).toList();
  }

  List<Map<String, dynamic>> getRequestsByType(String type) {
    return _requests.where((r) => r['type'] == type).toList();
  }

  List<Map<String, dynamic>> getTransactionsByType(String type) {
    return _transactions.where((t) => t['type'] == type).toList();
  }

  // Statistics Methods
  int get totalProperties => _properties.length;
  int get occupiedProperties => getPropertiesByStatus('Occupied').length;
  int get availableProperties => getPropertiesByStatus('Available').length;
  int get pendingRequests => getRequestsByStatus('Pending').length;
  int get unreadMessages => _conversations.fold(0, (sum, conv) => sum + (conv['unreadCount'] as int));

  double get monthlyRentIncome {
    return _properties
        .where((p) => p['status'] == 'Occupied')
        .fold(0.0, (sum, p) => sum + (p['rentAmount'] as num).toDouble());
  }

  double get totalSecurityDeposits {
    return _properties
        .where((p) => p['status'] == 'Occupied')
        .fold(0.0, (sum, p) => sum + (p['holdingAmount'] as num).toDouble());
  }
}