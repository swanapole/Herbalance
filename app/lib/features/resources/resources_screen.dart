import 'package:flutter/material.dart';

import '../../services/api_client.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

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
      final api = const ApiClient();
      final json = await api.getResourcesKE();
      setState(() => _data = json);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources (Kenya)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_data?['disclaimer'] != null) ...[
                        Text(
                          _data!['disclaimer'] as String,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ...((_data?['categories'] as List? ?? const [])).map((cat) {
                        final Map<String, dynamic> c = (cat as Map).cast<String, dynamic>();
                        final items = (c['items'] as List? ?? const []).cast<Map>();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['title']?.toString() ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((it) {
                              final m = it.cast<String, dynamic>();
                              return Card(
                                child: ListTile(
                                  title: Text(m['name']?.toString() ?? ''),
                                  subtitle: Text(m['description']?.toString() ?? ''),
                                  trailing: const Icon(Icons.open_in_new),
                                  onTap: () async {
                                    final url = m['url']?.toString();
                                    if (url == null) return;
                                    // Use canLaunchUrl in real app; keeping minimal dependency footprint for MVP.
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        );
                      })
                    ],
                  ),
                ),
    );
  }
}
