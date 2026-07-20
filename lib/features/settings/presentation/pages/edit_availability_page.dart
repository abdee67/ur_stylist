import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/onboarding/domain/entities/availability_slot.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';

class EditAvailabilityPage extends StatefulWidget {
  final List<AvailabilitySlot> availability;

  const EditAvailabilityPage({super.key, required this.availability});

  @override
  State<EditAvailabilityPage> createState() => _EditAvailabilityPageState();
}

class _EditAvailabilityPageState extends State<EditAvailabilityPage> {
  late List<AvailabilitySlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = widget.availability.isEmpty
        ? AvailabilitySlot.defaultWeek()
        : List<AvailabilitySlot>.from(widget.availability);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final slot = _slots[index];
          return Row(
            children: [
              SizedBox(
                width: 46,
                child: Text(
                  slot.dayOfWeek,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Switch(
                value: slot.isAvailable,
                activeThumbColor: Colors.pink,
                onChanged: (value) =>
                    _update(index, slot.copyWith(isAvailable: value)),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: slot.isAvailable ? () => _pickStart(index) : null,
                  child: Text(slot.startTime.format(context)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('to'),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: slot.isAvailable ? () => _pickEnd(index) : null,
                  child: Text(slot.endTime.format(context)),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: _slots.length,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            context.read<SettingsBloc>().add(SettingsAvailabilitySaved(_slots));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save availability'),
        ),
      ),
    );
  }

  Future<void> _pickStart(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slots[index].startTime,
    );
    if (picked != null) {
      _update(index, _slots[index].copyWith(startTime: picked));
    }
  }

  Future<void> _pickEnd(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _slots[index].endTime,
    );
    if (picked != null) {
      _update(index, _slots[index].copyWith(endTime: picked));
    }
  }

  void _update(int index, AvailabilitySlot slot) {
    setState(() => _slots[index] = slot);
  }
}
