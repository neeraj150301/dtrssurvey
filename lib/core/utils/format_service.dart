import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}