// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BehaviorProfileAdapter extends TypeAdapter<BehaviorProfile> {
  @override
  final int typeId = 2;

  @override
  BehaviorProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BehaviorProfile(
      lateNightCravingsCount: fields[0] as int,
      weekendSplurgesCount: fields[1] as int,
      frequentSmallOrdersCount: fields[2] as int,
      currentNickname: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BehaviorProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lateNightCravingsCount)
      ..writeByte(1)
      ..write(obj.weekendSplurgesCount)
      ..writeByte(2)
      ..write(obj.frequentSmallOrdersCount)
      ..writeByte(3)
      ..write(obj.currentNickname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehaviorProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
