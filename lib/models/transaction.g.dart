// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseTransactionAdapter extends TypeAdapter<ExpenseTransaction> {
  @override
  final int typeId = 1;

  @override
  ExpenseTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseTransaction(
      id: fields[0] as String,
      merchantName: fields[1] as String,
      amount: fields[2] as double,
      timestamp: fields[3] as DateTime,
      rawSms: fields[4] as String,
      riskScoreAtTime: fields[5] as double,
      toneUsed: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseTransaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.merchantName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.rawSms)
      ..writeByte(5)
      ..write(obj.riskScoreAtTime)
      ..writeByte(6)
      ..write(obj.toneUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
