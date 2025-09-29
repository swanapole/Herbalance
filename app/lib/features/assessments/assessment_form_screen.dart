import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';
import '../../services/classifier.dart';

class AssessmentFormScreen extends StatefulWidget {
  const AssessmentFormScreen({super.key});

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'mental_health_stress';

  // Stress fields (1..5)
  int _sleep = 3;
  int _mood = 3;
  int _workload = 3;

  // Breast
  int _ageBreast = 30;
  bool _familyHistory = false;

  // Cervical
  int _ageCervical = 30;
  bool _screeningUpToDate = false;

  // Osteoporosis
  int _ageOsteo = 45;
  bool _lowBmi = false;

  bool _submitting = false;
  String? _error;
  String? _success;

  List<DropdownMenuItem<String>> get _types => const [
        DropdownMenuItem(value: 'breast_cancer_risk', child: Text('Breast cancer (heuristic)')),
        DropdownMenuItem(value: 'cervical_cancer_risk', child: Text('Cervical cancer (heuristic)')),
        DropdownMenuItem(value: 'osteoporosis_risk', child: Text('Osteoporosis (heuristic)')),
        DropdownMenuItem(value: 'mental_health_stress', child: Text('Stress check-in')),
      ];

  Widget _buildFields() {
    switch (_type) {
      case 'breast_cancer_risk':
        return Column(children: [
          TextFormField(
            initialValue: '$_ageBreast',
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            onChanged: (v) => _ageBreast = int.tryParse(v) ?? _ageBreast,
          ),
          SwitchListTile(
            value: _familyHistory,
            onChanged: (v) => setState(() => _familyHistory = v),
            title: const Text('Family history'),
          )
        ]);
      case 'cervical_cancer_risk':
        return Column(children: [
          TextFormField(
            initialValue: '$_ageCervical',
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            onChanged: (v) => _ageCervical = int.tryParse(v) ?? _ageCervical,
          ),
          SwitchListTile(
            value: _screeningUpToDate,
            onChanged: (v) => setState(() => _screeningUpToDate = v),
            title: const Text('Screening up to date'),
          )
        ]);
      case 'osteoporosis_risk':
        return Column(children: [
          TextFormField(
            initialValue: '$_ageOsteo',
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            onChanged: (v) => _ageOsteo = int.tryParse(v) ?? _ageOsteo,
          ),
          SwitchListTile(
            value: _lowBmi,
            onChanged: (v) => setState(() => _lowBmi = v),
            title: const Text('Low BMI'),
          )
        ]);
      default:
        return Column(children: [
          _slider('Sleep quality', _sleep, (v) => setState(() => _sleep = v)),
          _slider('Mood', _mood, (v) => setState(() => _mood = v)),
          _slider('Workload', _workload, (v) => setState(() => _workload = v)),
        ]);
    }
  }

  Widget _slider(String label, int value, void Function(int) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text(label),
      Slider(
        value: value.toDouble(),
        min: 1,
        max: 5,
        divisions: 4,
        label: '$value',
        onChanged: (v) => onChanged(v.toInt()),
      )
    ]);
  }

  Future<void> _submit(Map extra) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
      _success = null;
    });
    try {
      final userId = (extra['userId'] ?? (GoRouterState.of(context).extra as Map?)?['userId']) as String?;
      if (userId == null) throw Exception('Missing userId');

      final classifier = ClassifierService();
      double? riskScore;
      String? explanation;
      Map<String, dynamic> answers = {};
      switch (_type) {
        case 'breast_cancer_risk':
          final res = classifier.breastRiskHeuristic(age: _ageBreast, familyHistory: _familyHistory);
          riskScore = res['score'] as double;
          explanation = res['explanation'] as String;
          answers = {'age': _ageBreast, 'familyHistory': _familyHistory};
          break;
        case 'cervical_cancer_risk':
          final res = classifier.cervicalRiskHeuristic(age: _ageCervical, screeningUpToDate: _screeningUpToDate);
          riskScore = res['score'] as double;
          explanation = res['explanation'] as String;
          answers = {'age': _ageCervical, 'screeningUpToDate': _screeningUpToDate};
          break;
        case 'osteoporosis_risk':
          final res = classifier.osteoporosisRiskHeuristic(age: _ageOsteo, lowBmi: _lowBmi);
          riskScore = res['score'] as double;
          explanation = res['explanation'] as String;
          answers = {'age': _ageOsteo, 'lowBmi': _lowBmi};
          break;
        default:
          final res = classifier.stressScore(sleepQuality: _sleep, mood: _mood, workload: _workload);
          riskScore = (res['score'] as num).toDouble();
          explanation = res['explanation'] as String;
          answers = {'sleep': _sleep, 'mood': _mood, 'workload': _workload};
      }

      final api = const ApiClient();
      await api.createAssessment(userId: userId, type: _type, answers: answers, riskScore: riskScore, explanation: explanation);

      if (!mounted) return;
      setState(() => _success = 'Assessment submitted.');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      context.go('/assessments');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = (GoRouterState.of(context).extra as Map?) ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('New Assessment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: _types,
                onChanged: (v) => setState(() => _type = v ?? 'mental_health_stress'),
                decoration: const InputDecoration(labelText: 'Assessment type'),
              ),
              const SizedBox(height: 12),
              _buildFields(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              if (_success != null) ...[
                const SizedBox(height: 12),
                Text(_success!, style: const TextStyle(color: Colors.green)),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _submitting ? null : () => _submit(extra),
                icon: const Icon(Icons.send),
                label: _submitting ? const Text('Submitting...') : const Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
