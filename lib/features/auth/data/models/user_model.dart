import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.token,
    super.colorVisionType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? 'ChromaLens User',
      token: json['token'] as String? ?? json['access_token'] as String?,
      colorVisionType: json['color_vision_type'] as String? ?? json['colorblind_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (token != null) 'token': token,
      if (colorVisionType != null) 'color_vision_type': colorVisionType,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      token: entity.token,
      colorVisionType: entity.colorVisionType,
    );
  }
}
