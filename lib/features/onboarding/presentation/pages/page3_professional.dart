import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/onboarding/presentation/bloc/stylist_onboarding_state.dart';
import 'package:ur_stylist/features/onboarding/presentation/widgets/day_hour_selector.dart';
import 'package:ur_stylist/features/onboarding/presentation/widgets/document_upload_tile.dart';
import 'package:ur_stylist/features/onboarding/presentation/widgets/radius_slider.dart';
import 'package:ur_stylist/features/onboarding/presentation/widgets/service_chip_grid.dart';

class Page3Professional extends StatelessWidget {
  const Page3Professional({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylistOnboardingBloc, StylistOnboardingState>(
      builder: (context, state) {
        final data = state.data;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionHeader('License & Experience'),
            DocumentUploadTile(
              title: 'Cosmetology license or certification',
              subtitle: 'Accepts image or PDF',
              file: data.licenseFile,
              icon: Icons.workspace_premium_outlined,
              onTap: () => _pickLicense(context),
            ),
            const SizedBox(height: 16),
            _Stepper(
              value: data.yearsExperience,
              onChanged: (value) {
                context.read<StylistOnboardingBloc>().add(
                  YearsExperienceChanged(value),
                );
              },
            ),
            const SizedBox(height: 16),
            _PortfolioRow(photos: data.portfolioPhotos),
            const SizedBox(height: 26),
            _SectionHeader('Service Specialties'),
            ServiceChipGrid(
              services: data.services,
              selectedServiceIds: data.selectedServiceIds,
              prices: data.servicePrices,
              onToggle: (service, price) {
                context.read<StylistOnboardingBloc>().add(
                  ServiceSelectionToggled(service: service, price: price),
                );
              },
            ),
            const SizedBox(height: 26),
            _SectionHeader('Availability'),
            DayHourSelector(
              availability: data.availability,
              onChanged: (slot) {
                context.read<StylistOnboardingBloc>().add(
                  AvailabilityUpdated(slot),
                );
              },
            ),
            const SizedBox(height: 26),
            _SectionHeader('Service Area'),
            RadiusSlider(
              value: data.serviceRadiusKm,
              onChanged: (value) {
                context.read<StylistOnboardingBloc>().add(
                  ServiceRadiusChanged(value),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: data.canContinueProfessional
                    ? () {
                        context.read<StylistOnboardingBloc>().add(
                          const ProfessionalDetailsSubmitted(),
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

  Future<void> _pickLicense(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;
    context.read<StylistOnboardingBloc>().add(LicenseFileChanged(File(path)));
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 18, color: Colors.pink),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _Stepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text('Years of experience')),
        IconButton(
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: value < 40 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _PortfolioRow extends StatelessWidget {
  final List<File> photos;

  const _PortfolioRow({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio photos',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Add at least 3 polished examples if you have them.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (picked != null && context.mounted) {
                      context.read<StylistOnboardingBloc>().add(
                        PortfolioPhotoAdded(File(picked.path)),
                      );
                    }
                  },
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.pink.shade50,
                      border: Border.all(color: Colors.pink.shade200),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      photos[index],
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: InkWell(
                      onTap: () {
                        context.read<StylistOnboardingBloc>().add(
                          PortfolioPhotoRemoved(index),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
