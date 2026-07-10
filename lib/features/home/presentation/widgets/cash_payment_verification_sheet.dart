import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ur_stylist/features/home/domain/entities/booking_entity.dart';

enum _CashVerificationMethod { qr, otp }

Future<bool> showCashPaymentVerificationSheet(
  BuildContext context,
  BookingEntity booking,
) async {
  final method = await showModalBottomSheet<_CashVerificationMethod>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _CashVerificationMethodSheet(),
  );

  if (!context.mounted || method == null) {
    return false;
  }

  if (method == _CashVerificationMethod.qr) {
    return await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => _CashQrScannerPage(booking: booking),
          ),
        ) ??
        false;
  }

  return await _showCashOtpDialog(context, booking) ?? false;
}

class _CashVerificationMethodSheet extends StatelessWidget {
  const _CashVerificationMethodSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Confirm cash payment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Use the customer QR or OTP after you receive cash.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _CashMethodTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan customer QR',
              subtitle: 'Validates the booking and confirms cash receipt',
              onTap: () =>
                  Navigator.of(context).pop(_CashVerificationMethod.qr),
            ),
            const SizedBox(height: 12),
            _CashMethodTile(
              icon: Icons.pin_rounded,
              title: 'Enter customer OTP',
              subtitle: 'Use the 6-digit code shown on the customer app',
              onTap: () =>
                  Navigator.of(context).pop(_CashVerificationMethod.otp),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashMethodTile extends StatelessWidget {
  const _CashMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF7FA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1CEDB)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.pink, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashQrScannerPage extends StatefulWidget {
  const _CashQrScannerPage({required this.booking});

  final BookingEntity booking;

  @override
  State<_CashQrScannerPage> createState() => _CashQrScannerPageState();
}

class _CashQrScannerPageState extends State<_CashQrScannerPage> {
  bool _handled = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan cash QR')),
      body: Stack(
        children: [
          MobileScanner(
            scanWindow: const Rect.fromLTWH(0, 0, 100, 100),
            onDetect: (capture) {
              if (_handled) {
                return;
              }

              final rawValue = capture.barcodes
                  .map((barcode) => barcode.rawValue?.trim())
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .firstOrNull;

              if (rawValue == null) {
                return;
              }

              if (_matchesCashQrPayload(rawValue, widget.booking)) {
                _handled = true;
                Navigator.of(context).pop(true);
                return;
              }

              setState(() {
                _errorMessage =
                    'This QR code does not match the active booking.';
              });
            },
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _errorMessage ??
                    'Point the camera at the QR code on the customer app.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showCashOtpDialog(BuildContext context, BookingEntity booking) {
  final controller = TextEditingController();
  final expectedOtp = _cashOtp(booking);

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final canConfirm = controller.text.trim() == expectedOtp;
          return AlertDialog(
            title: const Text('Enter customer OTP'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask the customer for the 6-digit cash payment code.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canConfirm
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(controller.dispose);
}

bool _matchesCashQrPayload(String rawValue, BookingEntity booking) {
  final uri = Uri.tryParse(rawValue);
  if (uri == null || uri.scheme != 'ursbeauty' || uri.host != 'cash-payment') {
    return false;
  }

  final bookingId = uri.queryParameters['booking_id'];
  final customerId = uri.queryParameters['customer_id'];
  final stylistId = uri.queryParameters['stylist_id'];

  return bookingId == booking.id &&
      (customerId == null || customerId == booking.clientId) &&
      (stylistId == null || stylistId == booking.stylistId);
}

String _cashOtp(BookingEntity booking) {
  final source = '${booking.id}:${booking.clientId ?? ''}:${booking.stylistId}';
  final hash = source.codeUnits.fold<int>(
    0,
    (value, codeUnit) => (value * 31 + codeUnit) & 0x7fffffff,
  );
  return (100000 + hash % 900000).toString();
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
