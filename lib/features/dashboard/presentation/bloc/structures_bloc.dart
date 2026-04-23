import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../../data/repositories/dash_repository.dart';
import 'structures_event.dart';
import 'structures_state.dart';

class StructuresBloc extends Bloc<StructuresEvent, StructuresState> {
  final DashboardRepository _repository;

  StructuresBloc({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository(),
        super(StructuresInitial()) {
    on<LoadStructures>(_onLoadStructures);
    on<SearchStructures>(_onSearchStructures);
    on<ChangePage>(_onChangePage);
  }

  Future<void> _onLoadStructures(
      LoadStructures event, Emitter<StructuresState> emit) async {
    
    StructuresLoaded? oldState;
    if (state is StructuresLoaded) {
      oldState = state as StructuresLoaded;
    }
    emit(StructuresLoading(oldState: oldState));
    
    try {
      final token = await SecureStorageHelper.getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await _repository.getStructures(
        event.title,
        event.username, 
        token, 
        page: event.page, 
        pageSize: 100,
        search: event.searchQuery,
      );
      
      emit(StructuresLoaded(
        allStructures: response.structures,
        filteredStructures: response.structures,
        username: event.username,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalRecords: response.total,
        title: event.title,
      ));
    } catch (e) {
      emit(StructuresError(e.toString()));
    }
  }

  void _onChangePage(ChangePage event, Emitter<StructuresState> emit) {
    if (state is StructuresLoaded) {
      final currentState = state as StructuresLoaded;
      if (event.newPage >= 1 && event.newPage <= currentState.totalPages) {
        add(LoadStructures(currentState.username, currentState.title, page: event.newPage));
      }
    }
  }

Future<void> _onSearchStructures(
    SearchStructures event, Emitter<StructuresState> emit) async {

  StructuresLoaded? oldState;
  if (state is StructuresLoaded) {
    oldState = state as StructuresLoaded;
  }

  emit(StructuresLoading(oldState: oldState));

  try {
    final token = await SecureStorageHelper.getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await _repository.getStructures(
      oldState?.title ?? "",
      oldState?.username ?? "",
      token,
      page: 1, // reset page on search
      pageSize: 100,
      search: event.query,
    );

    emit(StructuresLoaded(
      allStructures: response.structures,
      filteredStructures: response.structures,
      username: oldState?.username ?? "",
      currentPage: response.page,
      totalPages: response.totalPages,
      totalRecords: response.total,
      title: oldState?.title ?? "",
    ));
  } catch (e) {
    emit(StructuresError(e.toString()));
  }
}
}
