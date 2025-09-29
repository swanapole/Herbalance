import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_client.dart';
import '../../services/storage.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const List<DropdownMenuItem<String>> _types = [
    DropdownMenuItem(value: 'screening', child: Text('Screening')),
    DropdownMenuItem(value: 'vaccination', child: Text('Vaccination')),
    DropdownMenuItem(value: 'checkin', child: Text('Wellness check-in')),
    DropdownMenuItem(value: 'followup', child: Text('Follow up')),
  ];

  String _type = 'screening';
  DateTime _when = DateTime.now().add(const Duration(days: 7));
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
      if (uid == null) throw Exception('Missing user. Re-onboard.');
      const api = ApiClient();
      final list = await api.listAlerts(uid);
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

  Future<void> _create() async {
    if (_userId == null) return;
    setState(() => _loading = true);
    try {
      const api = ApiClient();
      await api.createAlert(userId: _userId!, type: _type, scheduleAt: _when);
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _type,
                        items: _types,
                        onChanged: (v) => setState(() => _type = v ?? 'screening'),
                        decoration: const InputDecoration(labelText: 'Type'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            initialDate: _when,
                          );
                          if (!context.mounted) return;
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_when),
                            );
                            if (!context.mounted) return;
                            if (time != null) {
                              setState(() => _when = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  ));
                            }
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Schedule at'),
                          child: Text(df.format(_when)),
                        ),
                      ),
                    )
                  ]),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _create,
                      icon: const Icon(Icons.add_alarm),
                      label: const Text('Create reminder'),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text('Upcoming & past reminders', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final a = _items[i];
                          final when = a['schedule_at'] as String?;
                          final delivered = a['delivered_at'] as String?;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.alarm),
                              title: Text(a['type'] as String? ?? ''),
                              subtitle: Text('at ${when ?? ''}${delivered != null ? '\nDelivered: $delivered' : ''}'),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
