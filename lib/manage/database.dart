import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/common/manage.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/model/database/project.dart';
import 'package:flutter_manager/tool/file.dart';
import 'package:flutter_manager/tool/tool.dart';
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
  Future<Project?> updateProject(Project item) {
    final length = isar.projects
        .where()
        .filter()
        .pinnedEqualTo(item.pinned)
        .sortByOrderDesc()
        .findAllSync()
        .length;
    return isar.writeTxn<Project?>(() {
      return isar.projects.put(item..order = length).then(
            (id) => item..id = id,
          );
    });
  }

  // 更新项目排序
  Future<void> reorderProject(Project item, int newOrder) {
    // 根据pinned取出全部项目
    var projects = isar.projects
        .where()
        .filter()
        .pinnedEqualTo(item.pinned)
        .sortByOrderDesc()
        .findAllSync();
    final length = projects.length;
    return isar.writeTxn<void>(() {
      // 交换目标项目的位置并重新设置order
      projects = swap(projects, projects.indexOf(item), newOrder);
      projects.asMap().forEach((i, e) => e.order = length - i);
      // 批量更新
      return isar.projects.putAll(projects);
    });
  }

  // 移除项目
  Future<bool> removeProject(Id id) =>
      isar.writeTxn<bool>(() => isar.projects.delete(id));

  // 根据id获取环境信息
  Future<Environment?> getEnvironmentById(Id id) =>
      isar.environments.where().idEqualTo(id).findFirst();

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
  Future<bool> removeEnvironment(Id id) =>
      isar.writeTxn<bool>(() => isar.environments.delete(id));
}

// 单例调用
final database = DatabaseManage();
