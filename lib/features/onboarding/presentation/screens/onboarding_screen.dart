import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/translations.dart';
import '../../../accounts/presentation/screens/create_account_screen.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'What is a Wallet?',
      subtitle: 'A Wallet helps you organize your money for a specific purpose.',
      description: 'You can create as many wallets as you need.',
      examples: [
        'Trips',
        'Monthly Budgets',
        'Personal Spending',
        'Savings',
        'Business',
        'Education',
      ],
      features: [
        OnboardingFeature(
          icon: Icons.arrow_downward,
          color: Colors.green,
          title: 'Track every income',
          subtitle: 'Record all your cash in',
        ),
        OnboardingFeature(
          icon: Icons.arrow_upward,
          color: Colors.red,
          title: 'Track every expense',
          subtitle: 'Record all your cash out',
        ),
        OnboardingFeature(
          icon: Icons.picture_as_pdf,
          color: Colors.blue,
          title: 'Export beautiful PDF reports',
          subtitle: 'See summary and share PDF',
        ),
      ],
      icon: Icons.account_balance_wallet,
    ),
    OnboardingData(
      title: 'Nainital Trip',
      subtitle: 'Imagine you\'re going to Nainital with your friends.',
      description: 'Your parents give you ₹6000.',
      walletName: 'Nainital Trip',
      cashIn: {'Parents': 6000},
      cashOut: ['Hotel', 'Food', 'Cab', 'Shopping', 'Tickets'],
      note: 'At the end of the trip, you\'ll know exactly where every rupee was spent and you can export a PDF report to share.',
      icon: Icons.landscape,
    ),
    OnboardingData(
      title: 'Monthly Budget',
      subtitle: 'Create a wallet called "July Expenses".',
      description: 'Manage your income and expenses for the month.',
      cashIn: {'Salary': 50000, 'Freelance': 15000, 'Bonus': 5000},
      cashOut: ['Rent', 'School Fees', 'Grocery', 'Electricity', 'Fuel', 'Shopping'],
      note: 'At the end of the month, FinTrack generates a complete summary of income, expenses and remaining balance.',
      icon: Icons.calendar_month,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    // Navigate to Create Wallet (which is renamed CreateAccountScreen)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/logo.png', height: 32),
                      const SizedBox(width: 8),
                      Text(
                        'FinTrack',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _complete,
                    child: Text(
                      context.translate('skip'),
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton.extended(
                    onPressed: _onNext,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    label: Text(_currentPage == _pages.length - 1
                        ? 'Create My First Wallet'
                        : 'Next'),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(data.icon, size: 100, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (data.description != null)
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (data.examples != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.examples!
                  .map((e) => Chip(
                        label: Text(e),
                        backgroundColor: theme.colorScheme.surface,
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ))
                  .toList(),
            ),
          if (data.features != null)
            ...data.features!.map((f) => Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: f.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(f.icon, color: f.color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              f.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          if (data.walletName != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Create a wallet named: '),
                    Text(
                      data.walletName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (data.cashIn != null)
              _buildTransactionList(
                  context, 'Cash In', data.cashIn!, Colors.green, Icons.arrow_downward),
            const SizedBox(height: 16),
            if (data.cashOut != null)
              _buildCashOutList(
                  context, 'Cash Out', data.cashOut!, Colors.red, Icons.arrow_upward),
          ],
          if (data.note != null) ...[
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.note!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, String title,
      Map<String, int> items, Color color, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.entries.map((e) => ListTile(
              dense: true,
              leading: const Icon(Icons.person_outline),
              title: Text(e.key),
              trailing: Text(
                '₹${e.value}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            )),
      ],
    );
  }

  Widget _buildCashOutList(BuildContext context, String title,
      List<String> items, Color color, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((e) => ListTile(
              dense: true,
              leading: Icon(_getIconForCashOut(e)),
              title: Text(e),
              trailing: const Icon(Icons.chevron_right, size: 16),
            )),
      ],
    );
  }

  IconData _getIconForCashOut(String name) {
    switch (name.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'food':
        return Icons.restaurant;
      case 'cab':
      case 'fuel':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'tickets':
        return Icons.confirmation_number;
      case 'rent':
        return Icons.home;
      case 'school fees':
        return Icons.school;
      case 'grocery':
        return Icons.shopping_cart;
      case 'electricity':
        return Icons.bolt;
      default:
        return Icons.category;
    }
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String? description;
  final List<String>? examples;
  final List<OnboardingFeature>? features;
  final String? walletName;
  final Map<String, int>? cashIn;
  final List<String>? cashOut;
  final String? note;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    this.description,
    this.examples,
    this.features,
    this.walletName,
    this.cashIn,
    this.cashOut,
    this.note,
    required this.icon,
  });
}

class OnboardingFeature {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  OnboardingFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}
