import 'dart:math';

class EmotionEngine {
  static const List<String> friendlyConfirmations = [
    'Just logging this snack! Keep your budget in mind 😋',
    'Got it! Another tasty purchase recorded.',
    'Tracking this food order. All good so far!',
  ];

  static const List<String> softReminders = [
    'Budget checking in! You\'re halfway there.',
    'Another bite? You still have room in the budget.',
    'Delicious! Just keeping an eye on that monthly limit.',
  ];

  static const List<String> playfulWarnings = [
    'Whoops, the wallet is getting a little lighter!',
    'Eating out again? Your kitchen misses you.',
    'Someone\'s hungry today! The budget is creeping up.',
  ];

  static const List<String> strongConcerns = [
    'Hey there! Food budget is getting dangerously low.',
    'We need to talk about your takeout habits 😅',
    'Warning: Your wallet is crying slightly.',
  ];

  static const List<String> highUrgencies = [
    'STOP! You are almost out of food money!',
    'Emergency! Only a few drops left in the budget bucket.',
    'Critical level reached! Step away from the delivery apps.',
  ];

  static const List<String> strictAlerts = [
    '🚨 STRICT MODE ACTIVATED! 🚨 No more food orders!',
    '🚨 OVERRIDE! BUDGET DEPLETED! 🚨 Kitchen. Now.',
    '🚨 HALT! 🚨 Your wallet has locked its doors.',
  ];

  // Helper mock dynamic nicknames based on behavior count
  static String getNickname(int lateNight, int weekend) {
    if (lateNight > 5) return 'Midnight Maharaja';
    if (weekend > 5) return 'Weekend Warrior';
    if (lateNight > 2 || weekend > 2) return 'Snack Commander';
    return 'Delivery CEO';
  }

  static String generateMessage({
    required String userName,
    required double budgetPercentage,
    required double amount,
    required double riskScore,
    required bool isAutoMode,
    required String manualTone,
    required String activeNickname,
  }) {
    final random = Random();
    String message = '';

    // ALWAYS OVERRIDE if risk > 90 or budget >= 95
    if (riskScore > 90 || budgetPercentage >= 95) {
      final alert = strictAlerts[random.nextInt(strictAlerts.length)];
      return '$alert $userName ($activeNickname), you spent ₹${amount.toStringAsFixed(0)}. Budget is at ${budgetPercentage.toStringAsFixed(1)}%.';
    }

    // Otherwise use auto or manual tone
    List<String> selectedPool;

    if (isAutoMode) {
      if (budgetPercentage < 40) {
        selectedPool = friendlyConfirmations;
      } else if (budgetPercentage < 60) {
        selectedPool = softReminders;
      } else if (budgetPercentage < 75) {
        selectedPool = playfulWarnings;
      } else if (budgetPercentage < 85) {
        selectedPool = strongConcerns;
      } else {
        selectedPool = highUrgencies;
      }
    } else {
      // Very simplified manual mapping for demo purposes
      if (manualTone.toLowerCase().contains('friendly')) {
        selectedPool = friendlyConfirmations;
      } else if (manualTone.toLowerCase().contains('strict')) {
        selectedPool = strictAlerts;
      } else {
        selectedPool = playfulWarnings;
      }
    }

    message = selectedPool[random.nextInt(selectedPool.length)];
    return '$message $userName, ₹${amount.toStringAsFixed(0)} logged. Budget: ${budgetPercentage.toStringAsFixed(1)}%.';
  }
}
