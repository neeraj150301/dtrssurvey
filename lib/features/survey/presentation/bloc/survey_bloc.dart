import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/survey_repository.dart';
import 'survey_event.dart';
import 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  final SurveyRepository _repository;

  SurveyBloc({SurveyRepository? repository})
    : _repository = repository ?? SurveyRepository(),
      super(const SurveyState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<SubstationChanged>(_onSubstationChanged);
    on<FeederChanged>(_onFeederChanged);
  }

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<SurveyState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final substations = await _repository.getSubstations(event.sectionCode);

      // Load feeders initially if substationCode is provided, otherwise just empty list
      var feeders = <dynamic>[];
      if (event.substationCode.isNotEmpty) {
        emit(state.copyWith(substations: substations, isFeederLoading: true));
        feeders = await _repository.getFeeders(event.substationCode);
      }

      // Check if the provided substationCode is actually in the list of fetched substations
      String? selectedSubstation = event.substationCode;
      if (selectedSubstation.isNotEmpty &&
          !substations.any((s) => s.sscode == selectedSubstation)) {
        selectedSubstation = null; // Reset if invalid
      }

      emit(
        state.copyWith(
          isLoading: false,
          isFeederLoading: false,
          substations: substations,
          feeders: feeders.cast(),
          selectedSubstation: selectedSubstation,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isFeederLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSubstationChanged(
    SubstationChanged event,
    Emitter<SurveyState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedSubstation: event.substationCode,
        selectedFeeder: null, // Clear selected feeder
        feeders: [], // Clear feeders list while loading new ones
        isFeederLoading: true,
      ),
    );

    try {
      final feeders = await _repository.getFeeders(event.substationCode);
      emit(state.copyWith(isFeederLoading: false, feeders: feeders));
    } catch (e) {
      emit(state.copyWith(isFeederLoading: false, error: e.toString()));
    }
  }

  void _onFeederChanged(FeederChanged event, Emitter<SurveyState> emit) {
    emit(state.copyWith(selectedFeeder: event.feederCode));
  }
}
