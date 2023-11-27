import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/common/manage.dart';
import 'package:flutter_manager/model/database/environment.dart';
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
        EnvironmentSchema,
      ],
      directory: dir ?? '',
    );
  }

  // 获取项目列表
  Future<List<Project>> getProjectList([bool pinned = false]) => isar.projects
      .where()
      .filter()
      .pinnedEqualTo(pinned)
      .sortByOrderDesc()
      .findAll();

  // 添加/更新项目
  Future<Project?> updateProject(Project item) => isar.writeTxn<Project?>(() {
        final length = isar.projects
            .where()
            .filter()
            .pinnedEqualTo(item.pinned)
            .sortByOrderDesc()
            .findAllSync()
            .length;
        return isar.projects.put(item..order = length).then(
              (id) => item..id = id,
            );
      });

  // 移除项目
  Future<bool> removeProject(int id) =>
      isar.writeTxn<bool>(() => isar.projects.delete(id));

  // 获取全部环境列表
  Future<List<Environment>> getEnvironmentList() =>
      isar.environments.where().findAll();

  // 添加/更新环境
  Future<Environment?> updateEnvironment(Environment item) =>
      isar.writeTxn<Environment?>(() {
        return isar.environments.put(item).then(
              (id) => item..id = id,
            );
      });

  // 移除环境
  Future<bool> removeEnvironment(int id) =>
      isar.writeTxn<bool>(() => isar.environments.delete(id));
}

// 单例调用
final database = DatabaseManage();
