// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_interactive_simulator_hivedb.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InteractiveLinkHiveAdapter extends TypeAdapter<InteractiveLinkHive> {
  @override
  final int typeId = 4;

  @override
  InteractiveLinkHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InteractiveLinkHive(
      item: (fields[0] as List?)?.cast<InteractiveLink>(),
    );
  }

  @override
  void write(BinaryWriter writer, InteractiveLinkHive obj) {
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
      other is InteractiveLinkHiveAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
