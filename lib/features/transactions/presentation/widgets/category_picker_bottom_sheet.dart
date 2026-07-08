import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/isar/collections/category_model.dart';
import '../controllers/category_controller.dart';
import '../../providers/transaction_provider.dart';

class CategoryPickerBottomSheet extends ConsumerStatefulWidget {
  final String type; // income, expense
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryPickerBottomSheet({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  ConsumerState<CategoryPickerBottomSheet> createState() => _CategoryPickerBottomSheetState();
}

class _CategoryPickerBottomSheetState extends ConsumerState<CategoryPickerBottomSheet> {
  String _searchQuery = '';
  List<CategoryModel> _recentCategories = [];
  bool _isCreatingCustom = false;

  final _customNameController = TextEditingController();
  String _customIcon = 'star';
  String _customColor = '#E91E63';

  static const List<Map<String, dynamic>> _iconOptions = [
    {'name': 'star', 'icon': Icons.star},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'sports_esports', 'icon': Icons.sports_esports},
    {'name': 'payments', 'icon': Icons.payments},
    {'name': 'credit_card', 'icon': Icons.credit_card},
  ];

  static const List<String> _colorOptions = [
    '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
    '#2196F3', '#00BCD4', '#009688', '#4CAF50', '#8BC34A',
    '#CDDC39', '#FFEB3B', '#FFC107', '#FF9800', '#FF5722',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final list = await ref.read(categoryControllerProvider).getRecentCategories(5);
    setState(() {
      _recentCategories = list.where((c) => c.type == widget.type).toList();
    });
  }

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  void _saveCustomCategory() async {
    final name = _customNameController.text.trim();
    if (name.isEmpty) return;

    final cat = CategoryModel()
      ..uuid = ''
      ..userId = ''
      ..name = name
      ..type = widget.type
      ..icon = _customIcon
      ..color = _customColor
      ..isDefault = false
      ..isDeleted = false
      ..isSynced = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..syncVersion = 1;

    await ref.read(categoryControllerProvider).saveCategory(cat);
    _customNameController.clear();
    setState(() {
      _isCreatingCustom = false;
    });
    _loadRecents();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        if (_isCreatingCustom) {
          return _buildCreateCustomView();
        }

        return categoriesAsync.when(
          data: (categories) {
            // Seed defaults first if empty
            if (categories.isEmpty) {
              ref.read(categoryRepositoryProvider).getCategories();
            }

            final filtered = categories
                .where((c) => c.type == widget.type)
                .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Category',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCreatingCustom = true;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Custom'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (_recentCategories.isNotEmpty && _searchQuery.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'Recent Categories',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _recentCategories.length,
                            itemBuilder: (context, index) {
                              final cat = _recentCategories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: ChoiceChip(
                                  label: Text(cat.name),
                                  selected: widget.selectedCategory == cat.name,
                                  onSelected: (selected) {
                                    if (selected) {
                                      widget.onCategorySelected(cat.name);
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'All Categories',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text('No categories match search.')),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final cat = filtered[index];
                            final isSelected = widget.selectedCategory == cat.name;
                            final color = Color(int.parse(cat.color.replaceAll('#', '0xFF')));

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                child: Icon(
                                  _getIconData(cat.icon),
                                  color: color,
                                ),
                              ),
                              title: Text(
                                cat.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                              onTap: () {
                                widget.onCategorySelected(cat.name);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading categories: $err')),
        );
      },
    );
  }

  Widget _buildCreateCustomView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isCreatingCustom = false;
                  });
                },
              ),
              Text(
                'Create Custom Category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customNameController,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Subscriptions',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final item = _iconOptions[index];
                final isSelected = _customIcon == item['name'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Icon(item['icon'] as IconData, size: 20),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _customIcon = item['name'] as String;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colorOptions.length,
              itemBuilder: (context, index) {
                final hex = _colorOptions[index];
                final color = Color(int.parse(hex.replaceAll('#', '0xFF')));
                final isSelected = _customColor == hex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _customColor = hex;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border(bottom: BorderSide(color: Colors.black, width: 3)) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _saveCustomCategory,
            child: const Text('Save Category'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'restaurant': return Icons.restaurant;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'directions_car': return Icons.directions_car;
      case 'flight': return Icons.flight;
      case 'wallet': return Icons.wallet;
      case 'school': return Icons.school;
      case 'medical_services': return Icons.medical_services;
      case 'sports_esports': return Icons.sports_esports;
      case 'payments': return Icons.payments;
      case 'credit_card': return Icons.credit_card;
      case 'redeem': return Icons.redeem;
      case 'trending_up': return Icons.trending_up;
      case 'local_offer': return Icons.local_offer;
      case 'work_outline': return Icons.work_outline;
      case 'store': return Icons.store;
      case 'show_chart': return Icons.show_chart;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'monetization_on': return Icons.monetization_on;
      case 'local_gas_station': return Icons.local_gas_station;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'receipt': return Icons.receipt;
      case 'home': return Icons.home;
      default: return Icons.category;
    }
  }
}
