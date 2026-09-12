import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/database/isar/collections/category_model.dart';
import 'package:fintrack/core/utils/category_emoji_helper.dart';
import 'package:fintrack/features/transactions/presentation/controllers/category_controller.dart';
import 'package:fintrack/features/transactions/providers/transaction_provider.dart';

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
  bool _isEditMode = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      data: (allCategories) {
        // Seed defaults if empty
        if (allCategories.isEmpty) {
          ref.read(categoryRepositoryProvider).getCategories();
        }

        final filtered = allCategories
            .where((c) => c.type == widget.type)
            .toList();

        // Sort by order ascending
        filtered.sort((a, b) => a.order.compareTo(b.order));

        if (_isEditMode) {
          return _buildManageCategoriesView(filtered);
        }

        return _buildGridPickerView(filtered);
      },
      loading: () => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF202126),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white70)),
      ),
      error: (err, _) => Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF202126),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: Text('Error loading categories: $err', style: const TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }

  /// The primary 3-column Grid View matching the user's screenshot
  Widget _buildGridPickerView(List<CategoryModel> categories) {
    final displayCategories = _searchQuery.isEmpty
        ? categories
        : categories
            .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF212226),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar
            _buildHeader(
              title: 'Category',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFFB0B3B8), size: 22),
                    tooltip: 'Edit Categories',
                    onPressed: () {
                      setState(() {
                        _isEditMode = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFB0B3B8), size: 22),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Optional search bar if list has many items
            if (categories.length > 12)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: const TextStyle(color: Color(0xFF7A7D85), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF7A7D85), size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFF2A2B30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // Grid of categories with cell borders
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: displayCategories.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No categories found',
                              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _showAddOrEditCategoryDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Category'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildCustomBorderedGrid(displayCategories),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a 3-column table-like grid with subtle borders between columns and rows
  Widget _buildCustomBorderedGrid(List<CategoryModel> categories) {
    const int crossAxisCount = 3;
    const Color borderColor = Color(0xFF2E3037);

    return SingleChildScrollView(
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(color: borderColor, width: 0.8),
          verticalInside: BorderSide(color: borderColor, width: 0.8),
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: _buildTableRows(categories, crossAxisCount),
      ),
    );
  }

  List<TableRow> _buildTableRows(List<CategoryModel> categories, int count) {
    final List<TableRow> rows = [];
    final int rowCount = (categories.length / count).ceil();

    for (int r = 0; r < rowCount; r++) {
      final List<Widget> cells = [];
      for (int c = 0; c < count; c++) {
        final int index = r * count + c;
        if (index < categories.length) {
          final cat = categories[index];
          cells.add(_buildGridCell(cat));
        } else {
          // Empty cell placeholder to maintain table grid structure
          cells.add(const SizedBox(height: 56));
        }
      }
      rows.add(TableRow(children: cells));
    }

    return rows;
  }

  Widget _buildGridCell(CategoryModel cat) {
    final isSelected = widget.selectedCategory.toLowerCase() == cat.name.toLowerCase();
    final emoji = CategoryEmojiHelper.getEmoji(cat.icon, cat.name);

    return Material(
      color: isSelected ? const Color(0xFF2E313A) : Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onCategorySelected(cat.name);
          Navigator.of(context).pop();
        },
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFE2E4EA),
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Manage / Edit Mode view allowing Drag & Drop reordering, category deletion, and category addition
  Widget _buildManageCategoriesView(List<CategoryModel> categories) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF212226),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header for Edit Mode
            _buildHeader(
              title: 'Edit Categories',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditMode = false;
                      });
                    },
                    icon: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
                    label: const Text(
                      'Done',
                      style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFB0B3B8), size: 22),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Top bar with instructions & "+ Add Category" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Drag = to reorder • Tap 🗑 to delete',
                    style: TextStyle(color: Color(0xFF8A8D96), fontSize: 13),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3240),
                      foregroundColor: const Color(0xFF64B5F6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showAddOrEditCategoryDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2E3037), height: 1),

            // Reorderable list of categories
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.58,
              ),
              child: categories.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No categories. Tap "+ Add Category" to create one.',
                          style: TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = categories.removeAt(oldIndex);
                          categories.insert(newIndex, item);
                        });
                        // Persist new order
                        ref.read(categoryControllerProvider).reorderCategories(categories);
                      },
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final emoji = CategoryEmojiHelper.getEmoji(cat.icon, cat.name);

                        return Container(
                          key: ValueKey(cat.uuid.isNotEmpty ? cat.uuid : '${cat.name}_$index'),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF2B2D33), width: 0.8),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            leading: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(
                                Icons.drag_handle,
                                color: Color(0xFF7A7D85),
                                size: 24,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    cat.name,
                                    style: const TextStyle(
                                      color: Color(0xFFE2E4EA),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF8A8D96), size: 20),
                                  tooltip: 'Edit',
                                  onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: cat),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE57373), size: 20),
                                  tooltip: 'Delete',
                                  onPressed: () => _confirmDeleteCategory(cat),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required String title, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.only(left: 18.0, right: 6.0, top: 12.0, bottom: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2D32),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE4E6EB),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  /// Confirms category deletion
  void _confirmDeleteCategory(CategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF26272C),
        title: const Text('Delete Category?', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Text(
          'Are you sure you want to delete "${cat.name}"? Existing transactions will keep their records.',
          style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(categoryControllerProvider).deleteCategory(cat.uuid);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Dialog to add a new category or edit an existing category with custom emoji picker
  void _showAddOrEditCategoryDialog({CategoryModel? categoryToEdit}) {
    final isEditing = categoryToEdit != null;
    final nameController = TextEditingController(text: isEditing ? categoryToEdit.name : '');
    String selectedEmoji = isEditing
        ? CategoryEmojiHelper.getEmoji(categoryToEdit.icon, categoryToEdit.name)
        : '🥤';
    String selectedCategoryTab = 'Food & Drinks';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF212226),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final activeEmojis = CategoryEmojiHelper.emojiCategories[selectedCategoryTab] ??
                CategoryEmojiHelper.emojiCategories.values.first;

            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Category' : 'Add Category',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.of(modalContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selected Emoji preview and Name input row
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2D33),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF3E4048)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            selectedEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Category Name',
                              labelStyle: const TextStyle(color: Color(0xFF8A8D96)),
                              hintText: 'e.g. Drink, Snacks, Clothes',
                              hintStyle: const TextStyle(color: Color(0xFF5A5D65)),
                              filled: true,
                              fillColor: const Color(0xFF2A2B30),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Custom Emoji Input or Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Emoji',
                          style: TextStyle(color: Color(0xFFB0B3B8), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        // Quick custom emoji typer
                        SizedBox(
                          width: 140,
                          height: 36,
                          child: TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Type any emoji',
                              hintStyle: const TextStyle(color: Color(0xFF6A6D75), fontSize: 12),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              filled: true,
                              fillColor: const Color(0xFF2A2B30),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) {
                              if (val.trim().isNotEmpty && CategoryEmojiHelper.isEmoji(val.trim())) {
                                setModalState(() {
                                  selectedEmoji = val.trim();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Emoji Category Tabs
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: CategoryEmojiHelper.emojiCategories.keys.map((tab) {
                          final isSelected = selectedCategoryTab == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(tab),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF9A9DA6),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF383A44),
                              backgroundColor: const Color(0xFF28292E),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF5A5D6B) : Colors.transparent,
                              ),
                              onSelected: (_) {
                                setModalState(() {
                                  selectedCategoryTab = tab;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Emoji Grid
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1C20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2D2E35)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        itemCount: activeEmojis.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (ctx, index) {
                          final emoji = activeEmojis[index];
                          final isSelected = selectedEmoji == emoji;

                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedEmoji = emoji;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF383B46) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: const Color(0xFF64B5F6), width: 1.5)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        if (isEditing) {
                          categoryToEdit.name = name;
                          categoryToEdit.icon = selectedEmoji;
                          categoryToEdit.updatedAt = DateTime.now();
                          await ref.read(categoryControllerProvider).saveCategory(categoryToEdit);
                        } else {
                          final newCat = CategoryModel()
                            ..uuid = ''
                            ..userId = ''
                            ..name = name
                            ..type = widget.type
                            ..icon = selectedEmoji
                            ..color = '#2196F3'
                            ..order = 0 // Placed at beginning for user convenience
                            ..isDefault = false
                            ..isDeleted = false
                            ..isSynced = false
                            ..createdAt = DateTime.now()
                            ..updatedAt = DateTime.now()
                            ..syncVersion = 1;

                          await ref.read(categoryControllerProvider).saveCategory(newCat);
                        }

                        if (modalContext.mounted) {
                          Navigator.of(modalContext).pop();
                        }
                      },
                      child: Text(
                        isEditing ? 'Save Changes' : 'Add Category',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
