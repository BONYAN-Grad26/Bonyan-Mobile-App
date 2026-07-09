
class IngredientDto {
  final int? id;
  final String? name;

  IngredientDto({this.id, this.name});

  factory IngredientDto.fromJson(Map<String, dynamic> json) {
    return IngredientDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DietaryTagDto {
  final int? id;
  final String? type;
  final String? name;
  final String? description;

  DietaryTagDto({this.id, this.type, this.name, this.description});

  factory DietaryTagDto.fromJson(Map<String, dynamic> json) {
    return DietaryTagDto(
      id: json['id'] as int?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }
}

class AllergyDto {
  final int? id;
  final String? name;
  final String? severity;

  AllergyDto({this.id, this.name, this.severity});

  factory AllergyDto.fromJson(Map<String, dynamic> json) {
    return AllergyDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      severity: json['severity'] as String?,
    );
  }
}

class ReadIngredientDto {
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? category;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? sugarG;
  final List<DietaryTagDto>? dietaryTags;
  final List<AllergyDto>? allergens;
  final double? price;
  final String? unit;
  final int? stockQuantity;
  final bool? availableForSale;
  final DateTime? createdAt;

  ReadIngredientDto({
    this.id, this.name, this.imageUrl, this.category, this.calories,
    this.proteinG, this.carbsG, this.fatG, this.fiberG, this.sugarG,
    this.dietaryTags, this.allergens, this.price, this.unit,
    this.stockQuantity, this.availableForSale, this.createdAt,
  });

  factory ReadIngredientDto.fromJson(Map<String, dynamic> jsonMap) {
    final data = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return ReadIngredientDto(
      id: data['id'] as int?,
      name: data['name'] as String?,
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String?,
      calories: (data['calories'] as num?)?.toDouble(),
      proteinG: (data['proteinG'] as num?)?.toDouble(),
      carbsG: (data['carbsG'] as num?)?.toDouble(),
      fatG: (data['fatG'] as num?)?.toDouble(),
      fiberG: (data['fiberG'] as num?)?.toDouble(),
      sugarG: (data['sugarG'] as num?)?.toDouble(),
      dietaryTags: (data['dietaryTags'] as List<dynamic>?)
          ?.map((e) => DietaryTagDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      allergens: (data['allergens'] as List<dynamic>?)
          ?.map((e) => AllergyDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: (data['price'] as num?)?.toDouble(),
      unit: data['unit'] as String?,
      stockQuantity: data['stockQuantity'] as int?,
      availableForSale: data['availableForSale'] as bool?,
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) : null,
    );
  }
}

class CreateIngredientDto {
  final String? name;
  final String? category;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? sugarG;
  final double? price;
  final String? unit;
  final int? stockQuantity;
  final bool? availableForSale;

  CreateIngredientDto({
    this.name, this.category, this.calories, this.proteinG, this.carbsG,
    this.fatG, this.fiberG, this.sugarG, this.price, this.unit,
    this.stockQuantity, this.availableForSale,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'proteinG': proteinG,
      if (carbsG != null) 'carbsG': carbsG,
      if (fatG != null) 'fatG': fatG,
      if (fiberG != null) 'fiberG': fiberG,
      if (sugarG != null) 'sugarG': sugarG,
      if (price != null) 'price': price,
      if (unit != null) 'unit': unit,
      if (stockQuantity != null) 'stockQuantity': stockQuantity,
      if (availableForSale != null) 'availableForSale': availableForSale,
    };
  }
}

class UpdateIngredientDto {
  final String? name;
  final String? category;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? sugarG;
  final double? price;
  final String? unit;
  final int? stockQuantity;
  final bool? availableForSale;

  UpdateIngredientDto({
    this.name, this.category, this.calories, this.proteinG, this.carbsG,
    this.fatG, this.fiberG, this.sugarG, this.price, this.unit,
    this.stockQuantity, this.availableForSale,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'proteinG': proteinG,
      if (carbsG != null) 'carbsG': carbsG,
      if (fatG != null) 'fatG': fatG,
      if (fiberG != null) 'fiberG': fiberG,
      if (sugarG != null) 'sugarG': sugarG,
      if (price != null) 'price': price,
      if (unit != null) 'unit': unit,
      if (stockQuantity != null) 'stockQuantity': stockQuantity,
      if (availableForSale != null) 'availableForSale': availableForSale,
    };
  }
}
