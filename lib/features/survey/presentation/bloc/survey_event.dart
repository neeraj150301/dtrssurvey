import 'package:equatable/equatable.dart';

abstract class SurveyEvent extends Equatable {
  const SurveyEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialData extends SurveyEvent {
  final String sectionCode;
  final String substationCode;
  final String feederCode;

  const LoadInitialData(this.sectionCode, this.substationCode, this.feederCode);

  @override
  List<Object?> get props => [sectionCode, substationCode];
}

class SubstationChanged extends SurveyEvent {
  final String substationCode;

  const SubstationChanged(this.substationCode);

  @override
  List<Object?> get props => [substationCode];
}

class FeederChanged extends SurveyEvent {
  final String feederCode;

  const FeederChanged(this.feederCode);

  @override
  List<Object?> get props => [feederCode];
}
