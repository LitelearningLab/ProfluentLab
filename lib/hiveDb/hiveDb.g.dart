// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiveDb.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProcessLearningLinkHiveAdapter
    extends TypeAdapter<ProcessLearningLinkHive> {
  @override
  final int typeId = 1;

  @override
  ProcessLearningLinkHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProcessLearningLinkHive(
      item: (fields[0] as List?)?.cast<ProcessLearningLink>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProcessLearningLinkHive obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.item);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessLearningLinkHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
