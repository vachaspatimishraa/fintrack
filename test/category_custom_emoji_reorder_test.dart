import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/database/isar/collections/category_model.dart';
import 'package:fintrack/core/utils/category_emoji_helper.dart';
import 'package:fintrack/features/transactions/presentation/widgets/category_picker_bottom_sheet.dart';
import 'package:fintrack/features/transactions/providers/transaction_provider.dart';

void main() {
  group('Category Emoji & Helper Tests', () {
    test('Resolves exact emojis for image categories', () {
      expect(CategoryEmojiHelper.getEmoji(null, 'Transport'), equals('🚕'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Apparel'), equals('🧥'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Education'), equals('📙'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Snacks'), equals('🍟'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Food'), equals('🌯'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Petrol'), equals('⛽'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Dhobi'), equals('👚'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Bike'), equals('🚲'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Movie'), equals('🎥'));
      expect(CategoryEmojiHelper.getEmoji(null, 'Drink'), equals('🥤'));
    });

    test('isEmoji identifies emoji characters', () {
      expect(CategoryEmojiHelper.isEmoji('🚕'), isTrue);
      expect(CategoryEmojiHelper.isEmoji('🥤'), isTrue);
      expect(CategoryEmojiHelper.isEmoji('🌯'), isTrue);
      expect(CategoryEmojiHelper.isEmoji('Transport'), isFalse);
      expect(CategoryEmojiHelper.isEmoji(''), isFalse);
    });

    test('Custom emoji is preserved when passed as icon', () {
      expect(CategoryEmojiHelper.getEmoji('🍺', 'Drink'), equals('🍺'));
      expect(CategoryEmojiHelper.getEmoji('🥤', 'My Custom'), equals('🥤'));
    });

    test('CategoryModel serializes and deserializes order correctly', () {
      final model = CategoryModel()
        ..uuid = 'test-uuid'
        ..userId = 'user-1'
        ..name = 'Drink'
        ..type = 'expense'
        ..icon = '🥤'
        ..color = '#00BCD4'
        ..order = 3
        ..isDefault = false
        ..isDeleted = false
        ..createdAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 2)
        ..syncVersion = 1;

      final json = model.toJson();
      expect(json['order'], equals(3));
      expect(json['icon'], equals('🥤'));
      expect(json['name'], equals('Drink'));

      final restored = CategoryModel.fromJson(json);
      expect(restored.uuid, equals('test-uuid'));
      expect(restored.order, equals(3));
      expect(restored.icon, equals('🥤'));
      expect(restored.name, equals('Drink'));
    });
  });

  group('CategoryPickerBottomSheet Widget Tests', () {
    testWidgets('Renders categories with emojis in grid and allows selection', (tester) async {
      String? selected;

      final testCategories = [
        CategoryModel()
          ..uuid = '1'
          ..name = 'Transport'
          ..type = 'expense'
          ..icon = '🚕'
          ..order = 0,
        CategoryModel()
          ..uuid = '2'
          ..name = 'Apparel'
          ..type = 'expense'
          ..icon = '🧥'
          ..order = 1,
        CategoryModel()
          ..uuid = '3'
          ..name = 'Education'
          ..type = 'expense'
          ..icon = '📙'
          ..order = 2,
        CategoryModel()
          ..uuid = '4'
          ..name = 'Drink'
          ..type = 'expense'
          ..icon = '🥤'
          ..order = 3,
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value(testCategories),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => CategoryPickerBottomSheet(
                          type: 'expense',
                          selectedCategory: 'Transport',
                          onCategorySelected: (val) => selected = val,
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Check header and category items
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Apparel'), findsOneWidget);
      expect(find.text('Education'), findsOneWidget);
      expect(find.text('Drink'), findsOneWidget);

      // Tap on 'Drink'
      await tester.tap(find.text('Drink'));
      await tester.pumpAndSettle();

      expect(selected, equals('Drink'));
    });
  });
}
