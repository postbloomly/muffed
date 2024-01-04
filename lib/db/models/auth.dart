import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
final class AuthRepository extends Equatable {
  const AuthRepository({
    required this.lemmy,
  });

  factory AuthRepository.fromJson(Map<String, dynamic> json) =>
      _$AuthRepositoryFromJson(json);

  final LemmyAuthRepository lemmy;

  Map<String, dynamic> toJson() => _$AuthRepositoryToJson(this);

  @override
  List<Object?> get props => [
        lemmy,
      ];
}

@JsonSerializable()
final class LemmyAuthRepository extends Equatable {
  const LemmyAuthRepository({
    required this.keys,
    required this.activeKeyIndex,
  });

  factory LemmyAuthRepository.fromJson(Map<String, dynamic> json) =>
      _$LemmyAuthRepositoryFromJson(json);

  final List<LemmyAuthKey> keys;
  final int activeKeyIndex;

  bool get loggedIn => keys[activeKeyIndex] is LemmyUserAuthKey;
  LemmyAuthKey get activeKey => keys[activeKeyIndex];

  LemmyUserAuthKey? get _userAuthKey => loggedIn
      ? keys[activeKeyIndex] as LemmyUserAuthKey
      : null;

  int? get activeUserId => _userAuthKey?.userInfo?.id;

  String? get jwt => _userAuthKey?.jwt;

  String get activeHost => activeKey.url;

  Map<String, dynamic> toJson() => _$LemmyAuthRepositoryToJson(this);

  @override
  List<Object?> get props => [
        keys,
        activeKeyIndex,
      ];
}

/// Not meant to be used directly.
@JsonSerializable()
final class LemmyAuthKey extends Equatable {
  const LemmyAuthKey({
    required this.url,
  });

  factory LemmyAuthKey.fromJson(Map<String, dynamic> json) =>
      _$LemmyAuthKeyFromJson(json);

  final String url;

  Map<String, dynamic> toJson() => _$LemmyAuthKeyToJson(this);

  @override
  List<Object?> get props => [
        url,
      ];
}

@JsonSerializable()
final class LemmyAnonAuthKey extends LemmyAuthKey {
  const LemmyAnonAuthKey({
    required super.url,
    required this.name,
    required this.id,
  });

  factory LemmyAnonAuthKey.fromJson(Map<String, dynamic> json) =>
      _$LemmyAnonAuthKeyFromJson(json);

  // Local only, the user chooses and can change the name
  final String name;

  // Unique id, local only, user cant see or change
  final int id;

  Map<String, dynamic> toJson() => _$LemmyAnonAuthKeyToJson(this);

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        id,
      ];
}

@JsonSerializable()
final class LemmyUserAuthKey extends LemmyAuthKey {
  const LemmyUserAuthKey({
    required super.url,
    required this.jwt,
    this.userInfo,
  });

  factory LemmyUserAuthKey.fromJson(Map<String, dynamic> json) =>
      _$LemmyUserAuthKeyFromJson(json);

  final String jwt;
  final LemmyUserAuthInfo? userInfo;

  Map<String, dynamic> toJson() => _$LemmyUserAuthKeyToJson(this);

  @override
  List<Object?> get props => [
        ...super.props,
        jwt,
        userInfo,
      ];
}

@JsonSerializable()
final class LemmyUserAuthInfo extends Equatable {
  const LemmyUserAuthInfo({
    required this.name,
    required this.id,
    this.displayName,
    this.avatar,
    this.banner,
  });

  factory LemmyUserAuthInfo.fromJson(Map<String, dynamic> json) =>
      _$LemmyUserAuthInfoFromJson(json);

  final String name;
  final int id;
  final String? displayName;
  final String? avatar;
  final String? banner;

  Map<String, dynamic> toJson() => _$LemmyUserAuthInfoToJson(this);

  @override
  List<Object?> get props => [
        name,
        id,
        displayName,
        banner,
        avatar,
      ];
}
