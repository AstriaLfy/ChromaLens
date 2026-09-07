import '../../domain/entities/user_profile_entity.dart';
import '../services/profile_api_service.dart';
import 'profile_data_source.dart';

class RemoteProfileDataSourceImpl implements ProfileDataSource {
  final ProfileApiService apiService;
  final LocalProfileDataSourceImpl _localFallback;

  RemoteProfileDataSourceImpl({
    required this.apiService,
    LocalProfileDataSourceImpl? localFallback,
  }) : _localFallback = localFallback ?? LocalProfileDataSourceImpl();

  @override
  Future<UserProfileEntity> getUserProfile() async {
    try {
      return await apiService.getProfile();
    } catch (_) {
      return await _localFallback.getUserProfile();
    }
  }

  @override
  Future<void> updateNotificationPreference(bool enabled) async {
    try {
      await apiService.updateSettings(notificationEnabled: enabled);
    } catch (_) {
      await _localFallback.updateNotificationPreference(enabled);
    }
  }
}
