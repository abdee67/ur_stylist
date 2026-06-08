import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_bloc.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_event.dart';
import 'package:ur_stylist/features/auth/onboarding/presentation/bloc/stylist_onboarding_state.dart';

class Page1BasicInfo extends StatefulWidget {
  const Page1BasicInfo({super.key});

  @override
  State<Page1BasicInfo> createState() => _Page1BasicInfoState();
}

class _Page1BasicInfoState extends State<Page1BasicInfo> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController(text: '+251');
  final _businessName = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StylistOnboardingBloc>().add(
        const CurrentLocationRequested(),
      );
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _businessName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylistOnboardingBloc, StylistOnboardingState>(
      builder: (context, state) {
        final data = state.data;
        _syncController(_fullName, data.fullName);
        _syncController(_email, data.email);
        _syncController(_phone, data.phone ?? '+251');
        _syncController(_businessName, data.businessName);

        return Form(
          key: _formKey,
          onChanged: _changed,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: InkWell(
                  onTap: _pickProfilePhoto,
                  borderRadius: BorderRadius.circular(56),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.pink.shade50,
                        backgroundImage: data.profilePhoto == null
                            ? null
                            : FileImage(data.profilePhoto!),
                        child: data.profilePhoto == null
                            ? Icon(
                                Icons.person,
                                size: 46,
                                color: Colors.pink.shade300,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.pink,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _field(
                _fullName,
                'Full name',
                Icons.person,
                validator: _requiredName,
              ),
              const SizedBox(height: 14),
              _field(
                _email,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              _field(
                _phone,
                'Phone number',
                Icons.phone,
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              const SizedBox(height: 14),
              _field(
                _businessName,
                'What do you call your practice?',
                Icons.storefront,
                validator: _required,
              ),
              const SizedBox(height: 18),
              _LocationCard(data: data),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: data.canContinueBasicInfo
                      ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<StylistOnboardingBloc>().add(
                              const BasicInfoSubmitted(),
                            );
                          }
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _changed() {
    context.read<StylistOnboardingBloc>().add(
      BasicInfoChanged(
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        businessName: _businessName.text.trim(),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      context.read<StylistOnboardingBloc>().add(
        ProfilePhotoChanged(File(picked.path)),
      );
    }
  }

  void _syncController(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (controller.text == next || next.isEmpty) {
      return;
    }
    controller.text = next;
  }

  String? _required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Required' : null;
  }

  String? _requiredName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter at least 2 characters';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }
}

class _LocationCard extends StatelessWidget {
  final dynamic data;

  const _LocationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasLocation = data.latitude != null && data.longitude != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasLocation ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasLocation ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasLocation ? Icons.location_on : Icons.my_location,
            color: Colors.pink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.isFetchingLocation
                  ? 'Fetching your location...'
                  : data.locationError ??
                        data.locationAddress ??
                        'Location is required',
            ),
          ),
          TextButton(
            onPressed: data.isFetchingLocation
                ? null
                : () {
                    context.read<StylistOnboardingBloc>().add(
                      const CurrentLocationRequested(),
                    );
                  },
            child: Text(hasLocation ? 'Retry' : 'Fetch'),
          ),
        ],
      ),
    );
  }
}
