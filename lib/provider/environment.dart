import 'dart:io';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/model/database/environment.dart';
import 'package:flutter_manager/tool/project/environment.dart';

/*
* 环境变量提供者
* @author wuxubaiyang
* @Time 2023/11/26 13:29
*/
class EnvironmentProvider extends BaseProvider {
  // 环境变量集合
  List<Environment> environments = [];

  EnvironmentProvider() {
    // 初始化加载环境列表
    loadEnvironmentList();
  }

  // 获取最新的环境变量集合
  Future<List<Environment>> loadEnvironmentList() async {
    environments = await database.getEnvironmentList();
    notifyListeners();
    return environments;
  }

  // 导入环境变量
  Future<Environment> importEnvironment(String path) async {
    dynamic result = await EnvironmentTool.getEnvironmentInfo(path);
    if (result == null) throw Exception('查询flutter信息失败');
    result = await updateEnvironment(result);
    if (result == null) throw Exception('写入flutter信息失败');
    return result;
  }

  // 导入压缩包的环境变量
  Future<Environment> importArchiveEnvironment(
      String archiveFile, String savePath) async {
    // await extractFileToDisk(archiveFile, savePath, asyncWrite: true);
    final dir = Directory(savePath);
    final tmp = dir.listSync();
    if (tmp.length <= 1) savePath = tmp.first.path;
    return importEnvironment(savePath);
  }

  // 刷新环境变量
  Future<Environment> refreshEnvironment(Environment item) async {
    dynamic result = await EnvironmentTool.getEnvironmentInfo(item.path);
    if (result == null) throw Exception('查询flutter信息失败');
    result = await updateEnvironment(result..id = item.id);
    if (result == null) throw Exception('写入flutter信息失败');
    return result;
  }

  // 添加环境变量
  Future<Environment?> updateEnvironment(Environment item) async {
    final result = await database.updateEnvironment(item);
    await loadEnvironmentList();
    return result;
  }

  // 移除环境变量
  Future<bool> removeEnvironment(Environment item) async {
    final result = await database.removeEnvironment(item.id);
    await loadEnvironmentList();
    return result;
  }
}
