class UserProfileEntity {
  final String name;
  final String email;
  final String colorblindType;
  final String joinedDate;
  final String? avatarUrl;
  final bool notificationEnabled;
  final String language;

  const UserProfileEntity({
    required this.name,
    required this.email,
    required this.colorblindType,
    required this.joinedDate,
    this.avatarUrl,
    this.notificationEnabled = true,
    this.language = 'Indonesia',
  });

  UserProfileEntity copyWith({
    String? name,
    String? email,
    String? colorblindType,
    String? joinedDate,
    String? avatarUrl,
    bool? notificationEnabled,
    String? language,
  }) {
    return UserProfileEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      colorblindType: colorblindType ?? this.colorblindType,
      joinedDate: joinedDate ?? this.joinedDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      language: language ?? this.language,
    );
  }
}
