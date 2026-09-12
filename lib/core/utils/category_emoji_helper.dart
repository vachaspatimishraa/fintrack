class CategoryEmojiHelper {
  const CategoryEmojiHelper._();

  static const String defaultEmoji = '🏷️';

  static final Map<String, String> _nameToEmoji = {
    'transport': '🚕',
    'transportation': '🚕',
    'apparel': '🧥',
    'education': '📙',
    'snacks': '🍟',
    'food': '🌯',
    'food & drinks': '🌯',
    'petrol': '⛽',
    'fuel': '⛽',
    'dhobi': '👚',
    'laundry': '👚',
    'bike': '🚲',
    'movie': '🎥',
    'entertainment': '🎥',
    'drink': '🥤',
    'drinks': '🥤',
    'beverage': '🥤',
    'beverages': '🥤',
    'shopping': '🛍️',
    'groceries': '🛒',
    'grocery': '🛒',
    'bills': '🧾',
    'utilities': '🧾',
    'medical': '💊',
    'health': '💊',
    'medicine': '💊',
    'rent': '🏠',
    'housing': '🏠',
    'subscription': '📱',
    'subscriptions': '📱',
    'travel': '✈️',
    'flight': '✈️',
    'gaming': '🎮',
    'salary': '💰',
    'investment': '📈',
    'business': '🏢',
    'freelance': '💻',
    'bonus': '🎉',
    'gift': '🎁',
    'cashback': '💸',
    'interest': '📈',
    'other income': '💵',
    'other': '📦',
  };

  static final Map<String, String> _iconToEmoji = {
    'restaurant': '🌯',
    'flight': '✈️',
    'local_gas_station': '⛽',
    'shopping_bag': '🛍️',
    'shopping_cart': '🛒',
    'receipt': '🧾',
    'medical_services': '💊',
    'subscriptions': '📱',
    'home': '🏠',
    'school': '📙',
    'sports_esports': '🎮',
    'payments': '💰',
    'redeem': '🎁',
    'trending_up': '📈',
    'local_offer': '🏷️',
    'work_outline': '💼',
    'store': '🏢',
    'show_chart': '📊',
    'card_giftcard': '🎁',
    'monetization_on': '💵',
    'directions_car': '🚕',
    'movie': '🎥',
  };

  /// Returns true if the string consists of or starts with emoji characters
  static bool isEmoji(String text) {
    if (text.isEmpty) return false;
    final runes = text.runes;
    for (final rune in runes) {
      if (rune > 0x1F000 ||
          (rune >= 0x2000 && rune <= 0x3299) ||
          rune == 0x23 ||
          rune == 0x2A ||
          (rune >= 0x30 && rune <= 0x39 && text.length > 1)) {
        return true;
      }
    }
    return false;
  }

  /// Resolves the best emoji for a category, checking the icon field first, then category name, then legacy icon mapping.
  static String getEmoji(String? icon, [String? categoryName]) {
    if (icon != null && icon.isNotEmpty && isEmoji(icon)) {
      return icon;
    }

    if (categoryName != null && categoryName.trim().isNotEmpty) {
      final key = categoryName.trim().toLowerCase();
      if (_nameToEmoji.containsKey(key)) {
        return _nameToEmoji[key]!;
      }
    }

    if (icon != null && icon.isNotEmpty) {
      final key = icon.trim().toLowerCase();
      if (_iconToEmoji.containsKey(key)) {
        return _iconToEmoji[key]!;
      }
    }

    return defaultEmoji;
  }

  /// Curated list of categorized emojis for the emoji picker
  static const Map<String, List<String>> emojiCategories = {
    'Food & Drinks': [
      '🥤', '🍺', '☕', '🍔', '🍟', '🍕', '🌯', '🌮', '🍜', '🍣',
      '🍩', '🍰', '🍦', '🍿', '🍷', '🍸', '🍹', '🧃', '🧉', '🍎',
      '🍉', '🍓', '🍌', '🍳', '🥞', '🥗', '🍲', '🍱', '🥪', '🍪',
    ],
    'Transport & Travel': [
      '🚕', '🚗', '🚙', '🚌', '🚲', '🛵', '🏍️', '⛽', '✈️', '🚆',
      '🚇', '🚢', '🚀', '🎫', '🗺️', '🧳', '🏖️', '🏎️', '🚁', '🛴',
    ],
    'Shopping & Apparel': [
      '🧥', '👚', '👕', '👖', '👗', '👟', '👠', '🧢', '👜', '🛍️',
      '🛒', '💍', '💎', '🕶️', '💄', '📦', '🏷️', '👒', '🎒', '👔',
    ],
    'Entertainment': [
      '🎥', '🎬', '🍿', '🎮', '🕹️', '🎵', '🎧', '🎸', '🎤', '🎳',
      '🎯', '🎲', '🎟️', '🎪', '🎨', '⚽', '🏀', '🎾', '📺', '📻',
    ],
    'Home & Daily': [
      '🏠', '🏡', '🔑', '💡', '🛋️', '🧺', '🧹', '🧼', '🔧', '🔨',
      '🪴', '🚿', '🛏️', '⚡', '💧', '📶', '📱', '💻', '⏰', '🔋',
    ],
    'Health & Education': [
      '💊', '🩹', '💉', '🩺', '🏥', '📙', '📚', '🎓', '✏️', '📝',
      '🏋️', '🧘', '🚴', '🏃', '🦷', '👓', '📖', '🔬', '💈', '🧖',
    ],
    'Finance & Work': [
      '💰', '💵', '💳', '🪙', '🏦', '📈', '📉', '💸', '💼', '🏢',
      '📊', '🧾', '📁', '🤝', '🎉', '🎁', '🔐', '🏧', '⚖️', '📮',
    ],
  };

  /// Flattened list of popular emojis
  static List<String> get allEmojis {
    return emojiCategories.values.expand((list) => list).toList();
  }
}
