import 'package:dtrs_survey/features/dashboard/data/models/structure_model.dart';
import 'package:flutter/material.dart';

Widget buildInfoCard(
  Structure structure, {
  String? selectedSubstation,
  String? selectedFeeder,
}) {
  return Wrap(
    spacing: 6,
    children: [
      _rowPair(
        _infoBox("Circle", '${structure.circode} - ${structure.cirname}'),
        _infoBox("Section", '${structure.uksec} - ${structure.secname}'),
      ),
      _rowPair(
        _infoBox("Division", '${structure.divcd} - ${structure.divname}'),
        _infoBox(
          "Sub Division",
          '${structure.subdivcd} - ${structure.subdivname}',
        ),
      ),
      _rowPair(
        selectedSubstation != null
            ? _infoBox("SUBSTATION", selectedSubstation)
            : const SizedBox(),
        selectedFeeder != null
            ? _infoBox("FEEDER", selectedFeeder)
            : const SizedBox(),
      ),
      _rowPair(
        _infoBox("Structure Name", structure.structname),
        _infoBox("Structure Code", structure.structurecode),
      ),
      _rowPair(
        _infoBox("AE Mobile No", structure.aePhno),
       const SizedBox(),
      ),
    ],
  );
}

Widget _rowPair(Widget left, Widget right) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 6),
          Expanded(child: right),
        ],
      ),
    ),
  );
}

Widget _infoBox(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.green.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          softWrap: true,
        ),
      ],
    ),
  );
}
