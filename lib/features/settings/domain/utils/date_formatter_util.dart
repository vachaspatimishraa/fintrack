import 'package:intl/intl.dart';
import '../entities/settings_entity.dart';

class DateFormatterUtil {
  static String format(DateTime date, SettingsEntity settings) {
    // Current Version: Basic selection from settings or auto-locale
    // Future: Use settings.dateFormat
    final formatter = DateFormat.yMMMMd(settings.language);
    return formatter.format(date);
  }

  static String formatShort(DateTime date, SettingsEntity settings) {
    final formatter = DateFormat.yMd(settings.language);
    return formatter.format(date);
  }

  static String formatMonthYear(DateTime date, SettingsEntity settings) {
    final formatter = DateFormat.yMMMM(settings.language);
    return formatter.format(date);
  }

  static String formatTime(DateTime date, SettingsEntity settings) {
    final formatter = DateFormat.jm(settings.language);
    return formatter.format(date);
  }
}
