class ReadAllergyDto {
  final int? id;
  final String? name;
  final String? description;
  final String? type;
  final String? userEmail;

  ReadAllergyDto({
    this.id,
    this.name,
    this.description,
    this.type,
    this.userEmail,
  });

  factory ReadAllergyDto.fromJson(Map<String, dynamic> jsonMap) {
    final data = jsonMap.containsKey('data') && jsonMap['data'] is Map<String, dynamic>
        ? jsonMap['data'] as Map<String, dynamic>
        : jsonMap;

    return ReadAllergyDto(
      id: data['id'] as int?,
      name: data['name'] as String?,
      description: data['description'] as String?,
      type: data['type'] as String?,
      userEmail: data['userEmail'] as String?,
    );
  }
}

class CreateAllergyDto {
  final String? name;
  final String? description;
  final String? type;
  final int? ingredientId;

  CreateAllergyDto({
    this.name,
    this.description,
    this.type,
    this.ingredientId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (ingredientId != null) 'ingredientId': ingredientId,
    };
  }
}

class UpdateAllergyDto {
  final String? name;
  final String? description;
  final String? type;
  final int? userId;

  UpdateAllergyDto({
    this.name,
    this.description,
    this.type,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (userId != null) 'userId': userId,
    };
  }
}
