import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/model/create_template.dart';
import 'package:jtech_base/jtech_base.dart';

/*
* 从模板创建项目
* @author wuxubaiyang
* @Time 2025/6/18 13:59
*/
class TemplateCreate {
  // 开始创建项目（返回创建项目地址）
  static Future<String?> start(CreateTemplate template) async {
    if (!await checkGit()) throw Exception('未检测到git环境');
    // 检查缓存目录是否存在模板项目，已存在则clone更新，不存在则从github克隆
    final cacheDir = await getApplicationCacheDirectory();
    final templatePath = join(cacheDir.path, Common.templateName);
    if (!await _updateTemplate(templatePath)) {
      throw Exception('模板拉取/更新失败，请重试');
    }
    // 执行模板项目中的创建脚本
    final result = await Process.start(
      join(templatePath, Common.templateCreateScript),
      template.toCommand(),
      runInShell: true,
      workingDirectory: templatePath,
      mode: ProcessStartMode.detached,
    );
    if (await result.exitCode != 0) return null;
    return join(template.targetDir, template.projectName);
  }

  // 更新/拉取最新模板源码
  static Future<bool> _updateTemplate(String templatePath) async {
    final hasCache = await _checkTemplateCache(templatePath);
    // 存在缓存且缓存正确则放弃并更新源码
    // 不存在缓存则克隆源码
    final cmd = hasCache
        ? ['git', 'reset', '--hard', 'HEAD', '&&', 'git', 'fetch', 'origin']
        : ['git', 'clone', Common.templateUrl, templatePath];
    // 如果不存在模板源码则创建目录再克隆
    if (!hasCache) Directory(templatePath).createSync(recursive: true);
    final result = await _execCommand(cmd, workingDirectory: templatePath);
    return result.exitCode == 0;
  }

  // 检查模板项目本地是否已缓存（.git是否存在，git的远程地址是否正确）
  static Future<bool> _checkTemplateCache(String projectPath) async {
    if (!Directory(join(projectPath, '.git')).existsSync()) return false;
    // 检查目标路径项目源是否正确，不匹配需要抛出异常
    final cmd = ['git', 'remote', 'get-url', 'origin'];
    final result = await _execCommand(cmd, workingDirectory: projectPath);
    if (result.exitCode != 0) return false;
    if (result.stdout.trim() != Common.templateUrl) {
      throw Exception('源不匹配，请删除($projectPath)整个目录后重试');
    }
    return true;
  }

  // 执行命令
  static Future<ProcessResult> _execCommand(
    List<String> command, {
    String? workingDirectory,
  }) async {
    return Process.run(
      command[0],
      command.sublist(1),
      runInShell: true,
      stderrEncoding: utf8,
      stdoutEncoding: utf8,
      workingDirectory: workingDirectory,
    );
  }

  // 检查是否存在git
  static Future<bool> checkGit() async {
    try {
      final result = await Process.run('git', ['--version']);
      if (result.exitCode == 0) return true;
    } catch (e) {
      Log.w('未检测到git');
    }
    return false;
  }
}
