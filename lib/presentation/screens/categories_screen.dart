import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n/strings.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';
import '../widgets/error_state.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _nameController = TextEditingController();
  var _selectedColor = 0xFF5B67CA;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  static const _colors = [
    0xFF5B67CA,
    0xFF43C6AC,
    0xFFEF4444,
    0xFFF59E0B,
    0xFF3B82F6,
    0xFF8B5CF6,
    0xFFEC4899,
    0xFF14B8A6,
  ];

  Future<void> _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(categoryListProvider.notifier).create(
          name: name,
          color: _selectedColor,
        );
    _nameController.clear();
    setState(() => _selectedColor = 0xFF5B67CA);
  }

  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.categoryHapus),
        content: const Text(S.categoryHapusDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(S.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(S.hapus),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(categoryListProvider.notifier).delete(category.uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(S.categoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    maxLength: AppConstants.categoryNameMaxLength,
                    decoration: const InputDecoration(
                      hintText: S.categoryBaru,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedColor,
                  underline: const SizedBox(),
                  items: _colors
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(c),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedColor = v);
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(
                detail: e.toString(),
                onRetry: () => ref.read(categoryListProvider.notifier).load(),
              ),
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Text(S.categoryKosong),
                  );
                }
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(category.color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      title: Text(category.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteCategory(category),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
