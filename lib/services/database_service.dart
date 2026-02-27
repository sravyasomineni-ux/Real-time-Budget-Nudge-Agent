import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/transaction.dart';
import '../models/behavior_profile.dart';

class DatabaseService {
  static const String userBoxName = 'userBox';
  static const String transactionBoxName = 'transactionBox';
  static const String behaviorBoxName = 'behaviorBox';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExpenseTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BehaviorProfileAdapter());
    }

    // Open Boxes
    await Hive.openBox<UserProfile>(userBoxName);
    await Hive.openBox<ExpenseTransaction>(transactionBoxName);
    await Hive.openBox<BehaviorProfile>(behaviorBoxName);
  }

  // --- User Profile ---
  Box<UserProfile> get userBox => Hive.box<UserProfile>(userBoxName);

  Future<void> saveUserProfile(UserProfile profile) async {
    await userBox.put('profile', profile);
  }

  UserProfile? getUserProfile() {
    return userBox.get('profile');
  }

  // --- Transactions ---
  Box<ExpenseTransaction> get transactionBox =>
      Hive.box<ExpenseTransaction>(transactionBoxName);

  Future<void> addTransaction(ExpenseTransaction tx) async {
    await transactionBox.add(tx);
  }

  List<ExpenseTransaction> getAllTransactions() {
    return transactionBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  double getTotalSpentThisMonth() {
    final now = DateTime.now();
    return transactionBox.values
        .where(
          (tx) =>
              tx.timestamp.year == now.year && tx.timestamp.month == now.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // --- Behavior Profile ---
  Box<BehaviorProfile> get behaviorBox =>
      Hive.box<BehaviorProfile>(behaviorBoxName);

  Future<void> saveBehaviorProfile(BehaviorProfile profile) async {
    await behaviorBox.put('profile', profile);
  }

  BehaviorProfile getBehaviorProfile() {
    return behaviorBox.get('profile') ?? BehaviorProfile();
  }
}
