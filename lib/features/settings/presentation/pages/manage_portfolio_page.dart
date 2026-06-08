import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';

class ManagePortfolioPage extends StatelessWidget {
  final List<PortfolioPhotoEntity> photos;

  const ManagePortfolioPage({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickImages(context),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add'),
      ),
      body: photos.isEmpty
          ? const Center(child: Text('No portfolio photos yet.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(photo.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: IconButton.filled(
                          onPressed: () => context.read<SettingsBloc>().add(
                            SettingsPortfolioPhotoDeleted(photo),
                          ),
                          icon: const Icon(Icons.delete, size: 18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isEmpty) return;
    final files = images.map((image) => File(image.path)).toList();
    if (!context.mounted) return;
    context.read<SettingsBloc>().add(SettingsPortfolioPhotosAdded(files));
    Navigator.pop(context);
  }
}
