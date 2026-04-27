class Profile {
  final String? name;
  final String? employeeCode;
  final String mobile;
  final String circleCode;
  final String circleName;
  final String divisionCode;
  final String divisionName;
  final String subdivisionCode;
  final String subdivisionName;
  final String sectionCode;
  final String sectionName;

  Profile({
    this.name,
    this.employeeCode,
    required this.mobile,
    required this.circleCode,
    required this.circleName,
    required this.divisionCode,
    required this.divisionName,
    required this.subdivisionCode,
    required this.subdivisionName,
    required this.sectionCode,
    required this.sectionName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['ae_name'],
      employeeCode: json['ae_employee_code'],
      mobile: json['ae_mobile_no'] ?? "",
      circleCode: json['circle_code'] ?? "",
      circleName: json['circle_name'] ?? "",
      divisionCode: json['division_code'] ?? "",
      divisionName: json['division_name'] ?? "",
      subdivisionCode: json['subdivision_code'] ?? "",
      subdivisionName: json['subdivision_name'] ?? "",
      sectionCode: json['section_code'] ?? "",
      sectionName: json['section_name'] ?? "",
    );
  }
} 