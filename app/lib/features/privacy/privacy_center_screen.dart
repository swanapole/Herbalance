import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../services/storage.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _export;
  bool _consentSensitive = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final c = await StorageService().getSensitiveConsent();
    if (mounted) setState(() => _consentSensitive = c);
  }

  Future<void> _exportData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = await StorageService().getUserId();
      if (uid == null) throw Exception('No user');
      const api = ApiClient();
      final data = await api.exportUser(uid);
      setState(() => _export = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final uid = await StorageService().getUserId();
    if (uid == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently delete your profile, assessments, and alerts from the server.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      const api = ApiClient();
      await api.deleteUser(uid);
      await StorageService().clearAll();
      if (!context.mounted) return;
      context.go('/onboarding');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Center')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Your Privacy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We collect minimal data. Sensitive data (assessment answers) is processed only with your explicit consent.',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _consentSensitive,
              onChanged: (_) {},
              title: const Text('Sensitive data consent'),
              subtitle: const Text('Configured during onboarding. Edit from Settings in a future version.'),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export my data'),
              subtitle: const Text('Download a JSON export of your profile, assessments, and alerts.'),
              trailing: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()) : null,
              onTap: _loading ? null : _exportData,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_export != null) ...[
              const SizedBox(height: 12),
              const Text('Preview (first 500 chars):'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(jsonEncode(_export).substring(0, _export.toString().length > 500 ? 500 : jsonEncode(_export).length)),
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete my account'),
              subtitle: const Text('This action is permanent and cannot be undone.'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: _loading ? null : _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
