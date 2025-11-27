import 'package:hive/hive.dart';

import '../models/InteractiveLink.dart';

part 'new_interactive_simulator_hivedb.g.dart'; // This file will be generated

@HiveType(typeId: 1)
class InteractiveLinkHive extends HiveObject {
  @HiveField(0)
  List<InteractiveLink>? item;

  InteractiveLinkHive({
    this.item,
  });
}
