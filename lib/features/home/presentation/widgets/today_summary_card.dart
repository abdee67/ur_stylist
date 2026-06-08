import 'package:flutter/material.dart';
import 'package:ur_stylist/features/home/domain/entities/today_summary_entity.dart';

class TodaySummaryCard extends StatelessWidget {
  final TodaySummaryEntity summary;

  const TodaySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _Metric(
              label: "Today's earnings",
              value: 'ETB ${summary.earnings.toStringAsFixed(0)}',
            ),
            _Metric(label: 'Bookings today', value: '${summary.bookingsCount}'),
            _Metric(
              label: 'Rating',
              value: '★ ${summary.averageRating.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
