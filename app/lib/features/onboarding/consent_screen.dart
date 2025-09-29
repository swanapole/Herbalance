import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_client.dart';
import '../../services/storage.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _consentSensitive = false;
  bool _loading = false;
  String? _error;

  Future<void> _complete(Map extra) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = extra['email'] as String;
      final region = extra['region'] as String? ?? 'KE';
      final language = extra['language'] as String? ?? 'en';

      const api = ApiClient();
      final res = await api.createOrUpdateUser(
        email: email,
        region: region,
        language: language,
        consents: {'sensitiveData': _consentSensitive},
      );

      final userId = res['id'] as String;
      await StorageService().saveUser(
        id: userId,
        email: email,
        region: region,
        language: language,
        consentSensitive: _consentSensitive,
      );

      if (!mounted) return;
      context.go('/assessments');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = (GoRouterState.of(context).extra as Map?) ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Consent')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensitive Data Consent',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We only collect the minimum necessary information. '
              'Your assessment answers may be considered sensitive. '
              'Please provide explicit consent to store them securely.',
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _consentSensitive,
              onChanged: (v) => setState(() => _consentSensitive = v ?? false),
              title: const Text('I consent to processing sensitive data for assessments'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _complete(extra),
                child: _loading ? const CircularProgressIndicator() : const Text('Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
