import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter_manager/database/database.dart';
import 'package:flutter_manager/database/model/environment.dart';
import 'package:flutter_manager/model/env_package.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 环境变量提供者
* @author wuxubaiyang
* @Time 2023/11/26 13:29
*/
class EnvironmentProvider extends BaseProvider {
  EnvironmentProvider(super.context);

  // 环境变量集合
  late List<Environment> _environments = database.getEnvList(desc: true);

  // 获取环境变量集合
  List<Environment> get environments => _environments;

  // 判断是否存在环境信息
  bool get hasEnvironment => _environments.isNotEmpty;

  // 导入环境变量
  Future<Environment> import(String path) async {
    final result = await EnvironmentTool.getInfo(path);
    if (result == null) throw Exception('查询flutter信息失败');
    return update(result);
  }

  // 导入压缩包的环境变量
  Future<Environment?> importArchive(EnvironmentPackage package) async {
    if (!package.canImport) return null;
    var buildPath = package.buildPath;
    await extractFileToDisk(
      package.downloadPath!,
      buildPath!,
    );
    final list = Directory(buildPath).listSync();
    return import(list.length <= 1 ? list.first.path : buildPath);
  }

  // 刷新环境变量
  Future<Environment> refresh(Environment env) async {
    final result = await EnvironmentTool.getInfo(env.path);
    if (result == null) throw Exception('查询flutter信息失败');
    return update(result..id = env.id);
  }

  // 添加环境变量
  Future<Environment> update(Environment item) async {
    final result = await database.updateEnv(item);
    reload();
    return result;
  }

  // 移除环境变量
  bool remove(Environment item) {
    final result = database.removeEnv(item.id);
    if (result) reload();
    return result;
  }

  // 验证是否可移除环境变量
  String? removeValidator(Environment item) {
    final result = database.getProjectsByEnvironmentId(item.id);
    if (result.isEmpty) return null;
    final length = result.length;
    final label = result.first.label;
    return '${length > 1 ? '$label 等 ${length - 1} 个' : label} 项目正在依赖该环境';
  }

  // 环境重排序
  Future<void> reorder(int oldIndex, int newIndex) async {
    final temp = environments.reversed.toList().swapReorder(oldIndex, newIndex);
    temp.asMap().forEach((i, e) => e.order = i);
    temp.sort((a, b) => a.order.compareTo(b.order));
    _environments = temp.reversed.toList();
    notifyListeners();
    await database.updateEnvs(temp);
  }

  // 重新加载环境变量列表
  void reload() {
    _environments = database.getEnvList(desc: true);
    notifyListeners();
  }
}
