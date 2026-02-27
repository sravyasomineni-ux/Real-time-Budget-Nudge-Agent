import 'package:hive/hive.dart';

part 'behavior_profile.g.dart';

@HiveType(typeId: 2)
class BehaviorProfile extends HiveObject {
  @HiveField(0)
  int lateNightCravingsCount;

  @HiveField(1)
  int weekendSplurgesCount;

  @HiveField(2)
  int frequentSmallOrdersCount;

  @HiveField(3)
  String currentNickname;

  BehaviorProfile({
    this.lateNightCravingsCount = 0,
    this.weekendSplurgesCount = 0,
    this.frequentSmallOrdersCount = 0,
    this.currentNickname = 'Neutral Observer',
  });
}
