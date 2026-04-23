class OcrData {
  final String serialNo;
  final String amperesHv;
  final String amperesLv;
  final String capacity;
  final String transformeryType;
  final String manufacturer;
  final String manufactureDate;
  final String orderNo;

  OcrData({
    required this.serialNo,
    required this.amperesHv,
    required this.amperesLv,
    required this.capacity,
    required this.transformeryType,
    required this.manufacturer,
    required this.manufactureDate,
    required this.orderNo,
  });

  factory OcrData.fromJson(Map<String, dynamic> json) {
    return OcrData(
      serialNo: json['serial_no'] ?? "",
      capacity: json['capacity_kva'] ?? "",
      manufacturer: json['manufacturer'] ?? "",
      amperesHv: json['amperes_hv'] ?? "",
      amperesLv: json['amperes_lv'] ?? "",
      transformeryType: json['transformer_type'] ?? "",
      manufactureDate: json['month_and_year_of_manufacture'] ?? "",
      orderNo: json['order_number'] ?? "",
    );
  }
}
