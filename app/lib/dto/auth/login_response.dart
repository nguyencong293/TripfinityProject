import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String token;
  final String type;
  final int userId;
  final String name;
  final String email;

  LoginResponse({
    required this.token,
    this.type = 'Bearer',
    required this.userId,
    required this.name,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
