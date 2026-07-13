import 'package:flutter/material.dart';

class RadiusSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const RadiusSlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How far will you travel to clients?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '$value km',
            style: TextStyle(
              color: Colors.pink.shade700,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: Colors.pink,
          label: '$value km',
          onChanged: (newValue) => onChanged(newValue.round()),
        ),
      ],
    );
  }
}
