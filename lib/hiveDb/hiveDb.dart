import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../models/ProcessLearningLink.dart';

part 'hiveDb.g.dart'; // This file will be generated

@HiveType(typeId: 1)
class ProcessLearningLinkHive extends HiveObject {
  @HiveField(0)
  List<ProcessLearningLink>? item;

  ProcessLearningLinkHive({
    this.item,
  });
}
