import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/common/manage.dart';
import 'package:flutter_manager/database/environment.dart';
import 'package:flutter_manager/database/project.dart';
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
    isar = await Isar.open([
      ProjectSchema,
      EnvironmentSchema,
    ], directory: dir ?? '');
  }

  // 根据环境id获取项目列表
  Future<List<Project>> getProjectsByEnvironmentId(Id id) =>
      isar.projects.where().filter().envIdEqualTo(id).findAll();

  // 获取项目列表
  Future<List<Project>> getProjectList({bool orderDesc = false}) {
    var queryBuilder = isar.projects.where();
    if (orderDesc) return queryBuilder.sortByOrderDesc().findAll();
    return queryBuilder.sortByOrder().findAll();
  }

  // 获取项目数量
  Future<int> get projectCount async => (await getProjectList()).length;

  // 添加/更新项目
  Future<Project?> updateProject(Project item) async {
    final count = await projectCount;
    return isar.writeTxn<Project?>(() {
      return isar.projects.put(item..order = count).then(
            (id) => item..id = id,
          );
    });
  }

  // 更新项目排序
  Future<List<Project>> updateProjects(List<Project> items) =>
      isar.writeTxn<List<Project>>(() {
        return isar.projects.putAll(items).then((_) => items);
      });

  // 移除项目
  Future<bool> removeProject(Id id) =>
      isar.writeTxn<bool>(() => isar.projects.delete(id));

  // 根据id获取环境信息
  Future<Environment?> getEnvironmentById(Id id) =>
      isar.environments.where().idEqualTo(id).findFirst();

  // 获取全部环境列表
  Future<List<Environment>> getEnvironmentList({bool orderDesc = false}) {
    var queryBuilder = isar.environments.where();
    if (orderDesc) return queryBuilder.sortByOrderDesc().findAll();
    return queryBuilder.sortByOrder().findAll();
  }

  // 获取环境数量
  Future<int> get environmentCount async => (await getEnvironmentList()).length;

  // 添加/更新环境
  Future<Environment> updateEnvironment(Environment item) async {
    final count = await environmentCount;
    return isar.writeTxn<Environment>(() {
      return isar.environments.put(item..order = count).then(
            (id) => item..id = id,
          );
    });
  }

  // 更新环境集合
  Future<List<Environment>> updateEnvironments(List<Environment> items) =>
      isar.writeTxn<List<Environment>>(() {
        return isar.environments.putAll(items).then((_) => items);
      });

  // 移除环境
  Future<bool> removeEnvironment(Id id) =>
      isar.writeTxn<bool>(() => isar.environments.delete(id));
}

// 单例调用
final database = DatabaseManage();
