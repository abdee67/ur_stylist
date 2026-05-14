import 'package:ur_stylist/features/auth/onboarding/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    super.description,
    required super.durationMinutes,
    required super.basePrice,
    super.minPrice,
    super.iconUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      durationMinutes:
          int.tryParse((json['duration_minutes'] ?? '0').toString()) ?? 0,
      basePrice: double.tryParse((json['base_price'] ?? '0').toString()) ?? 0,
      minPrice: json['min_price'] == null
          ? null
          : double.tryParse(json['min_price'].toString()),
      iconUrl: json['icon_url']?.toString(),
    );
  }
}
