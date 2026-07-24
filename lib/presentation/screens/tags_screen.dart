import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/tag.dart';
import '../../providers/tag_provider.dart';
import '../widgets/error_state.dart';

class TagsScreen extends ConsumerStatefulWidget {
  const TagsScreen({super.key});

  @override
  ConsumerState<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends ConsumerState<TagsScreen> {
  final _nameController = TextEditingController();
  var _selectedColor = 0xFF6366F1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  static const _colors = [
    0xFF6366F1,
    0xFF8B5CF6,
    0xFFEC4899,
    0xFFEF4444,
    0xFFF59E0B,
    0xFF10B981,
    0xFF06B6D4,
    0xFF3B82F6,
    0xFF84CC16,
    0xFF14B8A6,
  ];

  Future<void> _addTag() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(tagListProvider.notifier).create(
          name: name,
          color: _selectedColor,
        );
    _nameController.clear();
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus label'),
        content: Text('Hapus label "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(tagListProvider.notifier).delete(tag.uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Label')),
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
                      hintText: 'Nama label baru',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _addTag(),
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
                  onPressed: _addTag,
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
            child: tagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(
                detail: e.toString(),
                onRetry: () => ref.read(tagListProvider.notifier).load(),
              ),
              data: (tags) {
                if (tags.isEmpty) {
                  return const Center(
                    child: Text('Belum ada label'),
                  );
                }
                return ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(tag.color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.label,
                            color: Colors.white, size: 16),
                      ),
                      title: Text(tag.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTag(tag),
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
