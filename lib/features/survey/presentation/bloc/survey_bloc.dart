import 'package:dtrs_survey/features/survey/data/models/substation_feeder_model.dart';
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

      emit(state.copyWith(isLoading: false, substations: substations));

      Substation? matchedSubstation;

      try {
        matchedSubstation = substations.firstWhere(
          (s) => s.sscode == event.substationCode,
        );
      } catch (_) {
        matchedSubstation = null;
      }
      if (matchedSubstation == null) return;
      final selectedSubstation = matchedSubstation.sscode;
      emit(
        state.copyWith(
          selectedSubstation: selectedSubstation,
          isFeederLoading: true,
        ),
      );
      // Feeder? matchedFeeder;

      // String? selectedFeeder;

      List<Feeder> feeders = [];

      try {
        feeders = (await _repository.getFeeders(
          selectedSubstation,
        )).cast<Feeder>();

        // matchedSubstation = substations.firstWhere(
        //   (s) => s.sscode == event.substationCode,
        // );
      } catch (_) {
        emit(
          state.copyWith(
            isFeederLoading: false,
            error: "Failed to load feeders",
          ),
        );
        return;
      }
      String? selectedFeeder;
      try {
        final matchedFeeder = feeders.firstWhere(
          (f) => f.feedercode == event.feederCode,
        );
        selectedFeeder = matchedFeeder.feedercode;
      } catch (_) {
        // selectedFeeder = null;
      }

      emit(
        state.copyWith(
          // isLoading: false,
          // isFeederLoading: false,
          // substations: substations,
          feeders: feeders,
          isFeederLoading: false,
          selectedFeeder: selectedFeeder,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          // isFeederLoading: false,
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
