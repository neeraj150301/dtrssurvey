import 'dart:io';
import 'dart:convert';
import 'package:dtrs_survey/core/constants/colors.dart';
import 'package:dtrs_survey/core/network/api_constants.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dtrs_survey/features/dashboard/data/models/structure_model.dart';
import 'package:dtrs_survey/features/survey/data/models/ocr_extract_model.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/widgets/info_card.dart';
import 'package:dtrs_survey/core/utils/location_service.dart';

class ReviewSurveyScreen extends StatefulWidget {
  final Structure structure;
  final String selectedSubstation;
  final String selectedFeeder;
  final File structurePhoto;
  final File embossPhoto;
  final File namePlatePhoto;
  final bool isMeterAvailable;
  final File? meterPhoto;
  final OcrData? ocrData;
  final bool isRetake;

  const ReviewSurveyScreen({
    super.key,
    required this.structure,
    required this.selectedSubstation,
    required this.selectedFeeder,
    required this.structurePhoto,
    required this.embossPhoto,
    required this.namePlatePhoto,
    required this.isMeterAvailable,
    this.meterPhoto,
    this.ocrData,
    required this.isRetake,
  });

  @override
  State<ReviewSurveyScreen> createState() => _ReviewSurveyScreenState();
}

class _ReviewSurveyScreenState extends State<ReviewSurveyScreen> {
  late TextEditingController _structureCodeController;
  late TextEditingController _structureNameController;
  late TextEditingController _serialNoController;
  late TextEditingController _amperesHvController;
  late TextEditingController _amperesLvController;
  late TextEditingController _capacityController;
  late TextEditingController _transformerTypeController;
  late TextEditingController _manufacturerController;
  late TextEditingController _manufactureDateController;
  late TextEditingController _orderNoController;
  late TextEditingController _agriConnectionsController;

