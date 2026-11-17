import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:burning_rank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:burning_rank_app/features/record/data/repositories/workout_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  final WorkoutRepository _workoutRepository;

  ProfileCubit({
    required AuthRepository authRepository,
    required WorkoutRepository workoutRepository,
  }) : _authRepository = authRepository,
       _workoutRepository = workoutRepository,
       super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      await _workoutRepository.requestPermissions();
      final user = await _authRepository.checkAuthStatus();
      final totalCalories = await _workoutRepository.getTotalCalories();
      final workoutDays = await _workoutRepository.getWorkoutDaysCount();

      emit(
        ProfileLoaded(
          user: user,
          totalCalories: totalCalories,
          workoutDays: workoutDays,
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
