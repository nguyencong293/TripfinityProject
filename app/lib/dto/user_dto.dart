import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDTO {
  final int? userId;
  final String email;
  final String? passwordHash;
  final String? confirmPassword;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;

  @JsonKey(defaultValue: AccountRole.tourist)
  final AccountRole accountRole;

  @JsonKey(defaultValue: AccountStatus.active)
  final AccountStatus accountStatus;

  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? resetOtp;
  final DateTime? otpExpiryTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserDTO({
    this.userId,
    required this.email,
    this.passwordHash,
    this.confirmPassword,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.accountRole = AccountRole.tourist,
    this.accountStatus = AccountStatus.active,
    this.dateOfBirth,
    this.gender,
    this.resetOtp,
    this.otpExpiryTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a new [UserDTO] instance from a JSON map.
  factory UserDTO.fromJson(Map<String, dynamic> json) =>
      _$UserDTOFromJson(json);

  /// Converts this [UserDTO] instance into a JSON map.
  Map<String, dynamic> toJson() => _$UserDTOToJson(this);
}

enum AccountRole { tourist, provider, admin }

enum AccountStatus { active, banned }

enum Gender { male, female, other }
