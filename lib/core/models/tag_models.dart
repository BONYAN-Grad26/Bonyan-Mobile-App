import 'package:bonyaan_app/core/models/models.dart';

class ReadDietaryTagDto {
  final int? id;
  final String? name;
  final String? type;
  final String? description;
  final List<IngredientDto>? ingredients;

  ReadDietaryTagDto({
    this.id,
    this.name,
    this.type,
    this.description,
    this.ingredients,
  });

  factory ReadDietaryTagDto.fromJson(Map<String, dynamic> jsonMap) {
    final data = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return ReadDietaryTagDto(
      id: data['id'] as int?,
      name: data['name'] as String?,
      type: data['type'] as String?,
      description: data['description'] as String?,
      ingredients: (data['ingredients'] as List<dynamic>?)
          ?.map((e) => IngredientDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreateDietaryTagDto {
  final String? type;
  final String? name;
  final String? description;

  CreateDietaryTagDto({this.type, this.name, this.description});

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    };
  }
}

class UpdateDietaryTagDto {
  final String? type;
  final String? name;
  final String? description;

  UpdateDietaryTagDto({this.type, this.name, this.description});

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    };
  }
}
