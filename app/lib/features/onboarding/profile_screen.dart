import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  String _region = 'KE';
  String _language = 'en';

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _region,
                items: const [
                  DropdownMenuItem(value: 'KE', child: Text('Kenya (KE)')),
                ],
                onChanged: (v) => setState(() => _region = v ?? 'KE'),
                decoration: const InputDecoration(labelText: 'Region'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
                decoration: const InputDecoration(labelText: 'Language'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Persist locally; actual user creation after consent step.
                      context.go('/onboarding/consent', extra: {
                        'email': _emailCtrl.text.trim(),
                        'region': _region,
                        'language': _language,
                      });
                    }
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
