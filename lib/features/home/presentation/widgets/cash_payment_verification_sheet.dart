import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ur_stylist/api/cash/cash_payment_verification_service.dart';
import 'package:ur_stylist/core/constants/app_constants.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';

// Main entry point with improved error handling
Future<bool> showCashPaymentVerificationSheet(
  BuildContext context,
  BookingEntity booking,
) async {
  final service = CashPaymentVerificationService();

  try {
    final method = await showModalBottomSheet<CashVerificationMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => const _CashVerificationMethodSheet(),
    );

    if (!context.mounted || method == null) {
      return false;
    }

    return await _handleVerificationMethod(context, method, booking, service);
  } catch (e) {
    debugPrint('Error in cash payment verification: $e');
    if (context.mounted) {
      _showErrorDialog(context, 'Failed to process verification');
    }
    return false;
  }
}

Future<bool> _handleVerificationMethod(
  BuildContext context,
  CashVerificationMethod method,
  BookingEntity booking,
  CashPaymentVerificationService service,
) async {
  switch (method) {
    case CashVerificationMethod.qr:
      return await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => _CashQrScannerPage(
                booking: booking,
                verificationService: service,
              ),
            ),
          ) ??
          false;

    case CashVerificationMethod.otp:
      return await _showCashOtpDialog(context, booking, service) ?? false;
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// Improved bottom sheet with animations
class _CashVerificationMethodSheet extends StatelessWidget {
  const _CashVerificationMethodSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.padding,
        18,
        AppConstants.padding,
        24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: 6),
            Text(
              'Use the customer QR or OTP after you receive cash.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 18),
            _CashMethodTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan customer QR',
              subtitle: 'Validates the booking and confirms cash receipt',
              color: Colors.blue,
              onTap: () => Navigator.of(context).pop(CashVerificationMethod.qr),
            ),
            const SizedBox(height: 12),
            _CashMethodTile(
              icon: Icons.pin_rounded,
              title: 'Enter customer OTP',
              subtitle: 'Use the 6-digit code shown on the customer app',
              color: Colors.green,
              onTap: () =>
                  Navigator.of(context).pop(CashVerificationMethod.otp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Confirm cash payment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          splashRadius: 20,
        ),
      ],
    );
  }
}

// Improved tile with better visual feedback
class _CashMethodTile extends StatelessWidget {
  const _CashMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.tileBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.tileBorderRadius),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.tilePadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppConstants.tileBorderRadius,
              ),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: AppConstants.iconSize),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Improved QR scanner with better performance
class _CashQrScannerPage extends StatefulWidget {
  const _CashQrScannerPage({
    required this.booking,
    required this.verificationService,
  });

  final BookingEntity booking;
  final CashPaymentVerificationService verificationService;

  @override
  State<_CashQrScannerPage> createState() => _CashQrScannerPageState();
}

class _CashQrScannerPageState extends State<_CashQrScannerPage>
    with WidgetsBindingObserver {
  bool _isProcessing = false;
  String? _errorMessage;
  late final MobileScannerController _controller;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.qrCode],
      returnImage: false,
      torchEnabled: false,
      autoZoom: false,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _errorTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller.stop();
        break;
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .firstOrNull;

    if (rawValue == null) return;

    setState(() => _isProcessing = true);

    // Process asynchronously to avoid blocking UI
    Future.microtask(() {
      if (!mounted) return;

      if (widget.verificationService.matchesCashQrPayload(
        rawValue,
        widget.booking,
      )) {
        _controller.stop();
        Navigator.of(context).pop(true);
      } else {
        _showTemporaryError('This QR code does not match the active booking.');
        setState(() => _isProcessing = false);
      }
    });
  }

  void _showTemporaryError(String message) {
    setState(() => _errorMessage = message);

    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        title: const Text(
          'Scan cash QR',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            tapToFocus: true,
            fit: BoxFit.cover,
            onDetectError: (error, stackTrace) {
              debugPrint('Scanner error: $error');
            },
          ),
          // Scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? Colors.orange : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Processing indicator
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          // Error message
          if (_errorMessage != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Improved OTP dialog with better UX
Future<bool?> _showCashOtpDialog(
  BuildContext context,
  BookingEntity booking,
  CashPaymentVerificationService service,
) async {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final expectedOtp = service.generateCashOtp(booking);
  String? errorMessage;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final canConfirm =
              controller.text.trim().length == AppConstants.otpLength;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Enter customer OTP'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask the customer for the 6-digit cash payment code.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(AppConstants.otpLength),
                  ],
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.3),
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      errorMessage = null;
                    });
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: canConfirm
                    ? () {
                        if (controller.text.trim() == expectedOtp) {
                          Navigator.of(context).pop(true);
                        } else {
                          setDialogState(() {
                            errorMessage = 'Invalid OTP. Please try again.';
                            controller.clear();
                          });
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();
  focusNode.dispose();
  return result;
}

// Extension method
extension IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    if (this is List<T>) {
      return (this as List<T>).isNotEmpty ? (this as List<T>).first : null;
    }
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
