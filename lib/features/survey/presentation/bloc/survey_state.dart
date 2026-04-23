import 'package:equatable/equatable.dart';
import '../../data/models/substation_feeder_model.dart';

class SurveyState extends Equatable {
  final bool isLoading;
  final bool isFeederLoading;
  final String? error;
  
  final List<Substation> substations;
  final List<Feeder> feeders;
  
  final String? selectedSubstation;
  final String? selectedFeeder;

  const SurveyState({
    this.isLoading = false,
    this.isFeederLoading = false,
    this.error,
    this.substations = const [],
    this.feeders = const [],
    this.selectedSubstation,
    this.selectedFeeder,
  });

  SurveyState copyWith({
    bool? isLoading,
    bool? isFeederLoading,
    String? error,
    List<Substation>? substations,
    List<Feeder>? feeders,
    String? selectedSubstation,
    String? selectedFeeder,
  }) {
    return SurveyState(
      isLoading: isLoading ?? this.isLoading,
      isFeederLoading: isFeederLoading ?? this.isFeederLoading,
      error: error, // Don't preserve error on state change
      substations: substations ?? this.substations,
      feeders: feeders ?? this.feeders,
      selectedSubstation: selectedSubstation ?? this.selectedSubstation,
      selectedFeeder: selectedFeeder ?? this.selectedFeeder,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isFeederLoading,
        error,
        substations,
        feeders,
        selectedSubstation,
        selectedFeeder,
      ];
}
