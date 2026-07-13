import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_state.dart';
import 'package:ur_stylist/features/onboarding/presentation/widgets/document_upload_tile.dart';

class Page2Kyc extends StatelessWidget {
  const Page2Kyc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylistOnboardingBloc, StylistOnboardingState>(
      builder: (context, state) {
        final data = state.data;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Identity verification',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload clear photos of your national ID or Kebele ID, then complete the selfie check.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            DocumentUploadTile(
              title: 'Front of your national ID / Kebele ID',
              subtitle: 'Capture the front side clearly',
              file: data.nationalIdFront,
              icon: Icons.badge_outlined,
              onTap: () => _pick(context, 'front', ImageSource.camera),
            ),
            if (data.nationalIdFront != null) ...[
              const SizedBox(height: 14),
              AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 250),
                child: DocumentUploadTile(
                  title: 'Back of your national ID / Kebele ID',
                  subtitle: 'Capture the back side clearly',
                  file: data.nationalIdBack,
                  icon: Icons.badge,
                  onTap: () => _pick(context, 'back', ImageSource.camera),
                ),
              ),
            ],
            if (data.nationalIdBack != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.purple.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selfie liveness check',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "We'll take a short selfie to confirm you're a real person.",
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _pick(context, 'selfie', ImageSource.camera),
                        icon: Icon(
                          data.selfieVerified
                              ? Icons.verified
                              : Icons.photo_camera_front,
                        ),
                        label: Text(
                          data.selfieVerified
                              ? 'Selfie verified'
                              : 'Start liveness check',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: data.canContinueKyc
                    ? () {
                        context.read<StylistOnboardingBloc>().add(
                          const KycSubmitted(),
                        );
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pick(
    BuildContext context,
    String type,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;
    context.read<StylistOnboardingBloc>().add(
      KycFileChanged(type: type, file: File(picked.path)),
    );
  }
}
