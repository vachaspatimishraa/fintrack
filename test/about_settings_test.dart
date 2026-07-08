import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/settings/domain/entities/app_information_entity.dart';

void main() {
  group('About Settings', () {
    test('AppInformationEntity should store fields correctly', () {
      final date = DateTime.now();
      final entity = AppInformationEntity(
        appName: 'FinTrack',
        packageName: 'com.fintrack.app',
        version: '1.0.0',
        buildNumber: '100',
        buildDate: date,
      );

      expect(entity.appName, 'FinTrack');
      expect(entity.version, '1.0.0');
      expect(entity.releaseChannel, 'Stable');
      expect(entity.buildDate, date);
    });
  });
}
