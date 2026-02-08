import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// DocumentsScreen - Upload and manage user documents
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Mock document data
  final List<Map<String, dynamic>> _documents = [
    {
      'id': 'doc_001',
      'type': 'National ID',
      'status': 'verified',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 5)),
      'fileName': 'national_id.pdf',
    },
    {
      'id': 'doc_002',
      'type': 'Proof of Income',
      'status': 'pending',
      'uploadedAt': DateTime.now().subtract(const Duration(days: 2)),
      'fileName': 'payslip_march_2024.pdf',
    },
  ];

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
        title: const Text(
          'My Documents',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 40,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload your documents to speed up your lease applications',
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Required Documents Section
              const Text(
                'Required Documents',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Document Upload Cards
              _buildDocumentCard(
                'National ID / Passport',
                'Upload a clear copy of your government-issued ID',
                Icons.badge,
                _getDocumentStatus('National ID'),
              ),

              const SizedBox(height: 16),

              _buildDocumentCard(
                'Proof of Income',
                'Upload recent payslip or bank statement',
                Icons.account_balance,
                _getDocumentStatus('Proof of Income'),
              ),

              const SizedBox(height: 24),

              // Optional Documents Section
              const Text(
                'Optional Documents',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              _buildDocumentCard(
                'Employment Letter',
                'Letter from your employer (recommended)',
                Icons.work,
                null,
              ),

              const SizedBox(height: 16),

              _buildDocumentCard(
                'Reference Letter',
                'Letter from previous landlord (optional)',
                Icons.person,
                null,
              ),

              const SizedBox(height: 24),

              // Uploaded Documents Section
              if (_documents.isNotEmpty) ...[
                const Text(
                  'Uploaded Documents',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ..._documents.map((doc) => _buildUploadedDocument(doc)),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _getDocumentStatus(String type) {
    try {
      return _documents.firstWhere((doc) => doc['type'] == type);
    } catch (e) {
      return null;
    }
  }

  Widget _buildDocumentCard(
    String title,
    String description,
    IconData icon,
    Map<String, dynamic>? uploadedDoc,
  ) {
    final bool isUploaded = uploadedDoc != null;
    final bool isVerified = uploadedDoc?['status'] == 'verified';
    final bool isPending = uploadedDoc?['status'] == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              isVerified
                  ? Colors.green
                  : isPending
                  ? Colors.orange
                  : Colors.grey.shade200,
          width: isUploaded ? 2 : 1,
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
                      isVerified
                          ? Colors.green.shade100
                          : isPending
                          ? Colors.orange.shade100
                          : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      isVerified
                          ? Colors.green.shade800
                          : isPending
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
              if (isVerified)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else if (isPending)
                const Icon(Icons.pending, color: Colors.orange, size: 24),
            ],
          ),
          if (!isUploaded) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _uploadDocument(title),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff020202),
                  side: const BorderSide(color: Color(0xff020202), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text(
                  'Upload Document',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadedDocument(Map<String, dynamic> doc) {
    final bool isVerified = doc['status'] == 'verified';
    final bool isPending = doc['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description, size: 24, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['type'],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isVerified
                      ? Colors.green.shade50
                      : isPending
                      ? Colors.orange.shade50
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isVerified
                  ? 'Verified'
                  : isPending
                  ? 'Pending'
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
                        : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadDocument(String documentType) {
    // TODO: Implement file picker and upload
    Get.snackbar(
      'Upload Document',
      'File picker will open for $documentType',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