  late Listenable _formListenable;

  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationService.checkLocationRequirements(context);
      LocationService.monitorLocationService(context);
    });

    _structureCodeController = TextEditingController(
      text: widget.structure.structurecode,
    );
    _structureNameController = TextEditingController(
      text: widget.structure.structname,
    );
    _serialNoController = TextEditingController(
      text: widget.ocrData?.serialNo ?? '',
    );
    _amperesHvController = TextEditingController(
      text: widget.ocrData?.amperesHv ?? '',
    );
    _amperesLvController = TextEditingController(
      text: widget.ocrData?.amperesLv ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.ocrData?.capacity ?? '',
    );
    _transformerTypeController = TextEditingController(
      text: widget.ocrData?.transformeryType ?? '',
    );
    _manufacturerController = TextEditingController(
      text: widget.ocrData?.manufacturer ?? '',
    );
    _manufactureDateController = TextEditingController(
      text: widget.ocrData?.manufactureDate ?? '',
    );
    _orderNoController = TextEditingController(
      text: widget.ocrData?.orderNo ?? '',
    );
    _agriConnectionsController = TextEditingController();

    _formListenable = Listenable.merge([
      _structureCodeController,
      _structureNameController,
      _serialNoController,
      _amperesHvController,
      _amperesLvController,
      _capacityController,
      _transformerTypeController,
      _manufacturerController,
      _manufactureDateController,
      _orderNoController,
      _agriConnectionsController,
    ]);
  }

  @override
  void dispose() {
    _structureCodeController.dispose();
    _structureNameController.dispose();
    _serialNoController.dispose();
    _amperesHvController.dispose();
    _amperesLvController.dispose();
    _capacityController.dispose();
    _transformerTypeController.dispose();
    _manufacturerController.dispose();
    _manufactureDateController.dispose();
    _orderNoController.dispose();
    _agriConnectionsController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _structureCodeController.text.isNotEmpty &&
        _structureNameController.text.isNotEmpty &&
        _serialNoController.text.isNotEmpty &&
        _amperesHvController.text.isNotEmpty &&
        _amperesLvController.text.isNotEmpty &&
        _capacityController.text.isNotEmpty &&
        _transformerTypeController.text.isNotEmpty &&
        _manufacturerController.text.isNotEmpty &&
        _manufactureDateController.text.isNotEmpty &&
        _orderNoController.text.isNotEmpty &&
        _agriConnectionsController.text.isNotEmpty &&
        _currentPosition != null;
  }

  Map<String, String> _getFormData() {
    return {
      "Structure Code": _structureCodeController.text,
      "Structure Name": _structureNameController.text,
      "Serial No": _serialNoController.text,
      "Amperes Hv": _amperesHvController.text,
      "Amperes Lv": _amperesLvController.text,
      "Capacity Kva": _capacityController.text,
      "Transformer Type": _transformerTypeController.text,
      "Manufacturer": _manufacturerController.text,
      "Month And Year Of Manufacture": _manufactureDateController.text,
      "Order Number": _orderNoController.text,
      "Agricultural Connections": _agriConnectionsController.text,
      "Location": _currentPosition != null
          ? "Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)} (±${_currentPosition!.accuracy.toStringAsFixed(0)}m)"
          : "Not captured",
    };
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _PreviewDialog(
          data: _getFormData(),
          onSubmit: _submitSurveyData,
        );
      },
    );
  }

  Future<void> _submitSurveyData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.drtsImageEndpoint}'),
      );

      request.fields['circode'] = widget.structure.circode;
      request.fields['divcd'] = widget.structure.divcd;
      request.fields['subdivcd'] = widget.structure.subdivcd;
      request.fields['uksec'] = widget.structure.uksec;
      request.fields['ae_phno'] = widget.structure.aePhno;
      request.fields['is_retake'] = widget.isRetake.toString();
      request.fields['original_survey_id'] = '';
      request.fields['sscode'] = widget.selectedSubstation;
      request.fields['ssname'] = widget.structure.ssname;
      request.fields['feedercode'] = widget.selectedFeeder;
      request.fields['feedername'] = widget.structure.feedername;
      request.fields['structurecode'] = widget.structure.structurecode;

      request.fields['extracted_json'] = jsonEncode({
        "serial_no": widget.ocrData?.serialNo ?? "",
        "amperes_hv": widget.ocrData?.amperesHv ?? "",
        "amperes_lv": widget.ocrData?.amperesLv ?? "",
        "capacity_kva": widget.ocrData?.capacity ?? "",
        "transformer_type": widget.ocrData?.transformeryType ?? "",
        "manufacturer": widget.ocrData?.manufacturer ?? "",
        "month_and_year_of_manufacture": widget.ocrData?.manufactureDate ?? "",
        "order_number": widget.ocrData?.orderNo ?? "",
      });

      request.fields['edited_json'] = jsonEncode({
        "dtrCode": widget.structure.structurecode,
        "dtrName": _structureNameController.text,
        "agricultural_connections": _agriConnectionsController.text,
        "serial_no": _serialNoController.text,
        "amperes_hv": _amperesHvController.text,
        "amperes_lv": _amperesLvController.text,
        "capacity_kva": _capacityController.text,
        "transformer_type": _transformerTypeController.text,
        "manufacturer": _manufacturerController.text,
        "month_and_year_of_manufacture": _manufactureDateController.text,
        "order_number": _orderNoController.text,
      });

      request.fields['is_edited'] = 'true';
      request.fields['surveyedby_user_id'] = widget.structure.aePhno;
      request.fields['agricultural_connections'] =
          _agriConnectionsController.text;

      if (_currentPosition != null) {
        request.fields['latitude'] = _currentPosition!.latitude.toString();
        request.fields['longitude'] = _currentPosition!.longitude.toString();
        request.fields['location_accuracy'] = _currentPosition!.accuracy
            .toString();

        request.fields['gps_coordinates_history'] = jsonEncode([
          {
            "latitude": _currentPosition!.latitude,
            "longitude": _currentPosition!.longitude,
            "accuracy": _currentPosition!.accuracy,
            "timestamp": DateTime.now().toUtc().toIso8601String(),
            "timestampMs": DateTime.now().millisecondsSinceEpoch,
            "source": "browser",
          },
        ]);
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'nameplate_serial_photo',
          widget.embossPhoto.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'nameplate_photo',
          widget.namePlatePhoto.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'dtr_photo',
          widget.structurePhoto.path,
        ),
      );

      request.fields['is_meter_available'] = widget.isMeterAvailable.toString();
      if (widget.isMeterAvailable && widget.meterPhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'meter_device_photo',
            widget.meterPhoto!.path,
          ),
        );
      }

      var response = await request.send();

      if (mounted) Navigator.pop(context); // pop loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        var resBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $resBody"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // pop loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Survey Submitted Successfully!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your Structure survey has been completed and submitted.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E1E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Back to Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {

      final best = LocationService.getBestPosition();

       if (best == null) {
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Location not ready yet. Please wait...",
        ),
        backgroundColor: Colors.red,
      ),
    );

    }

    setState(() {
      _currentPosition = best;
    });



    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Captured with accuracy: ${best?.accuracy.toStringAsFixed(2)} m",
        ),
        backgroundColor: Colors.green,
      ),
    );

      // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // if (!serviceEnabled) {
      //   if (mounted) await LocationService.checkLocationRequirements(context);
      //   return;
      // }

      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      //   if (permission == LocationPermission.denied) {
      //     throw Exception('Location permissions are denied');
      //   }
      // }

      // if (permission == LocationPermission.deniedForever) {
      //   throw Exception('Location permissions are permanently denied');
      // }

      // Position position = await Geolocator.getCurrentPosition();
      // setState(() {
      //   _currentPosition = position;
      // });

      LocationService.stopGlobalCapture();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  String _displayParam(String? val) {
    if (val == null || val.isEmpty) return "-";
    return val;
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    final isNumberField = hint.toLowerCase().contains(
      "enter no. of agri connections",
    );
    return TextField(
      controller: controller,
      keyboardType: isNumberField ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumberField
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],

      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  TableRow _buildTableRow(
    String field,
    String param,
    Widget editWidget, {
    bool isHeader = false,
    bool required = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey[200] : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: field,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
                fontSize: 10,
              ),
              children: required
                  ? [
                      const TextSpan(
                        text: " *",
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            param,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: Colors.black54,
              fontSize: 13,
              fontStyle: isHeader ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: editWidget),
      ],
    );
  }

  Widget _buildImageGrid() {
    List<File> images = [
      widget.structurePhoto,
      widget.embossPhoto,
      widget.namePlatePhoto,
      if (widget.meterPhoto != null) widget.meterPhoto!,
    ];
    List<String> titles = [
      "Structure",
      "Emboss",
      "Name Plate",
      if (widget.meterPhoto != null) "Meter",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Captured Images",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titles[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify & Correct Data",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Review the extracted data and make corrections if needed",
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade300),
                verticalInside: BorderSide(color: Colors.grey.shade300),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(
                  "Field",
                  "Parameters as per the photograph",
                  const Text(
                    "Edit (if incorrect or not found) Value",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  isHeader: true,
                ),
                _buildTableRow(
                  "Structure Code",
                  widget.structure.structurecode,
                  _buildTextField(
                    _structureCodeController,
                    "Enter Structure Code",
                  ),
                ),
                _buildTableRow(
                  "Structure Name",
                  widget.structure.structname,
                  _buildTextField(
                    _structureNameController,
                    "Enter Structure Name",
                  ),
                ),
                _buildTableRow(
                  "Serial No",
                  _displayParam(widget.ocrData?.serialNo),
                  _buildTextField(_serialNoController, "Enter Serial No"),
                  required: true,
                ),
                _buildTableRow(
                  "Amperes Hv",
                  _displayParam(widget.ocrData?.amperesHv),
                  _buildTextField(_amperesHvController, "Enter Amperes Hv"),
                  required: true,
                ),
                _buildTableRow(
                  "Amperes Lv",
                  _displayParam(widget.ocrData?.amperesLv),
                  _buildTextField(_amperesLvController, "Enter Amperes Lv"),
                  required: true,
                ),
                _buildTableRow(
                  "Capacity Kva",
                  _displayParam(widget.ocrData?.capacity),
                  _buildTextField(_capacityController, "Enter Capacity Kva"),
                  required: true,
                ),
                _buildTableRow(
                  "Transformer Type",
                  _displayParam(widget.ocrData?.transformeryType),
                  _buildTextField(
                    _transformerTypeController,
                    "Enter Transformer Type",
                  ),
                  required: true,
                ),
                _buildTableRow(
                  "Manufacturer",
                  _displayParam(widget.ocrData?.manufacturer),
                  _buildTextField(
                    _manufacturerController,
                    "Enter Manufacturer",
                  ),
                  required: true,
                ),
                _buildTableRow(
                  "Month And Year Of Manufacture",
                  _displayParam(widget.ocrData?.manufactureDate),
                  _buildTextField(
                    _manufactureDateController,
                    "Enter Month And Year Of Manufacture",
                  ),
                  required: true,
                ),
                _buildTableRow(
                  "Order Number",
                  _displayParam(widget.ocrData?.orderNo),
                  _buildTextField(_orderNoController, "Enter Order Number"),
                  required: true,
                ),
                _buildTableRow(
                  "No. of Agricultural Connections",
                  "-",
                  _buildTextField(
                    _agriConnectionsController,
                    "Enter no. of Agri Connections",
                  ),
                  required: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: "📍 Location Capture ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "*",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Capture the Geo location of this DTR (Required)",
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.location_on, color: Colors.white),
              label: Text(
                _isGettingLocation ? "Capturing..." : "Capture Location",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        if (_currentPosition != null) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.dtrs_survey',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "LATITUDE:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            _currentPosition!.latitude.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "LONGITUDE:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            _currentPosition!.longitude.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        title: const Text("Review & Verify Survey Data"),
        backgroundColor: AppColors.backgroundGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildInfoCard(
            widget.structure,
            selectedFeeder: widget.selectedFeeder,
            selectedSubstation: widget.selectedSubstation,
          ),
          const SizedBox(height: 16),
          _buildImageGrid(),
          const SizedBox(height: 16),

          _buildMeterSection(),
          const SizedBox(height: 16),
          _buildDataTable(),
          const SizedBox(height: 16),
          _buildLocationSection(),

          AnimatedBuilder(
            animation: _formListenable,
            builder: (context, _) {
              if (!_isFormValid) {
                return const SizedBox(height: 40);
              }
              return Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showPreviewDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Preview & Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeterSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Text(
              "METER DEVICE AVAILABLE:   ",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.isMeterAvailable
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(
                    widget.isMeterAvailable ? Icons.check_circle : Icons.cancel,
                    color: widget.isMeterAvailable ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isMeterAvailable ? 'YES' : 'NO',
                    style: TextStyle(
                      color: widget.isMeterAvailable
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewDialog extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onSubmit;

  const _PreviewDialog({required this.data, required this.onSubmit});

  @override
  State<_PreviewDialog> createState() => _PreviewDialogState();
}

class _PreviewDialogState extends State<_PreviewDialog> {
  bool _isDeclared = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Confirm Survey Submission",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Survey Data Preview",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: widget.data.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  e.value,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checkbox
                  GestureDetector(
                    onTap: () => setState(() => _isDeclared = !_isDeclared),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isDeclared
                            ? Colors.green.shade50
                            : Colors.transparent,
                        border: Border.all(
                          color: _isDeclared
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _isDeclared,
                              onChanged: (val) =>
                                  setState(() => _isDeclared = val!),
                              activeColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "I declare that I have personally verified the data, and I confirm that the information provided is accurate and correct.",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.grey.shade50,
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_isDeclared) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onSubmit();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Proceed & Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
