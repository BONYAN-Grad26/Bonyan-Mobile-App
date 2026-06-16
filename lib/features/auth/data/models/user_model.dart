class UserModel {
  const UserModel({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final String email;
  final String firstName;
  final String lastName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: (json['email'] as String?)?.trim() ?? '',
      firstName: (json['firstName'] as String?)?.trim() ?? '',
      lastName: (json['lastName'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
