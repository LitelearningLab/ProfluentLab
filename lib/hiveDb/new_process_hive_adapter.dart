import 'package:hive/hive.dart';
import '../models/ProcessLearningLink.dart';

class ProcessLearningLinkAdapter extends TypeAdapter<ProcessLearningLink> {
  @override
  final int typeId = 0; // Make sure this ID is unique for each adapter

  @override
  ProcessLearningLink read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final faq = reader.readString();
    final video = reader.readString();
    final simulation = reader.readString();
    final knowledge = reader.readString();
    final eLearning = reader.readString();

    return ProcessLearningLink(
      id: id,
      name: name,
      faq: faq,
      video: video,
      simulation: simulation,
      knowledge: knowledge,
      eLearning: eLearning,
    );
  }

  @override
  void write(BinaryWriter writer, ProcessLearningLink obj) {
    writer.writeString(obj.id ?? '');
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.faq ?? '');
    writer.writeString(obj.video ?? '');
    writer.writeString(obj.simulation ?? '');
    writer.writeString(obj.knowledge ?? '');
    writer.writeString(obj.eLearning ?? '');
  }
}
