import 'merchant_recognition_service.dart';

class SmartSuggestionEngine {
  static String suggestCategory(String title) {
    final merchant = MerchantRecognitionService.recognizeMerchant(title);
    if (merchant == null) return 'Other';

    switch (merchant) {
      case 'Amazon':
        return 'Shopping';
      case 'Swiggy':
      case 'Zomato':
      case 'Starbucks':
        return 'Food';
      case 'Uber':
        return 'Travel';
      case 'Netflix':
        return 'Subscription';
      default:
        return 'Other';
    }
  }

  static List<String> suggestTags(String title) {
    final lowerTitle = title.toLowerCase();
    final suggested = <String>[];
    if (lowerTitle.contains('uber')) suggested.add('uber');
    if (lowerTitle.contains('amazon')) suggested.add('amazon');
    if (lowerTitle.contains('swiggy') || lowerTitle.contains('zomato')) suggested.add('food-delivery');
    if (lowerTitle.contains('netflix') || lowerTitle.contains('spotify')) suggested.add('entertainment');
    return suggested;
  }
}
