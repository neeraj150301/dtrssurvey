import 'dart:convert';
import 'package:dtrs_survey/core/constants/colors.dart';
import 'package:dtrs_survey/core/utils/location_service.dart';
import 'package:dtrs_survey/features/dashboard/data/models/structure_model.dart';
import 'package:dtrs_survey/features/survey/data/models/ocr_extract_model.dart';
import 'package:dtrs_survey/features/survey/presentation/pages/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dtrs_survey/features/survey/presentation/pages/review_survey_screen.dart';

class SurveyPage extends StatelessWidget {
  final Structure structure;
  final bool isRetake;
  const SurveyPage({
    super.key,
    required this.structure,
    required this.isRetake,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SurveyBloc()
        ..add(
          LoadInitialData(
            structure.uksec,
            structure.sscode,
            structure.feedercode,
          ),
        ),
      child: _SurveyPageView(structure: structure, isRetake: isRetake),
    );
  }
}

class _SurveyPageView extends StatefulWidget {
  final Structure structure;
  final bool isRetake;
  const _SurveyPageView({required this.structure, required this.isRetake});

  @override
  State<_SurveyPageView> createState() => _SurveyPageViewState();
}

class _SurveyPageViewState extends State<_SurveyPageView> {
  File? structurePhoto;
  File? embossPhoto;
  File? namePlatePhoto;
  bool isMeterAvailable = false;
  File? meterPhoto;
  final ImagePicker _picker = ImagePicker();
  bool isOcrLoading = false;
  OcrData? ocrData;

