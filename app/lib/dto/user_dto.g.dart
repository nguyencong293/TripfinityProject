// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDTO _$UserDTOFromJson(Map<String, dynamic> json) => UserDTO(
  userId: (json['userId'] as num?)?.toInt(),
  email: json['email'] as String,
  passwordHash: json['passwordHash'] as String,
  confirmPassword: json['confirmPassword'] as String?,
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  accountRole:
      $enumDecodeNullable(_$AccountRoleEnumMap, json['accountRole']) ??
      AccountRole.TOURIST,
  accountStatus:
      $enumDecodeNullable(_$AccountStatusEnumMap, json['accountStatus']) ??
      AccountStatus.ACTIVE,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  resetOtp: json['resetOtp'] as String?,
  otpExpiryTime: json['otpExpiryTime'] == null
      ? null
      : DateTime.parse(json['otpExpiryTime'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserDTOToJson(UserDTO instance) => <String, dynamic>{
  'userId': instance.userId,
  'email': instance.email,
  'passwordHash': instance.passwordHash,
  'confirmPassword': instance.confirmPassword,
  'fullName': instance.fullName,
  'phoneNumber': instance.phoneNumber,
  'avatarUrl': instance.avatarUrl,
  'accountRole': _$AccountRoleEnumMap[instance.accountRole]!,
  'accountStatus': _$AccountStatusEnumMap[instance.accountStatus]!,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'gender': _$GenderEnumMap[instance.gender],
  'resetOtp': instance.resetOtp,
  'otpExpiryTime': instance.otpExpiryTime?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$AccountRoleEnumMap = {
  AccountRole.TOURIST: 'TOURIST',
  AccountRole.PROVIDER: 'PROVIDER',
  AccountRole.ADMIN: 'ADMIN',
};

const _$AccountStatusEnumMap = {
  AccountStatus.ACTIVE: 'ACTIVE',
  AccountStatus.BANNED: 'BANNED',
};

const _$GenderEnumMap = {
  Gender.MALE: 'MALE',
  Gender.FEMALE: 'FEMALE',
  Gender.OTHER: 'OTHER',
};
