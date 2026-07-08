import 'package:flutter/material.dart';
import '../entities/settings_entity.dart';

class QuietHoursManager {
  static bool isQuietTime(SettingsEntity settings) {
    if (!settings.quietHoursEnabled) return false;

    final now = TimeOfDay.fromDateTime(DateTime.now());
    final start = _parseTime(settings.quietHoursStart);
    final end = _parseTime(settings.quietHoursEnd);

    if (start.hour < end.hour) {
      // Normal range (e.g., 22:00 to 07:00 next day NOT possible here)
      // Actually 22:00 to 23:59
      return _isBetween(now, start, end);
    } else {
      // Overnight range (e.g., 22:00 to 07:00)
      return _isBetween(now, start, const TimeOfDay(hour: 23, minute: 59)) ||
             _isBetween(now, const TimeOfDay(hour: 0, minute: 0), end);
    }
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static bool _isBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final nowMin = time.hour * 60 + time.minute;
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    return nowMin >= startMin && nowMin <= endMin;
  }
}
