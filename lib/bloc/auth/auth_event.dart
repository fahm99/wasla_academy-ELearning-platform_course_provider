import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String userType;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.userType = 'provider',
  });

  @override
  List<Object?> get props => [name, email, password, phone, userType];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthForgotPassword extends AuthEvent {
  final String email;

  const AuthForgotPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPassword extends AuthEvent {
  final String token;
  final String newPassword;

  const AuthResetPassword({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}
