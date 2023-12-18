import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter_manager/common/provider.dart';
import 'package:flutter_manager/manage/database.dart';
import 'package:flutter_manager/database/environment.dart';
import 'package:flutter_manager/tool/project/environment.dart';
import 'package:flutter_manager/tool/tool.dart';

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

  EnvironmentProvider(super.context) {
    initialize();
  }

  // 初始化加载环境变量
  Future<void> initialize() async {
    _environments = await database.getEnvironmentList(
      orderDesc: true,
    );
    notifyListeners();
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
  Future<void> remove(Environment item) async {
    if (!await database.removeEnvironment(item.id)) return;
    return initialize();
  }

  // 验证是否可移除环境变量
  Future<String?> removeValidator(Environment item) async {
    final result = await database.getProjectsByEnvironmentId(item.id);
    if (result.isEmpty) return null;
    final length = result.length;
    final label = result.first.label;
    return '${length > 1 ? '$label 等 ${length - 1} 个' : label} 项目正在依赖该环境';
  }

  // 环境重排序
  Future<void> reorder(int oldIndex, int newIndex) async {
    final temp = environments.reversed.toList().swap(oldIndex, newIndex);
    temp.asMap().forEach((i, e) => e.order = i);
    temp.sort((a, b) => a.order.compareTo(b.order));
    _environments = temp.reversed.toList();
    notifyListeners();
    await database.updateEnvironments(temp);
  }
}
