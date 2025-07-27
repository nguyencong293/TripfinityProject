import 'package:json_annotation/json_annotation.dart';

part 'reset_password.g.dart';

@JsonSerializable()
class ResetPassword {
  final String email;
  final String otp;
  final String newPassword;
  final String newConfirmPassword;

  ResetPassword({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.newConfirmPassword,
  });

  factory ResetPassword.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordToJson(this);
}
