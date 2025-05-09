// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PairingInfoAdapter extends TypeAdapter<PairingInfo> {
  @override
  final int typeId = 3;

  @override
  PairingInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PairingInfo(
      id: fields[0] as String?,
      deviceId: fields[1] as String,
      deviceName: fields[2] as String,
      pairingCode: fields[3] as String?,
      createdAt: fields[4] as DateTime?,
      expiresAt: fields[5] as DateTime?,
      status: fields[6] as PairingStatus,
      recordId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PairingInfo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deviceId)
      ..writeByte(2)
      ..write(obj.deviceName)
      ..writeByte(3)
      ..write(obj.pairingCode)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.expiresAt)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.recordId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairingInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PairingStatusAdapter extends TypeAdapter<PairingStatus> {
  @override
  final int typeId = 4;

  @override
  PairingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PairingStatus.PENDING;
      case 1:
        return PairingStatus.PAIRED;
      case 2:
        return PairingStatus.DISCONNECTED;
      case 3:
        return PairingStatus.EXPIRED;
      case 4:
        return PairingStatus.REJECTED;
      default:
        return PairingStatus.PENDING;
    }
  }

  @override
  void write(BinaryWriter writer, PairingStatus obj) {
    switch (obj) {
      case PairingStatus.PENDING:
        writer.writeByte(0);
        break;
      case PairingStatus.PAIRED:
        writer.writeByte(1);
        break;
      case PairingStatus.DISCONNECTED:
        writer.writeByte(2);
        break;
      case PairingStatus.EXPIRED:
        writer.writeByte(3);
        break;
      case PairingStatus.REJECTED:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
