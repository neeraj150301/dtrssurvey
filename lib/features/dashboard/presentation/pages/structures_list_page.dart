import 'dart:async';
import 'dart:typed_data';
import 'package:dtrs_survey/core/storage/secure_storage_helper.dart';
import 'package:dtrs_survey/features/dashboard/data/repositories/dash_repository.dart';
import 'package:dtrs_survey/features/dashboard/presentation/pages/widgets/status_stamp.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/survey_details_page.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/survey_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../data/models/structure_model.dart';
import '../bloc/structure_bloc/structures_bloc.dart';
import '../bloc/structure_bloc/structures_event.dart';
import '../bloc/structure_bloc/structures_state.dart';
import 'package:excel/excel.dart' as excel;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
  bool isExporting = false;

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

  Future<List<Structure>> _getExportData() async {
    final token = await SecureStorageHelper.getToken();

    if (token == null) {
      throw Exception("Token not found");
    }

    final state = context.read<StructuresBloc>().state;

    if (state is! StructuresLoaded) {
      throw Exception("Invalid state");
    }

    final repo = DashboardRepository();

    final response = await repo.getAllStructuresForExport(
      state.title,
      state.username,
      token,
      search: _searchController.text,
    );

    return response.data;
  }

  Future<void> _exportPdf() async {
    try {
      setState(() {
        isExporting = true;
      });

      // await Permission.manageExternalStorage.request();

      final data = await _getExportData();

      final pdf = PdfDocument();

      final page = pdf.pages.add();

      final grid = PdfGrid();

      grid.columns.add(count: 12);

      grid.headers.add(1);

      final header = grid.headers[0];

      header.cells[0].value = 'S.No';
      header.cells[1].value = 'Structure Code';
      header.cells[2].value = 'Structure Name';
      header.cells[3].value = 'Equipment Id';
      header.cells[4].value = 'Serial No';
      header.cells[5].value = 'Agency';
      header.cells[6].value = 'Circle';
      header.cells[7].value = 'Division';
      header.cells[8].value = 'Subdivision';
      header.cells[9].value = 'Section';
      header.cells[10].value = 'Feeder';
      header.cells[11].value = 'Status';

      for (int i = 0; i < data.length; i++) {
        final row = grid.rows.add();

        final item = data[i];

        row.cells[0].value = '${i + 1}';
        row.cells[1].value = item.structurecode;
        row.cells[2].value = item.structname;
        row.cells[3].value = item.equipment ?? '';
        row.cells[4].value = item.serialnumber ?? '';
        row.cells[5].value = item.agency ?? '';
        row.cells[6].value = item.cirname;
        row.cells[7].value = item.divname;
        row.cells[8].value = item.subdivname;
        row.cells[9].value = item.secname;
        row.cells[10].value = item.feedername;
        row.cells[11].value = item.surveyStatus.toUpperCase();
      }

      grid.draw(page: page, bounds: const Rect.fromLTWH(0, 50, 0, 0));

      page.graphics.drawString(
        'Total DTRs Report',
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: const Rect.fromLTWH(0, 0, 500, 30),
      );

      page.graphics.drawString(
        'Generated on: ${DateFormat('dd/MM/yyyy, hh:mm:ss a').format(DateTime.now())}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: const Rect.fromLTWH(0, 25, 500, 20),
      );

      final bytes = await pdf.save();

      pdf.dispose();

      // Directory? dir;

      // if (Platform.isAndroid) {
      //   dir = Directory('/storage/emulated/0/Download');
      // } else {
      //   dir = await getApplicationDocumentsDirectory();
      // }

      // final file = File(
      //   '${dir.path}/dtrs_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      // );

      // await file.writeAsBytes(bytes);

      // OpenFilex.open(file.path);
      final filePath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: Uint8List.fromList(bytes),
          fileName: 'dtrs_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        ),
      );

      if (filePath != null) {
        OpenFilex.open(filePath);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved in Download folder')));
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  Future<void> _exportExcel() async {
    try {
      // await Permission.manageExternalStorage.request();

      setState(() => isExporting = true);

      final data = await _getExportData();

      final excell = excel.Excel.createExcel();
      excell.delete('Sheet1');
      final sheet = excell['DTR Report'];

      sheet.appendRow([excel.TextCellValue('Total DTRs Report')]);

      sheet.appendRow([
        excel.TextCellValue(
          'Generated on: ${DateFormat('dd/MM/yyyy hh:mm:ss a').format(DateTime.now())}',
        ),
      ]);

      sheet.appendRow([]);

      sheet.appendRow([
        excel.TextCellValue('S.No'),
        excel.TextCellValue('Structure Code'),
        excel.TextCellValue('Structure Name'),
        excel.TextCellValue('Equipment Id'),
        excel.TextCellValue('Serial No'),
        excel.TextCellValue('Agency'),
        excel.TextCellValue('Circle'),
        excel.TextCellValue('Division'),
        excel.TextCellValue('Subdivision'),
        excel.TextCellValue('Section'),
        excel.TextCellValue('Feeder'),
        excel.TextCellValue('Status'),
      ]);

      for (int i = 0; i < data.length; i++) {
        final item = data[i];

        sheet.appendRow([
          excel.IntCellValue(i + 1),
          excel.TextCellValue(item.structurecode),
          excel.TextCellValue(item.structname),
          excel.TextCellValue(item.equipment ?? ''),
          excel.TextCellValue(item.serialnumber ?? ''),
          excel.TextCellValue(item.agency ?? ''),
          excel.TextCellValue(item.cirname),
          excel.TextCellValue(item.divname),
          excel.TextCellValue(item.subdivname),
          excel.TextCellValue(item.secname),
          excel.TextCellValue(item.feedername),
          excel.TextCellValue(item.surveyStatus.toUpperCase()),
        ]);
      }

      // Directory? dir;

      // if (Platform.isAndroid) {
      //   dir = Directory('/storage/emulated/0/Download');
      // } else {
      //   dir = await getApplicationDocumentsDirectory();
      // }

      // final file = File(
      //   '${dir.path}/dtrs_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      // );


      final bytes = excell.encode();

      if (bytes == null) {
        throw Exception("Failed to generate Excel file");
      }

final filePath = await FlutterFileDialog.saveFile(
  params: SaveFileDialogParams(
    data: Uint8List.fromList(bytes),
    fileName:
        'dtrs_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
  ),
);

if (filePath != null) {
  OpenFilex.open(filePath);
}

      // await file.writeAsBytes(bytes, flush: true);

      // OpenFilex.open(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel saved in Download folder')),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
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
        actions: [
          if (isExporting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.download),
              onSelected: (value) async {
                if (value == "pdf") {
                  await _exportPdf();
                } else {
                  await _exportExcel();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "pdf",
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Export PDF"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "excel",
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Export Excel"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          _buildSearchText(),
          SizedBox(height: 4),
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
          hintText: 'Search Structure / Equip ID / Serial No',
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

  Widget _buildSearchText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Text(
        'Search by Structure Name, Structure Code, Equipment Id, Serial No',
        maxLines: 1,
        style: TextStyle(fontSize: 12),
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
                StatusStamp(
                  statusColor: statusColor,
                  text: structure.surveyStatus.toUpperCase(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.qr_code,
                    'Structure Code',
                    structure.structurecode,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.electrical_services,
                    'Equipment',
                    structure.equipment ?? 'N/A',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.numbers,
                    'Serial Number',
                    structure.serialnumber ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.assignment,
                    'Agency',
                    structure.agency ?? 'N/A',
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
                        builder: (_) =>
                            SurveyPage(structure: structure, isRetake: false),
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
                        builder: (_) => SurveyDetailsPage(structure: structure),
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
