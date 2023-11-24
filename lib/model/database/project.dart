import 'package:isar/isar.dart';

part 'project.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  // 项目名
  String name = '';
}
