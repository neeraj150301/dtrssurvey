import 'dart:async';
import 'package:dtrs_survey/features/survey/presentation/pages/survey_details_page.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/survey_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../data/models/structure_model.dart';
import '../bloc/structures_bloc.dart';
import '../bloc/structures_event.dart';
import '../bloc/structures_state.dart';

class StructuresListPage extends StatelessWidget {
  final User user;
  final String title;
  const StructuresListPage({
    super.key,
    required this.user,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StructuresBloc()..add(LoadStructures(user.username, title)),
      child: _StructuresListView(title),
    );
  }
}

class _StructuresListView extends StatefulWidget {
  final String title;
  const _StructuresListView(this.title);

  @override
  State<_StructuresListView> createState() => _StructuresListViewState();
}

class _StructuresListViewState extends State<_StructuresListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<StructuresBloc>().add(
        SearchStructures(_searchController.text),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.backgroundGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      color: AppColors.cardBackground,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by Structure Code, Equipment Id, Serial...',
          fillColor: Colors.white,
          filled: true,
          // CLEAR BUTTON
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();

                    context.read<StructuresBloc>().add(
                      LoadStructures(
                        context.read<StructuresBloc>().state is StructuresLoaded
                            ? (context.read<StructuresBloc>().state
                                      as StructuresLoaded)
                                  .username
                            : "",
                        widget.title,
                        page: 1,
                      ),
                    );
                  },
                )
              : null,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<StructuresBloc, StructuresState>(
      builder: (context, state) {
        if (state is StructuresInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StructuresLoading) {
          if (state.oldState == null) {
            return const Center(child: CircularProgressIndicator());
          }
        }

        if (state is StructuresError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${state.message}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          );
        }

        StructuresLoaded? loadedState;
        if (state is StructuresLoaded) loadedState = state;
        if (state is StructuresLoading && state.oldState != null) {
          loadedState = state.oldState;
        }

        if (loadedState != null) {
          if (loadedState.filteredStructures.isEmpty) {
            return const Center(child: Text('No structures found.'));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 12,
                ),
                itemCount: loadedState.allStructures.length + 1,
                itemBuilder: (context, index) {
                  if (index == loadedState!.allStructures.length) {
                    return _buildPagination(context, loadedState);
                  }
                  final structure = loadedState.allStructures[index];
                  return _buildStructureCard(structure, context);
                },
              ),
              if (state is StructuresLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPagination(BuildContext context, StructuresLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: First, Previous
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageButton(
                'First',
                enabled: state.currentPage > 1,
                onPressed: () => context.read<StructuresBloc>().add(
                  LoadStructures(
                    state.username,
                    state.title,
                    page: 1,
                    searchQuery: _searchController.text, // KEEP SEARCH
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildPageButton(
                'Previous',
                enabled: state.currentPage > 1,
                onPressed: () => context.read<StructuresBloc>().add(
                  LoadStructures(
                    state.username,
                    state.title,
                    page: state.currentPage - 1,
                    searchQuery: _searchController.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Input and Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${state.currentPage}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${state.totalPages} (${state.totalRecords} records)',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Next, Last
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageButton(
                'Next',
                enabled: state.currentPage < state.totalPages,
                onPressed: () => context.read<StructuresBloc>().add(
                  LoadStructures(
                    state.username,
                    state.title,
                    page: state.currentPage + 1,
                    searchQuery: _searchController.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildPageButton(
                'Last',
                enabled: state.currentPage < state.totalPages,
                onPressed: () => context.read<StructuresBloc>().add(
                  LoadStructures(
                    state.username,
                    state.title,
                    page: state.totalPages,
                    searchQuery: _searchController.text,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(
    String text, {
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? Colors.black87 : Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStructureCard(Structure structure, BuildContext context) {
    final bool isPending = structure.surveyStatus.toLowerCase() == 'pending';
    final bool isCompleted =
        structure.surveyStatus.toLowerCase() == 'completed';
    final Color statusColor = isPending ? Colors.orange : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    structure.structname,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    structure.surveyStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.qr_code,
              'Structure Code',
              structure.structurecode,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.electrical_services,
                    'Equipment',
                    structure.equipment ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.numbers,
                    'Serial',
                    structure.serialnumber ?? 'N/A',
                  ),
                ),
              ],
            ),

            if (isPending) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurveyPage(structure: structure, isRetake: false,),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.assignment,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Start Survey',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            if (isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurveyDetailsPage(
                          structure: structure),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
