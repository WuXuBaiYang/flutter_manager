import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
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
  List<Environment>? _environments;

  // 获取环境变量集合
  List<Environment> get environments => _environments ?? [];

  // 判断是否存在环境信息
  bool get hasEnvironment => environments.isNotEmpty;

  EnvironmentProvider() {
    initialize();
  }

  // 初始化加载环境变量
  Future<List<Environment>> initialize() async {
    _environments = await database.getEnvironmentList();
    notifyListeners();
    return environments;
  }

  // 导入环境变量
  Future<Environment> import(String path) async {
    dynamic result = await EnvironmentTool.getEnvironmentInfo(path);
    if (result == null) throw Exception('查询flutter信息失败');
    result = await update(result);
    if (result == null) throw Exception('写入flutter信息失败');
    return result;
  }

  // 导入压缩包的环境变量
  Future<Environment> importArchive(String archiveFile, String savePath) async {
    await extractFileToDisk(archiveFile, savePath, asyncWrite: true);
    final dir = Directory(savePath);
    final tmp = dir.listSync();
    if (tmp.length <= 1) savePath = tmp.first.path;
    return import(savePath);
  }

  // 刷新环境变量
  Future<Environment> refresh(Environment item) async {
    dynamic result = await EnvironmentTool.getEnvironmentInfo(item.path);
    if (result == null) throw Exception('查询flutter信息失败');
    result = await update(result..id = item.id);
    if (result == null) throw Exception('写入flutter信息失败');
    return result;
  }

  // 添加环境变量
  Future<Environment?> update(Environment item) async {
    final result = await database.updateEnvironment(item);
    await initialize();
    return result;
  }

  // 移除环境变量
  Future<bool> remove(Environment item) async {
    final result = await database.removeEnvironment(item.id);
    await initialize();
    return result;
  }

  // 验证是否可移除环境变量
  Future<String?> removeValidator(Environment item) async {
    final result = await database.getProjectsByEnvironmentId(item.id);
    if (result.isEmpty) return null;
    final length = result.length;
    final label = result.first.label;
    return '${length > 1 ? '$label 等 ${length - 1} 个' : label}项目正在依赖该环境，无法移除';
  }
}
