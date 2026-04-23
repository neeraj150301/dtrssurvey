class Structure {
  final String structurecode;
  final String structname;
  final String aePhno;
  final String surveyStatus;
  final String circode;
  final String cirname;
  final String divcd;
  final String divname;
  final String subdivcd;
  final String subdivname;
  final String uksec;
  final String secname;
  final String sscode;
  final String ssname;
  final String feedercode;
  final String feedername;
  final String? equipment;
  final String? serialnumber;
  final String? surveyedAt;
  final String? agency;
  final String? surveyUpdatedAt;

  Structure({
    required this.structurecode,
    required this.structname,
    required this.aePhno,
    required this.surveyStatus,
    required this.circode,
    required this.cirname,
    required this.divcd,
    required this.divname,
    required this.subdivcd,
    required this.subdivname,
    required this.uksec,
    required this.secname,
    required this.sscode,
    required this.ssname,
    required this.feedercode,
    required this.feedername,
    this.equipment,
    this.serialnumber,
    this.surveyedAt,
    this.agency,
    this.surveyUpdatedAt,
  });

  factory Structure.fromJson(Map<String, dynamic> json) {
    return Structure(
      structurecode: json['structurecode']?.toString() ?? '',
      structname: json['structname'] ?? '',
      aePhno: json['ae_phno']?.toString() ?? '',
      surveyStatus: json['survey_status'] ?? '',
      circode: json['circode']?.toString() ?? '',
      cirname: json['cirname'] ?? '',
      divcd: json['divcd']?.toString() ?? '',
      divname: json['divname'] ?? '',
      subdivcd: json['subdivcd']?.toString() ?? '',
      subdivname: json['subdivname'] ?? '',
      uksec: json['uksec']?.toString() ?? '',
      secname: json['secname'] ?? '',
      sscode: json['sscode']?.toString() ?? '',
      ssname: json['ssname'] ?? '',
      feedercode: json['feedercode']?.toString() ?? '',
      feedername: json['feedername'] ?? '',
      equipment: json['equipment']?.toString(),
      serialnumber: json['serialnumber']?.toString(),
      surveyedAt: json['surveyed_at']?.toString(),
      agency: json['agency'],
      surveyUpdatedAt: json['survey_updated_at']?.toString(),
    );
  }
}

class StructuresResponse {
  final List<Structure> structures;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  StructuresResponse({
    required this.structures,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory StructuresResponse.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? json['structures'] ?? [];
    return StructuresResponse(
      structures: data.map((item) => Structure.fromJson(item)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 100,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
