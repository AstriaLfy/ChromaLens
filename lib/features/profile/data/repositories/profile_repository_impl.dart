import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

  ProfileRepositoryImpl({required this.dataSource});

  @override
  Future<UserProfileEntity> getUserProfile() {
    return dataSource.getUserProfile();
  }

  @override
  Future<void> updateNotificationPreference(bool enabled) {
    return dataSource.updateNotificationPreference(enabled);
  }
}
