import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/lease/house_lease.dart';
import '../../../controllers/lease/application_controller.dart';

/// LeaseApplicationScreen - Apply for a lease
class LeaseApplicationScreen extends StatefulWidget {
  final HouseLease lease;

  const LeaseApplicationScreen({Key? key, required this.lease})
    : super(key: key);

  @override
  State<LeaseApplicationScreen> createState() => _LeaseApplicationScreenState();
}

class _LeaseApplicationScreenState extends State<LeaseApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApplicationController _applicationController = Get.put(
    ApplicationController(),
  );

  String _applicationType = 'immediate_rent';
  final TextEditingController _proposedPriceController =
      TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _proposedPriceController.dispose();
    _messageController.dispose();
    super.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.06,
              vertical: Get.height * 0.02,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Apply for Lease',
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 40,
                      height: 1,
                      leadingDistribution: TextLeadingDistribution.proportional,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Complete the form below to submit your lease application',
                    style: TextStyle(
                      fontFamily: 'ProductSans Light',
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                      height: 1,
                      leadingDistribution: TextLeadingDistribution.proportional,
                      color: Color(0xff020202),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Property Summary
                  _buildPropertySummary(),

                  const SizedBox(height: 36),

                  // Application Type
                  _buildApplicationType(),

                  const SizedBox(height: 20),

                  // Proposed Price (if negotiation)
                  if (_applicationType == 'negotiation') _buildProposedPrice(),

                  if (_applicationType == 'negotiation')
                    const SizedBox(height: 20),

                  // Message
                  _buildMessage(),

                  const SizedBox(height: 36),

                  // Important Information
                  _buildImportantInfo(),

                  const SizedBox(height: 50),

                  // Submit Button
                  _buildSubmitButton(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property Image
        if (widget.lease.photos.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              widget.lease.photos.first,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xffF8F8F8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.home, size: 60, color: Color(0xff6B6B6B)),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
        _buildInfoField('Property', widget.lease.title),
        _buildInfoField(
          'Location',
          widget.lease.location['city'] ?? 'Location',
        ),
        _buildInfoField('Price', widget.lease.formattedPrice),
        _buildInfoField('Duration', widget.lease.leaseDuration),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff6B6B6B),
              fontFamily: 'ProductSans Light',
              fontWeight: FontWeight.w300,
              fontSize: 18.0,
              letterSpacing: 0.0,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontSize: 18.0,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonFormField<String>(
            value: _applicationType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Application Type',
              hintStyle: TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontSize: 18,
                letterSpacing: 0,
                color: Color(0xffBDBDBD),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'ProductSans Light',
              fontWeight: FontWeight.w300,
              fontSize: 18,
              letterSpacing: 0,
              color: Colors.black,
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items: const [
              DropdownMenuItem(
                value: 'immediate_rent',
                child: Text('Immediate Rent'),
              ),
              DropdownMenuItem(
                value: 'negotiation',
                child: Text('Negotiation'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _applicationType = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProposedPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: _proposedPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your proposed price',
              hintStyle: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontSize: 18,
                letterSpacing: 0,
                color: Color(0xffBDBDBD),
              ),
              prefixText: 'NGN ',
              fillColor: const Color(0xffF8F8F8),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffF8F8F8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffF8F8F8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffF8F8F8)),
              ),
            ),
            validator: (value) {
              if (_applicationType == 'negotiation' &&
                  (value == null || value.isEmpty)) {
                return 'Please enter a proposed price';
              }
              if (value != null && value.isNotEmpty) {
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Listed price: ${widget.lease.formattedPrice}',
          style: const TextStyle(
            color: Color(0xffBDBDBD),
            fontFamily: 'ProductSans Light',
            fontWeight: FontWeight.w300,
            fontSize: 15,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tell the owner why you\'re a great tenant...',
              hintStyle: const TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontSize: 18,
                letterSpacing: 0,
                color: Color(0xffBDBDBD),
              ),
              fillColor: const Color(0xffF8F8F8),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffF8F8F8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffF8F8F8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffF8F8F8)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please add a message';
              }
              if (value.length < 20) {
                return 'Message should be at least 20 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          disabledBackgroundColor: const Color(0xffF8F8F8),
        ),
        child:
            _isSubmitting
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Submit Application',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildImportantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Important Information',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            '• Your application will be reviewed by the property owner',
          ),
          _buildInfoItem(
            '• You may be required to provide additional documents',
          ),
          _buildInfoItem('• Response time is typically 24-48 hours'),
          _buildInfoItem('• Deposit: ${widget.lease.formattedDeposit}'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 13,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Get current user ID (you'll need to implement this based on your auth system)
    const String currentUserId = 'user_123'; // TODO: Get from auth

    final applicationData = {
      'houseLeaseId': widget.lease.id,
      'applicantId': currentUserId,
      'applicationType': _applicationType,
      'proposedPrice':
          _applicationType == 'negotiation'
              ? double.tryParse(_proposedPriceController.text)
              : null,
      'message': _messageController.text,
      'status': 'Pending_review',
      'viewedByOwner': false,
      'isPaymentSuccessful': false,
    };

    final success = await _applicationController.createApplication(
      applicationData,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // Show success dialog
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text(
                  'Application Submitted!',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Your application has been submitted successfully. The property owner will review it and get back to you soon.',
              style: TextStyle(fontFamily: 'ProductSans', fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text(
                  'View My Applications',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff020202),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
