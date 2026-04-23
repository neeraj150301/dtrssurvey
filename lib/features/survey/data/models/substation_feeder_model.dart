class Substation {
  final String sscode;
  final String ssname;

  Substation({required this.sscode, required this.ssname});

  factory Substation.fromJson(Map<String, dynamic> json) {
    return Substation(
      sscode: json['sscode']?.toString() ?? '',
      ssname: json['ssname'] ?? '',
    );
  }
}

class Feeder {
  final String feedercode;
  final String feedername;

  Feeder({required this.feedercode, required this.feedername});

  factory Feeder.fromJson(Map<String, dynamic> json) {
    return Feeder(
      feedercode: json['feedercode']?.toString() ?? '',
      feedername: json['feedername'] ?? '',
    );
  }
}