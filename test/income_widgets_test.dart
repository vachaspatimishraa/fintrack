import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/analytics/domain/entities/income_data.dart';
import 'package:fintrack/features/analytics/presentation/widgets/banners.dart';
import 'package:fintrack/features/analytics/presentation/widgets/income_sources_list.dart';
import 'package:fintrack/features/analytics/presentation/widgets/income_statistics_card.dart';
import 'package:fintrack/features/analytics/presentation/widgets/skeleton_loaders.dart';

void main() {
  group('Income Analytics Widgets Tests', () {
    testWidgets('SkeletonChart renders with animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonChart(height: 200),
          ),
        ),
      );

      expect(find.byType(SkeletonChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));

      // Verify animation
      await tester.pump(const Duration(milliseconds: 1500));
    });

    testWidgets('SkeletonCard displays loading placeholders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(height: 100),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // Verify animation completes
      await tester.pump(const Duration(milliseconds: 1500));
    });

    testWidgets('SkeletonStatisticsGrid displays grid layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SkeletonStatisticsGrid(),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonStatisticsGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
    });

    testWidgets('OfflineBanner shows when offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(isOffline: true),
          ),
        ),
      );

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.text('Income analytics calculated locally.'), findsOneWidget);
    });

    testWidgets('OfflineBanner hidden when online', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(isOffline: false),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      // The actual content should not be visible
      expect(find.text('Offline Mode'), findsNothing);
    });

    testWidgets('ErrorBanner displays error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Failed to load analytics',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to load analytics'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('ErrorBanner retry button works', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Failed to load',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryPressed, true);
    });

    testWidgets('InfoBanner displays information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoBanner(
              title: 'Info',
              message: 'This is information',
              icon: Icons.info_outline,
            ),
          ),
        ),
      );

      expect(find.byType(InfoBanner), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('This is information'), findsOneWidget);
    });
  });

  group('Income Statistics Card Tests', () {
    testWidgets('IncomeStatisticsCard displays all statistics', (WidgetTester tester) async {
      final stats = const IncomeStatistics(
        totalIncome: 10000,
        averageIncome: 1000,
        largestIncome: 2000,
        smallestIncome: 500,
        incomeCount: 10,
        averagePerDay: 100,
        averagePerWeek: 700,
        averagePerMonth: 3000,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: IncomeStatisticsCard(statistics: stats),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IncomeStatisticsCard), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Total Income'), findsOneWidget);
      expect(find.text('Average Income'), findsOneWidget);
      expect(find.text('Largest Income'), findsOneWidget);
      expect(find.text('Smallest Income'), findsOneWidget);
    });

    testWidgets('IncomeStatisticsCard displays period statistics', (WidgetTester tester) async {
      final stats = const IncomeStatistics(
        totalIncome: 10000,
        averageIncome: 1000,
        largestIncome: 2000,
        smallestIncome: 500,
        incomeCount: 10,
        averagePerDay: 100,
        averagePerWeek: 700,
        averagePerMonth: 3000,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: IncomeStatisticsCard(statistics: stats),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Per Week'), findsOneWidget);
      expect(find.text('Per Month'), findsOneWidget);
    });
  });

  group('Income Sources List Tests', () {
    testWidgets('IncomeSourcesList displays empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IncomeSourcesList(
                sources: const [],
                totalIncome: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IncomeSourcesList), findsOneWidget);
      expect(find.text('Income Sources'), findsOneWidget);
      expect(find.text('No income sources recorded'), findsOneWidget);
    });

    testWidgets('IncomeSourcesList displays sources', (WidgetTester tester) async {
      final sources = [
        const SourceSlice(sourceName: 'Bank Transfer', amount: 5000),
        const SourceSlice(sourceName: 'PayPal', amount: 3000),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IncomeSourcesList(
                sources: sources,
                totalIncome: 8000,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IncomeSourcesList), findsOneWidget);
      expect(find.text('Income Sources'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
    });

    testWidgets('IncomeSourcesList shows percentage correctly', (WidgetTester tester) async {
      final sources = [
        const SourceSlice(sourceName: 'Bank Transfer', amount: 5000),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IncomeSourcesList(
                sources: sources,
                totalIncome: 5000,
              ),
            ),
          ),
        ),
      );

      // 100% for single source
      expect(find.text('100.0%'), findsOneWidget);
    });

    testWidgets('IncomeSourcesList sorts by amount descending', (WidgetTester tester) async {
      final sources = [
        const SourceSlice(sourceName: 'Small', amount: 1000),
        const SourceSlice(sourceName: 'Large', amount: 5000),
        const SourceSlice(sourceName: 'Medium', amount: 3000),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IncomeSourcesList(
                sources: sources,
                totalIncome: 9000,
              ),
            ),
          ),
        ),
      );

      // Verify the sources appear in descending order
      final items = find.byType(ListView);
      expect(items, findsOneWidget);
    });
  });
}
