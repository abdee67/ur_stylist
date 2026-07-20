import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AvailabilitySlot extends Equatable {
  final String dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;

  const AvailabilitySlot({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  AvailabilitySlot copyWith({
    String? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAvailable,
  }) {
    return AvailabilitySlot(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  String get startTimeText => _formatTime(startTime);
  String get endTimeText => _formatTime(endTime);

  static List<AvailabilitySlot> defaultWeek() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days
        .map(
          (day) => AvailabilitySlot(
            dayOfWeek: day,
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 18, minute: 0),
            isAvailable: !['Sat', 'Sun'].contains(day),
          ),
        )
        .toList();
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime, isAvailable];
}
