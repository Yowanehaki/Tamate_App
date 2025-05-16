import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
  }
}