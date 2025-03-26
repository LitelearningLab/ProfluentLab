import 'package:hive/hive.dart';
import '../models/InteractiveLink.dart';

class InteractiveLinkAdapter extends TypeAdapter<InteractiveLink> {
  @override
  final int typeId = 3;

  @override
  InteractiveLink read(BinaryReader reader) {
    return InteractiveLink(
      id: reader.readString(),
      name: reader.readString(),
      link1: reader.readString(),
      link2: reader.readString(),
      link3: reader.readString(),
      link4: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, InteractiveLink obj) {
    writer.writeString(obj.id ?? '');
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.link1 ?? '');
    writer.writeString(obj.link2 ?? '');
    writer.writeString(obj.link3 ?? '');
    writer.writeString(obj.link4 ?? '');
  }
}
