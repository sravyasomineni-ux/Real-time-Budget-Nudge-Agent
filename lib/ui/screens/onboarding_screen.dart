import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  double _budget = 0.0;
  bool _isAutoMode = true;
  String _manualTone = 'Friendly';

  final List<String> tones = ['Friendly', 'Strict', 'Playful'];

  Future<void> _completeOnboarding() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final db = Provider.of<DatabaseService>(context, listen: false);
      final profile = UserProfile(
        name: _name,
        email: _email,
        monthlyFoodBudget: _budget,
        isAutoMode: _isAutoMode,
        manualTone: _manualTone,
      );

      await db.saveUserProfile(profile);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: PersonaTheme.primary,
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  'Welcome to PersonaBudget',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Your autonomous emotion-adaptive financial intervention agent.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 48),

                // Inputs
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => _name = value!,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => _email = value!,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Monthly Food Budget (₹)',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _budget = double.parse(value!),
                  textInputAction: TextInputAction.done,
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
                const SizedBox(height: 32),

                // Emotion Mode Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PersonaTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotion Mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Auto AI Mode'),
                        subtitle: const Text(
                          'Let the AI choose tone based on risk',
                        ),
                        value: _isAutoMode,
                        activeTrackColor: PersonaTheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _isAutoMode = val;
                          });
                        },
                      ),
                      if (!_isAutoMode) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _manualTone,
                          decoration: const InputDecoration(
                            labelText: 'Select Tone',
                          ),
                          items: tones.map((tone) {
                            return DropdownMenuItem(
                              value: tone,
                              child: Text(tone),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _manualTone = val!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 900.ms).scaleY(),

                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Start Interventions'),
                ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.5),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
