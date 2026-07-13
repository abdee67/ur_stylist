import 'package:flutter/material.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/availability_slot.dart';

class DayHourSelector extends StatelessWidget {
  final List<AvailabilitySlot> availability;
  final ValueChanged<AvailabilitySlot> onChanged;

  const DayHourSelector({
    super.key,
    required this.availability,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: availability
          .map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            slot.dayOfWeek,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: slot.isAvailable,
                          activeThumbColor: Colors.pink,
                          onChanged: (value) =>
                              onChanged(slot.copyWith(isAvailable: value)),
                        ),
                      ],
                    ),
                    if (slot.isAvailable)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: slot.startTime,
                                );
                                if (picked != null) {
                                  onChanged(slot.copyWith(startTime: picked));
                                }
                              },
                              icon: const Icon(Icons.schedule),
                              label: Text(slot.startTime.format(context)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: slot.endTime,
                                );
                                if (picked != null) {
                                  onChanged(slot.copyWith(endTime: picked));
                                }
                              },
                              icon: const Icon(Icons.schedule_outlined),
                              label: Text(slot.endTime.format(context)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
