import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/database_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final profile = db.getUserProfile();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Name'),
            subtitle: Text(profile.name),
            leading: const Icon(Icons.person),
          ),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(profile.email),
            leading: const Icon(Icons.email),
          ),
          ListTile(
            title: const Text('Monthly Food Budget'),
            subtitle: Text('₹${profile.monthlyFoodBudget.toStringAsFixed(0)}'),
            leading: const Icon(Icons.account_balance_wallet),
          ),
          ListTile(
            title: const Text('Emotion Mode'),
            subtitle: Text(
              profile.isAutoMode ? 'Auto AI' : 'Manual (${profile.manualTone})',
            ),
            leading: const Icon(Icons.psychology),
          ),
        ],
      ),
    );
  }
}