  Future<void> _callOcrApi(File imageFile) async {
    setState(() => isOcrLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://tgrpdcl.com/ocr/ocr-extract"),
      );

      request.fields['dtr_code'] = widget.structure.structurecode;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      setState(() => isOcrLoading = false);

      if (data['success'] == true) {
        //  SUCCESS
        ocrData = OcrData.fromJson(data['extracted_json']);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text("OCR Successful ✔"),
              backgroundColor: Colors.green,
            ),
          );
      } else {
        //  FAIL -> FORCE RETAKE
        setState(() {
          namePlatePhoto = null;
        });

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? "OCR failed. Capture again."),
              backgroundColor: Colors.red,
              duration: const Duration(days: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
      setState(() {
        isOcrLoading = false;
        namePlatePhoto = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Something went wrong. Capture again."),
            backgroundColor: Colors.red,
            duration: const Duration(days: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    LocationService.startGlobalCapture(context);
  }

  @override
  void dispose() {
    LocationService.stopGlobalCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        title: Text("Survey Details"),
        backgroundColor: AppColors.backgroundGreen,
      ),
      body: BlocConsumer<SurveyBloc, SurveyState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              buildInfoCard(widget.structure),
              const SizedBox(height: 8),

              // Substation Dropdown
              Row(
                children: [
                  const Text(
                    "SUBSTATION ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "*",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownSearch<String>(
                selectedItem: state.substations
                    .where((s) => s.sscode == state.selectedSubstation)
                    .map((s) => "${s.ssname} - ${s.sscode}")
                    .firstOrNull,
                items: state.substations
                    .map((s) => "${s.ssname} - ${s.sscode}")
                    .toList(),

                popupProps: const PopupProps.menu(
                  showSearchBox: true, // enables search
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search Substations...",
                    ),
                  ),
                ),

                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: _inputDecoration().copyWith(
                    hintText: "Select Substation",
                  ),
                ),

                onChanged: (value) {
                  if (value != null) {
                    final code = value.split(" - ").last;
                    context.read<SurveyBloc>().add(SubstationChanged(code));
                  }
                },
              ),
              const SizedBox(height: 20),

              // Feeder Dropdown
              Row(
                children: [
                  const Text(
                    "FEEDER ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "*",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownSearch<String>(
                selectedItem: state.feeders
                    .where((f) => f.feedercode == state.selectedFeeder)
                    .map((f) => "${f.feedername} - ${f.feedercode}")
                    .firstOrNull,
                items: state.feeders
                    .map((f) => "${f.feedername} - ${f.feedercode}")
                    .toList(),

                popupProps: const PopupProps.menu(
                  showSearchBox: true, // enables search
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(hintText: "Search feeder..."),
                  ),
                ),

                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: _inputDecoration().copyWith(
                    hintText: "Select Feeder",
                  ),
                ),
                onChanged: state.isFeederLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          final code = value.split(" - ").last;
                          context.read<SurveyBloc>().add(FeederChanged(code));
                        }
                      },
              ),
              if (state.isFeederLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: CircularProgressIndicator()),
                ),

              const SizedBox(height: 20),

              _buildCameraButton("STRUCTURE PHOTO ", 1),
              const SizedBox(height: 16),
              _buildCameraButton("DTR EMBOSS PLATE ", 2),
              const SizedBox(height: 16),
              _buildCameraButton("DTR NAME PLATE ", 3),
              const SizedBox(height: 16),

              _buildMeterSection(state),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImage(int type) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        if (type == 1) {
          structurePhoto = file;
        } else if (type == 2) {
          embossPhoto = file;
        } else if (type == 3) {
          namePlatePhoto = file;
        } else if (type == 4) {
          meterPhoto = file;
        }
      });
      if (type == 3) {
        _callOcrApi(file);
      }
    }
  }

  Widget _buildCameraButton(String title, int type) {
    File? image;

    if (type == 1) image = structurePhoto;
    if (type == 2) image = embossPhoto;
    if (type == 3) image = namePlatePhoto;
    if (type == 4) image = meterPhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text("*", style: TextStyle(color: AppColors.errorRed)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isOcrLoading && type == 3 ? null : () => _pickImage(type),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: isOcrLoading && type == 3
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : image == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 24),
                      // SizedBox(height: 6),
                      Text("Tap to capture"),
                    ],
                  )
                : SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(image, fit: BoxFit.contain),
                    ),
                  ),
          ),
        ),
        if (image != null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              "Image captured ✔",
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildMeterSection(SurveyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              RichText(
                text: const TextSpan(
                  text: "IS METER DEVICE AVAILABLE? ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: "*",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // RADIO BUTTONS
              Row(
                children: [
                  _buildRadio(true, "Yes"),
                  const SizedBox(width: 20),
                  _buildRadio(false, "No"),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // SHOW ONLY IF YES
        if (isMeterAvailable) ...[_buildCameraButton('METER DEVICE PHOTO ', 4)],

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isFormValid(state)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewSurveyScreen(
                          structure: widget.structure,

                          selectedSubstation: state.selectedSubstation!,
                          selectedFeeder: state.selectedFeeder!,
                          selectedSubstationDisplay: state.substations
                              .where(
                                (s) => s.sscode == state.selectedSubstation,
                              )
                              .map((s) => "${s.ssname} - ${s.sscode}")
                              .firstOrNull,

                          selectedFeederDisplay: state.feeders
                              .where(
                                (f) => f.feedercode == state.selectedFeeder,
                              )
                              .map((f) => "${f.feedername} - ${f.feedercode}")
                              .firstOrNull,
                          structurePhoto: structurePhoto!,
                          embossPhoto: embossPhoto!,
                          namePlatePhoto: namePlatePhoto!,
                          isMeterAvailable: isMeterAvailable,
                          meterPhoto: meterPhoto,
                          ocrData: ocrData,
                          isRetake: widget.isRetake,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFormValid(state)
                  ? Colors.black87
                  : Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("NEXT", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRadio(bool value, String label) {
    final isSelected = isMeterAvailable == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          isMeterAvailable = value;

          if (!value) {
            meterPhoto = null; // reset photo if NO
          }
        });
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.withValues(alpha: 0.2) : null,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                RadioGroup<bool>(
                  groupValue: isMeterAvailable,
                  onChanged: (v) {
                    setState(() {
                      isMeterAvailable = v!;
                      if (!v) meterPhoto = null;
                    });
                  },
                  // activeColor: Colors.green,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isFormValid(SurveyState state) {
    if (state.selectedSubstation == null) return false;
    if (state.selectedFeeder == null) return false;
    if (structurePhoto == null) return false;
    if (embossPhoto == null) return false;
    if (namePlatePhoto == null) return false;
    if (isMeterAvailable && meterPhoto == null) return false;
    return true;
  }
}
