// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryRecordAdapter extends TypeAdapter<HistoryRecord> {
  @override
  final int typeId = 1;

  @override
  HistoryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryRecord(
      id: fields[0] as String?,
      partnerName: fields[1] as String,
      partnerDeviceId: fields[2] as String?,
      location: fields[3] as String?,
      createdAt: fields[4] as DateTime?,
      consentStatement: fields[5] as String?,
      audioRecordPath: fields[6] as String?,
      faceRecognitionPath: fields[7] as String?,
      photosPaths: (fields[8] as List?)?.cast<String>(),
      isCompleted: fields[9] as bool,
      hashValue: fields[10] as String?,
      status: fields[11] as RecordStatus,
      partnerAvatar: fields[12] as String,
      isVerified: fields[13] as bool,
      evidenceIds: (fields[14] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HistoryRecord obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.partnerName)
      ..writeByte(2)
      ..write(obj.partnerDeviceId)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.consentStatement)
      ..writeByte(6)
      ..write(obj.audioRecordPath)
      ..writeByte(7)
      ..write(obj.faceRecognitionPath)
      ..writeByte(8)
      ..write(obj.photosPaths)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.hashValue)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.partnerAvatar)
      ..writeByte(13)
      ..write(obj.isVerified)
      ..writeByte(14)
      ..write(obj.evidenceIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordStatusAdapter extends TypeAdapter<RecordStatus> {
  @override
  final int typeId = 2;

  @override
  RecordStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordStatus.CREATED;
      case 1:
        return RecordStatus.STATEMENT_RECORDED;
      case 2:
        return RecordStatus.FACE_RECOGNIZED;
      case 3:
        return RecordStatus.PHOTOS_CAPTURED;
      case 4:
        return RecordStatus.COMPLETED;
      case 5:
        return RecordStatus.VERIFIED;
      case 6:
        return RecordStatus.INVALIDATED;
      default:
        return RecordStatus.CREATED;
    }
  }

  @override
  void write(BinaryWriter writer, RecordStatus obj) {
    switch (obj) {
      case RecordStatus.CREATED:
        writer.writeByte(0);
        break;
      case RecordStatus.STATEMENT_RECORDED:
        writer.writeByte(1);
        break;
      case RecordStatus.FACE_RECOGNIZED:
        writer.writeByte(2);
        break;
      case RecordStatus.PHOTOS_CAPTURED:
        writer.writeByte(3);
        break;
      case RecordStatus.COMPLETED:
        writer.writeByte(4);
        break;
      case RecordStatus.VERIFIED:
        writer.writeByte(5);
        break;
      case RecordStatus.INVALIDATED:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
