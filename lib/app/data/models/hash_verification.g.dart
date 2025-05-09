// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hash_verification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HashVerificationAdapter extends TypeAdapter<HashVerification> {
  @override
  final int typeId = 5;

  @override
  HashVerification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HashVerification(
      id: fields[0] as String?,
      recordId: fields[1] as String,
      masterHash: fields[2] as String,
      componentHashes: (fields[3] as Map).cast<String, String>(),
      createdAt: fields[4] as DateTime?,
      lastVerifiedAt: fields[5] as DateTime?,
      isValid: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HashVerification obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recordId)
      ..writeByte(2)
      ..write(obj.masterHash)
      ..writeByte(3)
      ..write(obj.componentHashes)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastVerifiedAt)
      ..writeByte(6)
      ..write(obj.isValid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HashVerificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
