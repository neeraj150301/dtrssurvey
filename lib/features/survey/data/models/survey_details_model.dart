class SurveyDetailsResponse {
  final int id;
  final String circode;
  final int? divcd;
  final int? subdivcd;
  final int? uksec;
  final String? aePhno;
  final String sscode;
  final String? feedercode;
  final String structurecode;

  final Map<String, dynamic>? extractedJson;
  final Map<String, dynamic>? editedJson;

  final bool? isEdited;
  final int? surveyedByUserId;

  final String? nameplateSerialPhotoUrl;
  final String? nameplatePhotoUrl;
  final String? dtrPhotoUrl;
  final String? dtrFrontPhotoUrl;
  final String? dtrBackPhotoUrl;
  final String? dtrLeftPhotoUrl;
  final String? dtrRightPhotoUrl;

  final int? agriculturalConnections;

  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;

  final String? ssname;
  final String? feedername;

  final bool? isMeterAvailable;
  final String? meterDevicePhotoUrl;

  final List<GpsHistory>? gpsHistory;

  final bool? isRetake;
  final int? originalSurveyId;

  final String? structname;
  final String? equipment;
  final String? serialnumber;
  final String? agency;
  final String? surveyType;
  final DateTime? createdAt;

  SurveyDetailsResponse({
    required this.id,
    required this.circode,
    required this.sscode,
    required this.structurecode,
    this.divcd,
    this.subdivcd,
    this.uksec,
    this.aePhno,
    this.feedercode,
    this.extractedJson,
    this.editedJson,
    this.isEdited,
    this.surveyedByUserId,
    this.nameplateSerialPhotoUrl,
    this.nameplatePhotoUrl,
    this.dtrPhotoUrl,
    this.dtrFrontPhotoUrl,
    this.dtrBackPhotoUrl,
    this.dtrLeftPhotoUrl,
    this.dtrRightPhotoUrl,
    this.agriculturalConnections,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.ssname,
    this.feedername,
    this.isMeterAvailable,
    this.meterDevicePhotoUrl,
    this.gpsHistory,
    this.isRetake,
    this.originalSurveyId,
    this.structname,
    this.equipment,
    this.serialnumber,
    this.agency,
    this.surveyType,
    this.createdAt,
  });

  factory SurveyDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SurveyDetailsResponse(
      id: json['id'] ?? 0,
      circode: json['circode']?.toString() ?? '',
      sscode: json['sscode']?.toString() ?? '',
      structurecode: json['structurecode']?.toString() ?? '',

      divcd: json['divcd'],
      subdivcd: json['subdivcd'],
      uksec: json['uksec'],
      aePhno: json['ae_phno']?.toString(),
      feedercode: json['feedercode']?.toString(),

      extractedJson: json['extracted_json'],
      editedJson: json['edited_json'],

      isEdited: json['is_edited'],
      surveyedByUserId: json['surveyedby_user_id'],

      nameplateSerialPhotoUrl: json['nameplate_serial_photo_url'],
      nameplatePhotoUrl: json['nameplate_photo_url'],
      dtrPhotoUrl: json['dtr_photo_url'],
      dtrFrontPhotoUrl: json['dtr_front_photo_url'],
      dtrBackPhotoUrl: json['dtr_back_photo_url'],
      dtrLeftPhotoUrl: json['dtr_left_photo_url'],
      dtrRightPhotoUrl: json['dtr_right_photo_url'],

      agriculturalConnections: json['agricultural_connections'],

      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracy: (json['location_accuracy'] as num?)?.toDouble(),

      ssname: json['ssname'],
      feedername: json['feedername'],

      isMeterAvailable: json['is_meter_available'],
      meterDevicePhotoUrl: json['meter_device_photo_url'],

      gpsHistory: (json['gps_coordinates_history'] as List?)
          ?.map((e) => GpsHistory.fromJson(e))
          .toList(),

      isRetake: json['is_retake'],
      originalSurveyId: json['original_survey_id'],

      structname: json['structname'],
      equipment: json['equipment'],
      serialnumber: json['serialnumber'],
      agency: json['agency'],
      surveyType: json['survey_type'],
      createdAt: json['created_at'] != null
    ? DateTime.parse(json['created_at'])
    : null,
    );
  }
}

class GpsHistory {
  final String? source;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? timestamp;

  GpsHistory({
    this.source,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.timestamp,
  });

  factory GpsHistory.fromJson(Map<String, dynamic> json) {
    return GpsHistory(
      source: json['source'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: json['timestamp'],
    );
  }
}