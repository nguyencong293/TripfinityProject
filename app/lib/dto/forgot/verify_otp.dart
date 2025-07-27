import 'package:json_annotation/json_annotation.dart';

part 'verify_otp.g.dart';

@JsonSerializable()
class VerifyOtp {
  final String email;
  final String otp;

  VerifyOtp({required this.email, required this.otp});

  factory VerifyOtp.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpToJson(this);
}
