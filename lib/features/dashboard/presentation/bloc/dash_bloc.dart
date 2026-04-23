import 'package:dtrs_survey/core/storage/secure_storage_helper.dart';
import 'package:dtrs_survey/features/dashboard/data/repositories/dash_repository.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/dash_event.dart';
import 'package:dtrs_survey/features/dashboard/presentation/bloc/dash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final token = await SecureStorageHelper.getToken();

      if (token == null) {
        throw Exception("Token not found");
      }

      final data = await repository.getDashboardData(event.phone, token);

      emit(
        state.copyWith(
          isLoading: false,
          total: data['total'],
          pending: data['pending'],
          completed: data['completed'],
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
