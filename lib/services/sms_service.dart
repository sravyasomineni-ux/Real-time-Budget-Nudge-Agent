import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'database_service.dart';
import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;
  final DatabaseService db;
  final Function(ExpenseTransaction) onFoodTransactionDetected;

  SmsService({required this.db, required this.onFoodTransactionDetected});

  final List<String> foodKeywords = [
    'swiggy',
    'zomato',
    'domino',
    'cafe',
    'restaurant',
    'food',
  ];

  Future<void> init() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted != null && permissionsGranted) {
      telephony.listenIncomingSms(
        onNewMessage: _handleIncomingSms,
        onBackgroundMessage: backgroundMessageHandler,
      );
    }
  }

  void _handleIncomingSms(SmsMessage message) async {
    debugPrint('New SMS: ${message.body}');
    _processMessage(message.body ?? "");
  }

  void _processMessage(String body) async {
    String lowerBody = body.toLowerCase();

    // Expanded keywords for real use cases
    final keywords = [
      'swiggy',
      'zomato',
      'domino',
      'cafe',
      'restaurant',
      'food',
      'eats',
    ];
    bool isFood = keywords.any((keyword) => lowerBody.contains(keyword));

    if (isFood) {
      debugPrint('Food transaction detected in SMS');

      // More robust regex for Indian Banks (e.g. Rs. 250.00, INR 250, debited by Rs.250)
      RegExp exp = RegExp(
        r'(?:rs\.?|inr|debited(?:\s+for|\s+by)?\s*(?:rs\.?|inr)?)\s*(\d+(?:\.\d{1,2})?)',
        caseSensitive: false,
      );
      Match? match = exp.firstMatch(lowerBody);

      double amount = 0.0;
      if (match != null && match.groupCount >= 1) {
        amount = double.tryParse(match.group(1)!) ?? 0.0;
      }

      if (amount <= 0.0) return;

      // Guess merchant
      String merchant = 'Food Order';
      for (String kw in keywords) {
        if (lowerBody.contains(kw)) {
          merchant = kw.toUpperCase();
          break;
        }
      }

      ExpenseTransaction tx = ExpenseTransaction(
        id: const Uuid().v4(),
        merchantName: merchant,
        amount: amount,
        timestamp: DateTime.now(),
        rawSms: body,
        riskScoreAtTime: 0.0,
        toneUsed: '',
      );

      // Trigger callback
      onFoodTransactionDetected(tx);
    }
  }
}

// Background handler must be top-level static method
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  debugPrint("Background SMS Processed: ${message.body}");

  if (message.body == null) return;
  String lowerBody = message.body!.toLowerCase();
  final keywords = [
    'swiggy',
    'zomato',
    'domino',
    'cafe',
    'restaurant',
    'food',
    'eats',
  ];

  if (keywords.any((kw) => lowerBody.contains(kw))) {
    RegExp exp = RegExp(
      r'(?:rs\.?|inr|debited(?:\s+for|\s+by)?\s*(?:rs\.?|inr)?)\s*(\d+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    Match? match = exp.firstMatch(lowerBody);

    if (match != null && match.groupCount >= 1) {
      double amount = double.tryParse(match.group(1)!) ?? 0.0;
      if (amount > 0) {
        String merchant = 'Food Order';
        for (String kw in keywords) {
          if (lowerBody.contains(kw)) {
            merchant = kw.toUpperCase();
            break;
          }
        }

        WidgetsFlutterBinding.ensureInitialized();
        final db = DatabaseService();
        await db.init();

        ExpenseTransaction tx = ExpenseTransaction(
          id: const Uuid().v4(),
          merchantName: merchant,
          amount: amount,
          timestamp: DateTime.now(),
          rawSms: message.body!,
          riskScoreAtTime: 0.0, // Calculated correctly when app opens
          toneUsed: 'Background Recorded',
        );
        await db.addTransaction(tx);
      }
    }
  }
}
