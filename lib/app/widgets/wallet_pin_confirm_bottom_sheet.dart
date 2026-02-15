import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _accentColor = Color(0xFF1ABC9C);

/// Reusable wallet PIN confirmation bottom sheet (same UI as withdraw/KYC flow).
/// Use for any wallet debit that requires PIN: withdrawal, campaign activation, etc.
class WalletPinConfirmBottomSheet extends StatefulWidget {
  const WalletPinConfirmBottomSheet({
    super.key,
    required this.title,
    required this.amountText,
    this.amountLabel = 'Total amount',
    this.showBiometric = false,
    this.onBiometric,
    required this.onPinEntered,
  });

  final String title;
  final String amountText;
  final String amountLabel;
  final bool showBiometric;
  final Future<void> Function()? onBiometric;
  final Future<void> Function(String pin) onPinEntered;

  @override
  State<WalletPinConfirmBottomSheet> createState() =>
      _WalletPinConfirmBottomSheetState();
}

class _WalletPinConfirmBottomSheetState
    extends State<WalletPinConfirmBottomSheet> {
  String _pin = '';
  static const int _pinLength = 4;
  bool _isSubmitting = false;
  bool _biometricProcessing = false;

  Future<void> _onPinComplete() async {
    if (_pin.length != _pinLength || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onPinEntered(_pin);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _pin = '';
      });
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleBiometric() async {
    if (widget.onBiometric == null || _biometricProcessing) return;
    setState(() => _biometricProcessing = true);
    try {
      await widget.onBiometric!();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _biometricProcessing = false);
    }
  }

  void _addDigit(String digit) {
    if (_pin.length >= _pinLength || _isSubmitting) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 200), _onPinComplete);
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Processing…',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'ProductSans',
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ProductSans',
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.amountLabel,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.amountText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: 'ProductSans',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.showBiometric && widget.onBiometric != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _biometricProcessing ? null : _handleBiometric,
                  icon: _biometricProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint, size: 24),
                  label: Text(
                    _biometricProcessing ? 'Verifying…' : 'Use Biometric',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accentColor,
                    side: const BorderSide(color: _accentColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Or enter your PIN',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'ProductSans',
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _pinLength,
                (index) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: index < _pin.length
                          ? _accentColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      index < _pin.length ? '•' : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.0,
              children: [
                ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) {
                  return _buildPinButton(
                    label: num.toString(),
                    onTap: () => _addDigit(num.toString()),
                  );
                }),
                _buildPinButton(
                  label: '0',
                  onTap: () => _addDigit('0'),
                ),
                _buildPinButton(
                  label: '⌫',
                  icon: Icons.backspace_outlined,
                  onTap: _deleteDigit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPinButton({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 22, color: Colors.grey[700])
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ProductSans',
                  ),
                ),
        ),
      ),
    );
  }
}
