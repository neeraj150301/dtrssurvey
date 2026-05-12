import 'package:dtrs_survey/features/dashboard/data/models/structure_model.dart';

class ExportStructuresResponse {
  final List<Structure> data;
  final int total;

  ExportStructuresResponse({
    required this.data,
    required this.total,
  });

  factory ExportStructuresResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExportStructuresResponse(
      data: (json['data'] as List)
          .map((e) => Structure.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}