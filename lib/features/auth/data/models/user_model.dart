class UserModel {
  const UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final int? id;

  final String email;
  final String firstName;
  final String lastName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      email: (json['email'] as String?)?.trim() ?? '',
      firstName: (json['firstName'] as String?)?.trim() ?? '',
      lastName: (json['lastName'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
