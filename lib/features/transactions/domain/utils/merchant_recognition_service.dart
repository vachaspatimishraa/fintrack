class MerchantRecognitionService {
  static String? recognizeMerchant(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('amazon')) return 'Amazon';
    if (lower.contains('swiggy')) return 'Swiggy';
    if (lower.contains('zomato')) return 'Zomato';
    if (lower.contains('uber')) return 'Uber';
    if (lower.contains('starbucks')) return 'Starbucks';
    if (lower.contains('netflix')) return 'Netflix';
    return null;
  }
}
