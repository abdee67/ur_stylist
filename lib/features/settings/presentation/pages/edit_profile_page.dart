import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ur_stylist/features/settings/domain/entities/stylist_profile_entity.dart';
import 'package:ur_stylist/features/settings/presentation/bloc/settings_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final StylistProfileEntity profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _business;
  late final TextEditingController _description;
  late double _radius;
  File? _photo;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _phone = TextEditingController(text: widget.profile.phone);
    _business = TextEditingController(text: widget.profile.businessName);
    _description = TextEditingController(
      text: widget.profile.description ?? '',
    );
    _radius = widget.profile.serviceRadiusKm.toDouble();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _business.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: _photo != null
                      ? FileImage(_photo!)
                      : (widget.profile.imageUrl == null
                            ? null
                            : NetworkImage(widget.profile.imageUrl!)
                                  as ImageProvider),
                  child: _photo == null && widget.profile.imageUrl == null
                      ? const Icon(Icons.person, size: 42)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          TextField(
            controller: _business,
            decoration: const InputDecoration(labelText: 'Business name'),
          ),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 18),
          Text('Service radius: ${_radius.round()} km'),
          Slider(
            value: _radius,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: Colors.pink,
            onChanged: (value) => setState(() => _radius = value),
          ),
          const SizedBox(height: 18),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isActionLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save changes'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _photo = File(image.path));
  }

  void _save() {
    context.read<SettingsBloc>().add(
      SettingsProfileSaved(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        businessName: _business.text.trim(),
        description: _description.text.trim(),
        profilePhoto: _photo,
        latitude: widget.profile.latitude,
        longitude: widget.profile.longitude,
        serviceRadiusKm: _radius.round(),
      ),
    );
    Navigator.pop(context);
  }
}
