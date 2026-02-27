import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class ExpenseTransaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String merchantName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String rawSms;

  @HiveField(5)
  double riskScoreAtTime;

  @HiveField(6)
  String toneUsed;

  ExpenseTransaction({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.timestamp,
    required this.rawSms,
    required this.riskScoreAtTime,
    required this.toneUsed,
  });
}
