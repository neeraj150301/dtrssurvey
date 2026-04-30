import 'dart:convert';
import 'package:dtrs_survey/core/network/api_constants.dart';
import 'package:dtrs_survey/core/utils/format_service.dart';
import 'package:dtrs_survey/features/dashboard/data/models/structure_model.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/survey_page.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/widgets/full_screen_image.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dtrs_survey/features/survey/data/models/survey_details_model.dart';
import '../../../../core/constants/colors.dart';

class SurveyDetailsPage extends StatefulWidget {
  final Structure structure;
  const SurveyDetailsPage({super.key, required this.structure});

  @override
  State<SurveyDetailsPage> createState() => _SurveyDetailsPageState();
}

class _SurveyDetailsPageState extends State<SurveyDetailsPage> {
  bool _isLoading = true;
  SurveyDetailsResponse? _details;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.drtsStructureEndpoint}${widget.structure.structurecode}',
        ),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _details = SurveyDetailsResponse.fromJson(json);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              "Failed to load details. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  String _getFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '${ApiConstants.baseUrl}/$path';
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not open map.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        title: Text("Survey Details - ${widget.structure.structurecode}"),
        backgroundColor: AppColors.backgroundGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_details == null) return const Center(child: Text("No details found."));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_details!.isRetake == true && _details!.surveyType == 'retake')
          _buildRetakeSection(),
        if (_details!.isRetake == true && _details!.surveyType == 'retake')
          const SizedBox(height: 12),
        _buildCompletedSection(),
        const SizedBox(height: 16),
        buildInfoCard(
          Structure(
            structurecode: _details!.structurecode,
            structname: _details!.structname ?? "",
            aePhno: _details!.aePhno ?? "",
            surveyStatus: widget.structure.surveyedAt!,
            circode: _details!.circode,
            cirname: widget.structure.cirname,
            divcd: _details!.divcd.toString(),
            divname: widget.structure.divname,
            subdivcd: _details!.subdivcd.toString(),
            subdivname: widget.structure.subdivname,
            uksec: _details!.uksec.toString(),
            secname: widget.structure.secname,
            sscode: _details!.sscode,
            ssname: _details!.ssname ?? "",
            feedercode: _details!.feedercode ?? "",
            feedername: _details!.feedername ?? "",
            agency: _details!.agency ?? "",
          ),
          selectedFeeder: _details!.feedercode ?? "",
          selectedSubstation: _details!.sscode,
          agriculturalConnection: _details!.agriculturalConnections,
        ),
        const SizedBox(height: 16),
        _buildImagesSection(),
        const SizedBox(height: 16),
        _buildMeterSection(),
        const SizedBox(height: 16),
        _buildDataSection('Extracted Data (OCR)', _details!.extractedJson),

        const SizedBox(height: 16),
        _buildDataSection('Verified Data (Edited)', _details!.editedJson),

        const SizedBox(height: 16),
        _buildLocationSection(),

        const SizedBox(height: 16),
        if (_details!.isRetake == false && _details!.surveyType == 'original')
          _buildRetakeButton(),
      ],
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
                color: _details!.isMeterAvailable == true
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(
                    _details!.isMeterAvailable == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _details!.isMeterAvailable == true
                        ? Colors.green
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _details!.isMeterAvailable == true ? 'YES' : 'NO',
                    style: TextStyle(
                      color: _details!.isMeterAvailable == true
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

  Widget _buildImagesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Structure Photo",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildImageCard(_details!.dtrPhotoUrl),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "DTR emboss plate",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildImageCard(_details!.nameplateSerialPhotoUrl),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Structure Name plate",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildImageCard(_details!.nameplatePhotoUrl),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (_details!.meterDevicePhotoUrl != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Meter Device Photo",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildImageCard(_details!.meterDevicePhotoUrl),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String? urlPath) {
    String fullUrl = _getFullUrl(urlPath);
    return GestureDetector(
      onTap: fullUrl.isNotEmpty
        ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImagePage(imageUrl: fullUrl),
              ),
            );
          }
        : null,
        
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 120,
          width: double.infinity,
          color: Colors.black12,
          child: fullUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: fullUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                )
              : const Center(
                  child: Text(
                    "No Image",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                "Location Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildLocInfoCard(
            "LATITUDE:",
            _details!.latitude?.toString() ?? "N/A",
          ),
          _buildLocInfoCard(
            "LONGITUDE:",
            _details!.longitude?.toString() ?? "N/A",
          ),
          _buildLocInfoCard(
            "ACCURACY:",
            "${_details!.locationAccuracy?.toStringAsFixed(2) ?? "N/A"} meters",
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "GOOGLE MAPS:",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          if (_details!.latitude != null &&
                              _details!.longitude != null) {
                            _openGoogleMaps(
                              _details!.latitude!,
                              _details!.longitude!,
                            );
                          }
                        },
                        child: const Text(
                          "View on Map",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_details!.latitude != null && _details!.longitude != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      _details!.latitude!,
                      _details!.longitude!,
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
                            _details!.latitude!,
                            _details!.longitude!,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
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

  Widget _buildLocInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${e.key.replaceAll("_", " ").toUpperCase()}:",

                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.value.toString(),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRetakeButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SurveyPage(structure: widget.structure, isRetake: true),
          ),
        );
      },
      icon: const Icon(Icons.restart_alt, color: Colors.white, size: 18),
      label: const Text(
        'Retake Survey',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCompletedSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Survey Completed",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  "Submitted On: ${formatDate(_details!.createdAt)}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (_details!.isEdited == true)
                  Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Data was edited after extraction.",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetakeSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat, color: Colors.blueAccent, size: 18),
          SizedBox(width: 10),
          Text(
            "This is a Retake Survey",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
