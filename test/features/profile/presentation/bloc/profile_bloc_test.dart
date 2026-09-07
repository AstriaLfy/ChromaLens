import 'package:flutter_test/flutter_test.dart';
import 'package:chroma_lens/features/profile/data/datasources/profile_data_source.dart';
import 'package:chroma_lens/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chroma_lens/features/profile/presentation/bloc/profile_bloc.dart';

void main() {
  late ProfileBloc bloc;
  late ProfileRepositoryImpl repository;
  late LocalProfileDataSourceImpl dataSource;

  setUp(() {
    dataSource = LocalProfileDataSourceImpl();
    repository = ProfileRepositoryImpl(dataSource: dataSource);
    bloc = ProfileBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  test('Initial state should be ProfileInitial', () {
    expect(bloc.state, isA<ProfileInitial>());
  });

  test('LoadProfile emits [ProfileLoading, ProfileLoaded] with Sung Jinwoo profile', () async {
    final expectedStates = [
      isA<ProfileLoading>(),
      isA<ProfileLoaded>().having(
        (state) => state.profile.name,
        'name',
        'Sung Jinwoo',
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));
    bloc.add(LoadProfile());
  });

  test('ToggleNotification updates notificationEnabled flag', () async {
    bloc.add(LoadProfile());
    await Future.delayed(const Duration(milliseconds: 150));

    expect((bloc.state as ProfileLoaded).profile.notificationEnabled, true);

    bloc.add(ToggleNotification(false));
    await Future.delayed(const Duration(milliseconds: 100));

    expect((bloc.state as ProfileLoaded).profile.notificationEnabled, false);
  });
}
