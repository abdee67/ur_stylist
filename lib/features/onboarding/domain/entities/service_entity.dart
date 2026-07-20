import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int durationMinutes;
  final double basePrice;
  final double? minPrice;
  final String? iconUrl;

  const ServiceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.basePrice,
    this.minPrice,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    durationMinutes,
    basePrice,
    minPrice,
    iconUrl,
  ];
}
