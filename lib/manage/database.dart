import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/common/manage.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:isar/isar.dart';

/*
* 数据库管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class DatabaseManage extends BaseManage {
  static final DatabaseManage _instance = DatabaseManage._internal();

  factory DatabaseManage() => _instance;

  DatabaseManage._internal();

  // 数据库对象
  late Isar isar;

  @override
  Future<void> initialize() async {
    final dir = await FileTool.getDirPath(Common.baseCachePath,
        root: FileDir.applicationDocuments);
    isar = await Isar.open(
      [
        ProjectSchema,
      ],
      directory: dir ?? '',
    );
  }

  // 获取全部项目列表
  Future<List<Project>> getProjectList() => isar.projects.where().findAll();
}

// 单例调用
final database = DatabaseManage();
