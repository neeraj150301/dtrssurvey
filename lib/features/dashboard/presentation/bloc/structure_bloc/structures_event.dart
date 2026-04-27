import 'package:equatable/equatable.dart';

abstract class StructuresEvent extends Equatable {
  const StructuresEvent();

  @override
  List<Object> get props => [];
}

class LoadStructures extends StructuresEvent {
  final String username;
  final int page;
  final String title;
  final String? searchQuery;
  const LoadStructures(this.username, this.title, {this.page = 1, this.searchQuery});

  @override
  List<Object> get props => [username, page, title];
}

class SearchStructures extends StructuresEvent {
  final String query;
  const SearchStructures(this.query);

  @override
  List<Object> get props => [query];
}

class ChangePage extends StructuresEvent {
  final int newPage;
  const ChangePage(this.newPage);

  @override
  List<Object> get props => [newPage];
}
