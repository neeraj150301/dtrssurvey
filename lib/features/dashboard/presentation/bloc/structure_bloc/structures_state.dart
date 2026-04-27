import 'package:equatable/equatable.dart';
import '../../../data/models/structure_model.dart';

abstract class StructuresState extends Equatable {
  const StructuresState();

  @override
  List<Object> get props => [];
}

class StructuresInitial extends StructuresState {}

class StructuresLoading extends StructuresState {
  final StructuresLoaded? oldState;
  const StructuresLoading({this.oldState});
  
  @override
  List<Object> get props => oldState != null ? [oldState!] : [];
}

class StructuresLoaded extends StructuresState {
  final List<Structure> allStructures;
  final List<Structure> filteredStructures;
  final String username;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final String title;

  const StructuresLoaded({
    required this.allStructures,
    required this.filteredStructures,
    required this.username,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.title,
  });

  StructuresLoaded copyWith({
    List<Structure>? allStructures,
    List<Structure>? filteredStructures,
    String? username,
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    String? title,
  }) {
    return StructuresLoaded(
      allStructures: allStructures ?? this.allStructures,
      filteredStructures: filteredStructures ?? this.filteredStructures,
      username: username ?? this.username,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      title: title ?? this.title,
    );
  }

  @override
  List<Object> get props => [allStructures, filteredStructures, username, currentPage, totalPages, totalRecords, title];
}

class StructuresError extends StructuresState {
  final String message;
  const StructuresError(this.message);

  @override
  List<Object> get props => [message];
}
