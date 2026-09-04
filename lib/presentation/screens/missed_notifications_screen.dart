import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/strings.dart';
import '../../providers/task_list_provider.dart';

class MissedNotificationsScreen extends ConsumerStatefulWidget {
  const MissedNotificationsScreen({super.key});

  @override
  ConsumerState<MissedNotificationsScreen> createState() =>
      _MissedNotificationsScreenState();
}

class _MissedNotificationsScreenState
    extends ConsumerState<MissedNotificationsScreen> {
  List<Map<String, dynamic>> _missed = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notifier = ref.read(taskListProvider.notifier);
    final missed = await notifier.getMissedNotifications();
    setState(() => _missed = missed);
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'p1':
        return 'P1 Penting';
      case 'p2':
        return 'P2';
      case 'p3':
        return 'P3';
      case 'p4':
        return 'P4';
      default:
        return priority;
    }
  }

  Color _priorityColor(String priority, ColorScheme scheme) {
    switch (priority) {
      case 'p1':
        return scheme.error;
      case 'p2':
        return Colors.orange;
      case 'p3':
        return scheme.primary;
      case 'p4':
        return scheme.onSurface.withOpacity(0.4);
      default:
        return scheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Terlewat'),
        actions: [
          if (_missed.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua',
              onPressed: () async {
                final notifier = ref.read(taskListProvider.notifier);
                await notifier.clearMissedNotifications();
                setState(() => _missed = []);
              },
            ),
        ],
      ),
      body: _missed.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64,
                      color: scheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi terlewat',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _missed.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _missed[index];
                final dueDate = DateTime.parse(item['dueDate'] as String);
                final priority = item['priority'] as String;
                final title = item['title'] as String;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _priorityColor(priority, scheme)
                        .withOpacity(0.15),
                    child: Icon(
                      Icons.notifications_off,
                      size: 20,
                      color: _priorityColor(priority, scheme),
                    ),
                  ),
                  title: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${_priorityLabel(priority)}  •  Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () async {
                      setState(() => _missed.removeAt(index));
                      final prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'missed_notifications', jsonEncode(_missed));
                    },
                  ),
                  onTap: () {
                    context.push('/tasks/${item['uuid']}');
                  },
                );
              },
            ),
    );
  }
}
