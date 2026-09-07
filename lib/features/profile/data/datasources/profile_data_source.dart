import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileDataSource {
  Future<UserProfileEntity> getUserProfile();
  Future<void> updateNotificationPreference(bool enabled);
}

class LocalProfileDataSourceImpl implements ProfileDataSource {
  final TokenStorage? tokenStorage;
  bool _notificationEnabled = true;

  LocalProfileDataSourceImpl({this.tokenStorage});

  UserProfileEntity get _currentProfile {
    final name = tokenStorage?.getUserName();
    final email = tokenStorage?.getUserEmail();
    final cond = tokenStorage?.getConditionType();

    return UserProfileEntity(
      name: (name != null && name.isNotEmpty) ? name : 'Pengguna ChromaLens',
      email: (email != null && email.isNotEmpty) ? email : 'user@chromalens.app',
      colorblindType: (cond != null && cond.isNotEmpty) ? cond : 'Deuteranomaly',
      joinedDate: '19 Agt 2024',
      notificationEnabled: _notificationEnabled,
      language: 'Indonesia',
    );
  }

  @override
  Future<UserProfileEntity> getUserProfile() async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentProfile;
  }

  @override
  Future<void> updateNotificationPreference(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _notificationEnabled = enabled;
  }
}
