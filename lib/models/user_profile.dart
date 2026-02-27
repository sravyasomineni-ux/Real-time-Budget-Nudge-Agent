import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  double monthlyFoodBudget;

  @HiveField(3)
  bool isAutoMode; // true = Auto, false = Manual

  @HiveField(4)
  String manualTone; // only used if isAutoMode is false

  UserProfile({
    required this.name,
    required this.email,
    required this.monthlyFoodBudget,
    this.isAutoMode = true,
    this.manualTone = 'Friendly',
  });
}
