import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models/lease/house_lease.dart';

/// InspectionRequestScreen - Request property inspection
class InspectionRequestScreen extends StatefulWidget {
  final HouseLease lease;

  const InspectionRequestScreen({Key? key, required this.lease})
    : super(key: key);

  @override
  State<InspectionRequestScreen> createState() =>
      _InspectionRequestScreenState();
}

class _InspectionRequestScreenState extends State<InspectionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      Get.snackbar(
        'Date Required',
        'Please select an inspection date',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    if (_selectedTime == null) {
      Get.snackbar(
        'Time Required',
        'Please select an inspection time',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // TODO: Implement API call to submit inspection request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    Get.snackbar(
      'Success',
      'Inspection request submitted successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );

    Get.back();
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
                    'Schedule\nInspection',
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
                    'Choose your preferred date and time to inspect the property',
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

                  // Date Selection
                  _buildDateSelector(),

                  const SizedBox(height: 20),

                  // Time Selection
                  _buildTimeSelector(),

                  const SizedBox(height: 20),

                  // Additional Notes
                  _buildNotesField(),

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
                  child: const Icon(
                    Icons.home,
                    size: 60,
                    color: Color(0xff6B6B6B),
                  ),
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                  style: TextStyle(
                    fontFamily: 'ProductSans Light',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    letterSpacing: 0,
                    color:
                        _selectedDate == null
                            ? const Color(0xffBDBDBD)
                            : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : _selectedTime!.format(context),
                  style: TextStyle(
                    fontFamily: 'ProductSans Light',
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    letterSpacing: 0,
                    color:
                        _selectedTime == null
                            ? const Color(0xffBDBDBD)
                            : Colors.black,
                  ),
                ),
                const Icon(Icons.access_time, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
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
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Additional notes or special requests (optional)',
              hintStyle: TextStyle(
                fontFamily: 'ProductSans Light',
                fontWeight: FontWeight.w300,
                fontSize: 18,
                letterSpacing: 0,
                color: Color(0xffBDBDBD),
              ),
              fillColor: Color(0xffF8F8F8),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: Color(0xffF8F8F8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: Color(0xffF8F8F8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                borderSide: BorderSide(color: Color(0xffF8F8F8)),
              ),
            ),
          ),
        ),
      ],
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
              const Icon(Icons.info_outline, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Important Information',
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('• Inspection requests are subject to owner approval'),
          _buildInfoItem('• You will be notified once the owner responds'),
          _buildInfoItem('• Please arrive 5 minutes before scheduled time'),
          _buildInfoItem('• Bring a valid ID for verification'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'ProductSans Light',
          fontSize: 13,
          color: Color(0xff6B6B6B),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRequest,
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
                  'Submit Request',
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
}
