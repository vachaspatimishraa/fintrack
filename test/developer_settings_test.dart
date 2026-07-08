import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/data/mappers/settings_mapper.dart';

void main() {
  group('Developer Settings', () {
    test('SettingsMapper should handle feature flags correctly', () {
      final entity = SettingsEntity(
        developerModeEnabled: true,
        featureFlags: {'Beta Feature': true, 'Old Feature': false},
      );

      final model = SettingsMapper.toModel(entity);

      expect(model.developerModeEnabled, isTrue);
      expect(model.enabledFeatureFlags, contains('Beta Feature'));
      expect(model.enabledFeatureFlags, isNot(contains('Old Feature')));

      final fromModel = SettingsMapper.toEntity(model);
      expect(fromModel.featureFlags['Beta Feature'], isTrue);
      expect(fromModel.featureFlags['Old Feature'], isNull); // Mapping logic only adds enabled flags
    });
  });
}
