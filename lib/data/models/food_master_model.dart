import 'package:flutter/foundation.dart';

@immutable
class FoodMasterModel {
  final String id;
  final String name;
  final String manufacturer;
  final String servingSize;
  final double energyKcal;
  final double proteinG;
  final double carbohydrateG;
  final double fatG;
  final double sugarG;
  final double sodiumMg;
  final double fiberG;
  final String nutritionBasis;
  final String? barcode;
  final String? imageUrl;
  final String status;

  const FoodMasterModel({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.servingSize,
    required this.energyKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.sugarG,
    required this.sodiumMg,
    required this.fiberG,
    this.nutritionBasis = 'PER_100G',
    this.barcode,
    this.imageUrl,
    this.status = 'active',
  });

  factory FoodMasterModel.fromJson(Map<String, dynamic> json) {
    final String rawManufacturer = json['manufacturer'] as String? ?? '';
    String rawServing = json['serving_size'] as String? ?? '1 porsi';
    if (rawServing.toLowerCase().contains('bdd')) {
      rawServing = rawServing
          .replaceAll(RegExp(r'\(Berat Dapat Dimakan\)', caseSensitive: false), '')
          .replaceAll(RegExp(r'BDD', caseSensitive: false), '')
          .replaceAll(RegExp(r'Per\s*', caseSensitive: false), '')
          .trim();
      if (rawServing.isEmpty || rawServing == '100 g' || rawServing == '100g') {
        rawServing = '100 g';
      }
    }

    String basis = json['nutrition_basis'] as String? ?? '';
    if (basis.isEmpty) {
      final s = rawServing.trim().toLowerCase();
      if (s.isEmpty || s == '0' || s == '0 g' || s == '0 ml' || s == '0.00 g') {
        basis = 'UNVERIFIED';
      } else if (s.contains('100 g') || s.contains('100g') || s.contains('100 gram')) {
        basis = 'PER_100G';
      } else if (s.contains('kemasan') || s.contains('bungkus') || s.contains('botol')) {
        basis = 'PER_PACKAGE';
      } else {
        basis = 'PER_SERVING';
      }
    }

    return FoodMasterModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      manufacturer: rawManufacturer,
      servingSize: rawServing,
      energyKcal: (json['energy_kcal'] as num?)?.toDouble() ?? (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbohydrateG: (json['carbohydrate_g'] as num?)?.toDouble() ?? (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? (json['fat'] as num?)?.toDouble() ?? 0.0,
      sugarG: (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (json['sodium_mg'] as num?)?.toDouble() ?? 0.0,
      fiberG: (json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      nutritionBasis: basis,
      barcode: json['barcode'] as String?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'serving_size': servingSize,
      'energy_kcal': energyKcal,
      'protein_g': proteinG,
      'carbohydrate_g': carbohydrateG,
      'fat_g': fatG,
      'sugar_g': sugarG,
      'sodium_mg': sodiumMg,
      'fiber_g': fiberG,
      'nutrition_basis': nutritionBasis,
      'barcode': barcode,
      'image_url': imageUrl,
      'status': status,
    };
  }
}
