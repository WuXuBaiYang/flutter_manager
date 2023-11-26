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
  Future<List<Environment>> getEnvironments() async =>
      _environments ??= await database.getEnvironmentList();

  // 导入环境变量
  Future<Environment?> importEnvironment(String path) async {
    dynamic result = await EnvironmentTool.getEnvironmentInfo(path);
    if (result == null) throw Exception('查询flutter信息失败');
    result = await updateEnvironment(result);
    if (result == null) throw Exception('写入flutter信息失败');
    return result;
  }

  // 添加环境变量
  Future<Environment?> updateEnvironment(Environment item) async {
    final result = await database.updateEnvironment(item);
    _environments = null;
    notifyListeners();
    return result;
  }
}
