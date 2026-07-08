import '../entities/app_information_entity.dart';

abstract class AboutRepository {
  Future<AppInformationEntity> loadAppInformation();
  Future<String> loadPrivacyPolicy();
  Future<String> loadTermsOfService();
  Future<List<Map<String, String>>> loadReleaseNotes();
}
