// Authentication-related models
import 'package:flutter/foundation.dart';

/// Response after successful login/register with JWT token
class AuthResponse {
  final String accessToken;
  final DateTime expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String? ?? '',
      expiresIn: json['expiresIn'] != null
          ? DateTime.parse(json['expiresIn'] as String)
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expiresIn': expiresIn.toIso8601String(),
    };
  }

  @override
  String toString() => 'AuthResponse(accessToken: $accessToken, expiresIn: $expiresIn)';
}

/// Request payload for user registration
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() =>
      'RegisterRequest(firstName: $firstName, lastName: $lastName, email: $email)';
}

/// Request payload for user login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() => 'LoginRequest(email: $email)';
}

/// Request payload for email confirmation with OTP
class ConfirmEmailRequest {
  final String email;
  final String otp;

  ConfirmEmailRequest({
    required this.email,
    required this.otp,
  });

  factory ConfirmEmailRequest.fromJson(Map<String, dynamic> json) {
    return ConfirmEmailRequest(
      email: json['email'] as String? ?? '',
      otp: json['otp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  @override
  String toString() => 'ConfirmEmailRequest(email: $email, otp: $otp)';
}

/// User profile information
class UserProfile {
  final String firstName;
  final String lastName;
  final String email;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  @override
  String toString() =>
      'UserProfile(firstName: $firstName, lastName: $lastName, email: $email)';
}
