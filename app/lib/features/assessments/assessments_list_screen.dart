import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../services/storage.dart';

class AssessmentsListScreen extends StatefulWidget {
  const AssessmentsListScreen({super.key});

  @override
  State<AssessmentsListScreen> createState() => _AssessmentsListScreenState();
}

class _AssessmentsListScreenState extends State<AssessmentsListScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = await StorageService().getUserId();
      if (uid == null) {
        if (!mounted) return;
        context.go('/onboarding');
        return;
      }
      final api = const ApiClient();
      final list = await api.listAssessments(uid);
      setState(() {
        _userId = uid;
        _items = list;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments'),
        actions: [
          IconButton(
            onPressed: () => context.go('/resources'),
            icon: const Icon(Icons.public),
            tooltip: 'Resources',
          ),
          IconButton(
            onPressed: () => context.go('/alerts'),
            icon: const Icon(Icons.alarm),
            tooltip: 'Alerts',
          ),
          IconButton(
            onPressed: () => context.go('/privacy'),
            icon: const Icon(Icons.privacy_tip),
            tooltip: 'Privacy',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _userId == null
            ? null
            : () => context.go('/assessments/form', extra: {'userId': _userId}),
        icon: const Icon(Icons.add),
        label: const Text('New assessment'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final a = _items[index];
                      final type = a['type'] as String;
                      final score = (a['risk_score'] as num?)?.toDouble();
                      final createdAt = a['created_at'] as String?;
                      return Card(
                        child: ListTile(
                          title: Text(type.replaceAll('_', ' ')),
                          subtitle: Text(createdAt ?? ''),
                          trailing: score != null
                              ? Chip(label: Text('Risk ${(score * 100).toStringAsFixed(0)}%'))
                              : const Text('No score'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
