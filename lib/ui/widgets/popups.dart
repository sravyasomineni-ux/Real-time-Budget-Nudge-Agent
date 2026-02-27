import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../../models/transaction.dart';
import '../../models/user_profile.dart';
import '../../services/emotion_engine.dart';
import '../../services/risk_engine.dart';

class InterventionPopups {
  static void showTransactionPopup({
    required BuildContext context,
    required ExpenseTransaction transaction,
    required double currentTotal,
    required double budget,
    required UserProfile profile,
  }) {
    final riskScore = RiskEngine.calculateRiskScore(
      totalSpent: currentTotal,
      monthlyBudget: budget,
      transactionTime: transaction.timestamp,
    );

    final budgetPercentage = (currentTotal / budget) * 100;

    // Trigger Cartoon Mode if >= 100%
    if (budgetPercentage >= 100) {
      _showCartoonIntervention(
        context,
        currentTotal - budget,
        budgetPercentage,
      );
      return;
    }

    // Generate Adaptive Message
    final message = EmotionEngine.generateMessage(
      userName: profile.name,
      budgetPercentage: budgetPercentage,
      amount: transaction.amount,
      riskScore: riskScore,
      isAutoMode: profile.isAutoMode,
      manualTone: profile.manualTone,
      activeNickname: EmotionEngine.getNickname(
        0,
        0,
      ), // Mocked behavior profile for now
    );

    final color = PersonaTheme.getRiskColor(riskScore);
    final stage = RiskEngine.getEscalationStage(budgetPercentage);

    // Show custom sliding modal
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 60, left: 16, right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PersonaTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: color, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stage.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      color: PersonaTheme.textMain,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  static void _showCartoonIntervention(
    BuildContext context,
    double overshoot,
    double budgetPercentage,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: PersonaTheme.errorRed,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: PersonaTheme.errorRed.withValues(alpha: 0.6),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('😭💸', style: TextStyle(fontSize: 80))
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scaleXY(begin: 1.0, end: 1.2, duration: 300.ms),
                  const SizedBox(height: 24),
                  const Text(
                    'WHOA THERE!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().shake(hz: 8),
                  const SizedBox(height: 16),
                  Text(
                    'You crossed your food budget! You are at ${budgetPercentage.toStringAsFixed(0)}%.\nOvershoot: ₹${overshoot.toStringAsFixed(0)}.',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your wallet has officially filed a complaint. Please step away from the delivery apps immediately.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: PersonaTheme.errorRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'I WILL STOP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(curve: Curves.elasticOut),
          ),
        );
      },
    );
  }
}
