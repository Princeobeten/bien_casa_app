import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatePickerDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final Function(String?) onChanged;
  final Widget? prefixIcon;

  const DatePickerDropdown({
    super.key,
    required this.hint,
    this.value,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                value?.isEmpty == true || value == null ? hint : value!,
                style: TextStyle(
                  color: value?.isEmpty == true || value == null 
                      ? Colors.grey[600] 
                      : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Select $hint',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Date options
            ...['Immediately', 'Next Month', 'In 2 Months', 'In 3 Months', 'Custom Date'].map((option) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                option,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              trailing: value == option 
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                if (option == 'Custom Date') {
                  Navigator.pop(context);
                  _showCustomDatePicker(context);
                } else {
                  onChanged(option);
                  Navigator.pop(context);
                }
              },
            )).toList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        final formattedDate = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
        onChanged(formattedDate);
      }
    });
  }
}