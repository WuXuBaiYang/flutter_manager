import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_manager/common/common.dart';
import 'package:flutter_manager/model/create_template.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jtech_base/jtech_base.dart';

part 'template.g.dart';

part 'template.freezed.dart';

/*
* 从模板创建项目
* @author wuxubaiyang
* @Time 2025/6/18 13:59
*/
class TemplateCreate {
  // 开始创建项目
  static Future<bool> start(
    CreateTemplate template, {
    ValueChanged<List<CreateStep>>? onCreateStep,
    StreamSink<String>? onLog,
  }) async {
    final progressList = <CreateStep>[];
    updateStep(int index, CreateStep step) {
      progressList.length >= index
          ? progressList.add(step)
          : progressList[index] = step;
      // 将最后一条数据之前的所有数据状态标记为完成
      for (var i = 0; i < index; i++) {
        final item = progressList[i];
        if (item.state == CreateStepState.ongoing) {
          progressList[i] = CreateStep.finish(item.message);
        }
      }
      onCreateStep?.call(progressList);
    }

    // #0-----------检查git环境
    updateStep(0, CreateStep.ongoing('检查git环境'));
    if (!await checkGit()) {
      updateStep(0, CreateStep.error('未检测到git环境'));
      throw Exception('未检测到git环境');
    }
    // #1-----------检查缓存目录是否存在模板项目，已存在则clone更新，不存在则从github克隆
    final cacheDir = await getApplicationCacheDirectory();
    final projectPath = join(cacheDir.path, Common.templateName);
    updateStep(1, CreateStep.ongoing('拉取/更新模板'));
    if (!await _updateTemplate(projectPath)) {
      updateStep(1, CreateStep.error('模板拉取/更新失败，请重试'));
      throw Exception('模板拉取/更新失败，请重试');
    }
    // #2-----------执行模板项目中的创建脚本
    final process = await Process.start(
      join(projectPath, Common.templateCreateScript),
      template.toCommand(),
      runInShell: true,
      workingDirectory: projectPath,
    );
    // 监听脚本执行过程日志
    int index = progressList.length;
    process.stdout.transform(utf8.decoder).listen((data) {
      if (data.startsWith('*st:')) {
        updateStep(index++, CreateStep.ongoing(data.replaceAll('*st:', '')));
      } else if (data.startsWith('*fst:')) {
        updateStep(index++, CreateStep.error(data.replaceAll('*fst:', '')));
      }
      onLog?.add(data);
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      onLog?.add(data);
    });
    return await process.exitCode == 0;
  }

  // 更新/拉取最新模板源码
  static Future<bool> _updateTemplate(String projectPath) async {
    final hasCache = await _checkTemplateCache(projectPath);
    // 存在缓存且缓存正确则放弃并更新源码
    // 不存在缓存则克隆源码
    final cmd = hasCache
        ? ['git', 'reset', '--hard', 'HEAD', '&&', 'git', 'fetch', 'origin']
        : ['git', 'clone', Common.templateUrl, projectPath];
    final result = await _execCommand(cmd, workingDirectory: projectPath);
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

// 项目创建步骤
@freezed
abstract class CreateStep with _$CreateStep {
  const CreateStep._();

  const factory CreateStep({
    required CreateStepState state,
    required String message,
  }) = _CreateStep;

  factory CreateStep.fromJson(Map<String, dynamic> json) =>
      _$CreateStepFromJson(json);

  // 进行中
  static CreateStep ongoing(String message) =>
      CreateStep(state: CreateStepState.ongoing, message: message);

  // 完成
  static CreateStep finish(String message) =>
      CreateStep(state: CreateStepState.finish, message: message);

  // 错误
  static CreateStep error(String message) =>
      CreateStep(state: CreateStepState.error, message: message);
}

// 创建步骤状态
enum CreateStepState { ongoing, finish, error }
