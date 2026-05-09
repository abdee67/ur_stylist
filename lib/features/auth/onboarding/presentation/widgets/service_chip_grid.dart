import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

class ServiceChipGrid extends StatelessWidget {
  final List<ServiceEntity> services;
  final List<String> selectedServiceIds;
  final Map<String, double> prices;
  final void Function(ServiceEntity service, double? price) onToggle;

  const ServiceChipGrid({
    super.key,
    required this.services,
    required this.selectedServiceIds,
    required this.prices,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: services.map((service) {
        final selected = selectedServiceIds.contains(service.id);
        return FilterChip(
          selected: selected,
          selectedColor: Colors.pink.shade100,
          checkmarkColor: Colors.pink.shade700,
          avatar: _ServiceIcon(service: service),
          label: Text(
            selected
                ? '${service.name} (${(prices[service.id] ?? service.basePrice).toStringAsFixed(0)} ETB)'
                : service.name,
          ),
          onSelected: (_) async {
            if (selected) {
              onToggle(service, null);
              return;
            }
            final price = await _askForPrice(context, service);
            if (price != null) {
              onToggle(service, price);
            }
          },
        );
      }).toList(),
    );
  }

  Future<double?> _askForPrice(BuildContext context, ServiceEntity service) {
    final controller = TextEditingController(
      text: service.basePrice.toStringAsFixed(0),
    );
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Your price',
                  suffixText: 'ETB',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final price = double.tryParse(controller.text.trim());
                    if (price != null && price > 0) {
                      Navigator.of(context).pop(price);
                    }
                  },
                  child: const Text('Add service'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final ServiceEntity service;

  const _ServiceIcon({required this.service});

  @override
  Widget build(BuildContext context) {
    final iconUrl = service.iconUrl;
    if (iconUrl == null || iconUrl.isEmpty) {
      return const Icon(Icons.content_cut);
    }
    return CachedNetworkImage(
      imageUrl: iconUrl,
      width: 22,
      height: 22,
      errorWidget: (_, __, ___) => const Icon(Icons.content_cut),
    );
  }
}
