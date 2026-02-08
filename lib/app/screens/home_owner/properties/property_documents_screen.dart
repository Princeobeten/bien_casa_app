import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertyDocumentsScreen extends StatefulWidget {
  final Map<String, dynamic>? property;

  const PropertyDocumentsScreen({super.key, this.property});

  @override
  State<PropertyDocumentsScreen> createState() =>
      _PropertyDocumentsScreenState();
}

class _PropertyDocumentsScreenState extends State<PropertyDocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock properties list
  final List<Map<String, dynamic>> _properties = [
    {'id': 'prop_001', 'title': 'Modern 3BR Apartment in Lekki'},
    {'id': 'prop_002', 'title': 'Luxury 4BR Duplex with Pool'},
    {'id': 'prop_003', 'title': 'Cozy 2BR Flat in Victoria Island'},
  ];

  // Selected property for document upload (when viewing all)
  Map<String, dynamic>? _selectedProperty;

  // General documents (not tied to any property)
  final List<Map<String, dynamic>> _generalDocuments = [
    {
      'id': 'gen_001',
      'documentType': 'Realtor License',
      'status': 'verified',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 15)),
      'fileName': 'realtor_license_2024.pdf',
      'verifiedAt': DateTime.now().subtract(const Duration(days: 12)),
    },
  ];

  // Property-specific documents
  final List<Map<String, dynamic>> _propertyDocuments = [
    {
      'id': 'doc_001',
      'propertyId': 'prop_001',
      'propertyTitle': 'Modern 3BR Apartment in Lekki',
      'documentType': 'Ownership Proof',
      'status': 'verified',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 10)),
      'fileName': 'certificate_of_occupancy.pdf',
      'verifiedAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'doc_002',
      'propertyId': 'prop_002',
      'propertyTitle': 'Luxury 4BR Duplex with Pool',
      'documentType': 'Ownership Proof',
      'status': 'pending',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 2)),
      'fileName': 'land_title_deed.pdf',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // If viewing a specific property, set it as selected
    if (widget.property != null) {
      _selectedProperty = widget.property;
    } else {
      // Default to first property when viewing all
      _selectedProperty = _properties.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getPropertyDocuments() {
    if (_selectedProperty == null) return [];
    return _propertyDocuments
        .where((doc) => doc['propertyId'] == _selectedProperty!['id'])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.only(left: 18),
        ),
        title:
            widget.property != null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Property Documents',
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.property!['title'],
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
                : const Text(
                  'All Property Documents',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.black,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'General Documents'),
                Tab(text: 'Property Documents'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // General Documents Tab
                _buildGeneralDocumentsTab(),
                // Property Documents Tab
                _buildPropertyDocumentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralDocumentsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents not tied to a specific property',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildDocumentTypeCard(
              'Realtor License',
              'Valid realtor license (if applicable)',
              Icons.badge,
              _generalDocuments,
              isGeneral: true,
            ),
            const SizedBox(height: 16),
            _buildDocumentTypeCard(
              'Business Registration',
              'Certificate of incorporation (optional)',
              Icons.business,
              [],
              isGeneral: true,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDocumentsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents for a specific property',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            // Property Selector (only show when viewing all properties)
            if (widget.property == null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<Map<String, dynamic>>(
                        dropdownColor: Colors.white,
                        value: _selectedProperty,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        items:
                            _properties.map((property) {
                              return DropdownMenuItem(
                                value: property,
                                child: Text(property['title']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProperty = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildDocumentTypeCard(
              'Ownership Proof',
              'Certificate of Occupancy, Land Title, or Deed',
              Icons.home_work,
              _getPropertyDocuments(),
              isGeneral: false,
            ),
            const SizedBox(height: 16),
            _buildDocumentTypeCard(
              'Building Approval',
              'Building plan approval (recommended)',
              Icons.architecture,
              [],
              isGeneral: false,
            ),
            const SizedBox(height: 16),
            _buildDocumentTypeCard(
              'Property Survey',
              'Land survey plan (optional)',
              Icons.map,
              [],
              isGeneral: false,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDocumentsByType(String type, bool isGeneral) {
    if (isGeneral) {
      return _generalDocuments
          .where((doc) => doc['documentType'] == type)
          .toList();
    } else {
      return _getPropertyDocuments()
          .where((doc) => doc['documentType'] == type)
          .toList();
    }
  }

  Widget _buildDocumentTypeCard(
    String title,
    String description,
    IconData icon,
    List<Map<String, dynamic>> uploadedDocs, {
    required bool isGeneral,
  }) {
    final bool hasUploaded = uploadedDocs.isNotEmpty;
    final bool hasVerified = uploadedDocs.any(
      (doc) => doc['status'] == 'verified',
    );
    final bool hasPending = uploadedDocs.any(
      (doc) => doc['status'] == 'pending',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              hasVerified
                  ? Colors.green
                  : hasPending
                  ? Colors.orange
                  : Colors.grey.shade200,
          width: hasUploaded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      hasVerified
                          ? Colors.green.shade100
                          : hasPending
                          ? Colors.orange.shade100
                          : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      hasVerified
                          ? Colors.green.shade800
                          : hasPending
                          ? Colors.orange.shade800
                          : Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (hasVerified)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else if (hasPending)
                const Icon(Icons.pending, color: Colors.orange, size: 24),
            ],
          ),
          if (hasUploaded) ...[
            const SizedBox(height: 12),
            Text(
              '${uploadedDocs.length} document${uploadedDocs.length > 1 ? 's' : ''} uploaded',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _uploadDocument(title, isGeneral),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff020202),
                side: const BorderSide(color: Color(0xff020202), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.upload_file, size: 20),
              label: Text(
                hasUploaded ? 'Upload Another' : 'Upload Document',
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedDocument(Map<String, dynamic> doc) {
    final bool isVerified = doc['status'] == 'verified';
    final bool isPending = doc['status'] == 'pending';
    final bool isRejected = doc['status'] == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isVerified
                  ? Colors.green.shade200
                  : isPending
                  ? Colors.orange.shade200
                  : isRejected
                  ? Colors.red.shade200
                  : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['documentType'],
                      style: const TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc['fileName'],
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      isVerified
                          ? Colors.green.shade50
                          : isPending
                          ? Colors.orange.shade50
                          : isRejected
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isVerified
                      ? 'Verified'
                      : isPending
                      ? 'Pending'
                      : isRejected
                      ? 'Rejected'
                      : 'Uploaded',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isVerified
                            ? Colors.green.shade800
                            : isPending
                            ? Colors.orange.shade800
                            : isRejected
                            ? Colors.red.shade800
                            : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Property: ${doc['propertyTitle']}',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Uploaded: ${_formatDate(doc['uploadedAt'])}',
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (isVerified && doc['verifiedAt'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Verified: ${_formatDate(doc['verifiedAt'])}',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 12,
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _uploadDocument(String documentType, bool isGeneral) {
    // TODO: Implement file picker and upload
    final propertyInfo =
        isGeneral
            ? 'General document'
            : 'For ${_selectedProperty?['title'] ?? 'selected property'}';

    Get.snackbar(
      'Upload Document',
      'File picker will open for $documentType\n$propertyInfo',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
