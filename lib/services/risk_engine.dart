import 'dart:math';

class RiskEngine {
  /// Calculates risk score (0-100)
  ///
  /// Factors:
  /// - Budget usage percentage (Total spent / Monthly budget) * 100
  /// - Late night indicator (Is this purchase after 10 PM and before 4 AM?)
  /// - Weekend indicator (Is this a Friday evening, Saturday, or Sunday?)
  static double calculateRiskScore({
    required double totalSpent,
    required double monthlyBudget,
    required DateTime transactionTime,
  }) {
    if (monthlyBudget <= 0) return 100.0;

    double budgetPercentage = (totalSpent / monthlyBudget) * 100.0;
    double baseRisk = min(budgetPercentage, 100.0);

    // Add velocity/time based multipliers
    double riskMultiplier = 1.0;

    // Late night impulse (10 PM to 4 AM)
    if (transactionTime.hour >= 22 || transactionTime.hour < 4) {
      riskMultiplier += 0.15; // +15% risk for late night
    }

    // Weekend splurge (Friday after 5 PM, Saturday, Sunday)
    if (transactionTime.weekday == DateTime.saturday ||
        transactionTime.weekday == DateTime.sunday ||
        (transactionTime.weekday == DateTime.friday &&
            transactionTime.hour >= 17)) {
      riskMultiplier += 0.10; // +10% risk for weekend
    }

    double finalRisk = baseRisk * riskMultiplier;
    return min(finalRisk, 100.0);
  }

  static String getEscalationStage(double budgetPercentage) {
    if (budgetPercentage >= 100) return 'Cartoon Intervention';
    if (budgetPercentage >= 95) return 'Strict Alert';
    if (budgetPercentage >= 85) return 'High Urgency';
    if (budgetPercentage >= 75) return 'Strong Concern';
    if (budgetPercentage >= 60) return 'Playful Warning';
    if (budgetPercentage >= 40) return 'Soft Reminder';
    return 'Friendly Confirmation';
  }
}
