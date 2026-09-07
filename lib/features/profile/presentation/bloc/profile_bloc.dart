import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class ToggleNotification extends ProfileEvent {
  final bool enabled;
  ToggleNotification(this.enabled);
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ToggleNotification>(_onToggleNotification);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await repository.getUserProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onToggleNotification(
    ToggleNotification event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      final updatedProfile =
          currentProfile.copyWith(notificationEnabled: event.enabled);
      emit(ProfileLoaded(updatedProfile));
      try {
        await repository.updateNotificationPreference(event.enabled);
      } catch (_) {
        // Rollback on failure if needed
      }
    }
  }
}
