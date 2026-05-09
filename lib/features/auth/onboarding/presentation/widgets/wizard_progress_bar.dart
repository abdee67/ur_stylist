import 'package:flutter/material.dart';

class WizardProgressBar extends StatelessWidget {
  final int currentStep;

  const WizardProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['Basic Info', 'Identity', 'Professional', 'Wallet'];
    final visibleStep = switch (currentStep) {
      0 => 0,
      1 || 2 => 1,
      3 => 2,
      _ => 3,
    };

    return Row(
      children: List.generate(labels.length, (index) {
        final isDone = index < visibleStep;
        final isCurrent = index == visibleStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= visibleStep
                                ? Colors.pink
                                : Colors.grey.shade300),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone || isCurrent
                          ? Colors.pink
                          : Colors.grey.shade300,
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : Icons.circle,
                      size: isDone ? 18 : 8,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == labels.length - 1
                          ? Colors.transparent
                          : (index < visibleStep
                                ? Colors.pink
                                : Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? Colors.pink.shade700
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
