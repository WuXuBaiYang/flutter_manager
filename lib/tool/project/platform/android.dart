import 'dart:io';
import 'package:flutter_manager/tool/image.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:jtech_base/jtech_base.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

// android平台信息元组
typedef AndroidPlatformInfo = ();

// android签名生成工具表单数据
typedef AndroidSignKeyForm = ({
  String keytoolPath,
  String path,
  String alias,
  String storepass,
  String keypass,
  String keyAlg,
  int keySize,
  int validity,
  String dNameCN,
  String dNameOU,
  String dNameO,
  String dNameL,
  String dNameT,
  String dNameC,
});

/*
* Android平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:55
*/
class AndroidPlatformTool extends PlatformTool<AndroidPlatformInfo> {
  // build.gradle(.kts)路径
  String _buildGradlePath = 'app/build.gradle';

  // AndroidManifest.xml相对路径
  final String _manifestPath = 'app/src/main/AndroidManifest.xml';

  // 资源目录
  final String _resPath = 'app/src/main/res';

  // package匹配正则
  late final _packageRegExp = RegExp(
      _isBuildGradleKts ? r'applicationId = "(.*)"' : r'applicationId "(.*)"');

  // 匹配java路径
  final _jdkRegExp = RegExp(r'.*jdk(.*)bin');

  // 判断当前得build.gradle是否为kts版本
  bool get _isBuildGradleKts => _buildGradlePath.endsWith('.kts');

  // 读取manifest文件信息
  Future<XmlDocument> _getManifestDocument(String projectPath) =>
      readPlatformFileXml(projectPath, _manifestPath);

  // 获取manifest文件fragment
  Future<XmlDocumentFragment> _getManifestFragment(String projectPath) =>
      readPlatformFileXmlFragment(projectPath, _manifestPath);

  // 获取build.gradle(.kts)文件内容
  Future<String> _getBuildGradleContent(String projectPath) =>
      readPlatformFile(projectPath, _buildGradlePath);

  @override
  PlatformType get platform => PlatformType.android;

  @override
  bool isPathAvailable(String projectPath) {
    final path = join(getPlatformPath(projectPath), 'app/build.gradle');
    return [File('$path.kts'), File(path)].any((e) {
      final exists = e.existsSync();
      if (exists) _buildGradlePath = e.path;
      return exists;
    });
  }

  @override
  Future<PlatformInfo<AndroidPlatformInfo>?> getPlatformInfo(
      String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (
      path: getPlatformPath(projectPath),
      label: await getLabel(projectPath) ?? '',
      package: await getPackage(projectPath) ?? '',
      logos: await getLogos(projectPath) ?? [],
      permissions: await getPermissions(projectPath) ?? [],
      info: (),
    );
  }

  @override
  Future<String?> getLabel(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    return (await _getManifestDocument(projectPath))
        .getElement('manifest')
        ?.getElement('application')
        ?.getAttribute('android:label');
  }

  @override
  Future<bool> setLabel(String projectPath, String label) async {
    if (!isPathAvailable(projectPath)) return false;
    return writePlatformFileXml(
      projectPath,
      _manifestPath,
      (await _getManifestFragment(projectPath))
        ..getElement('manifest')
            ?.getElement('application')
            ?.setAttribute('android:label', label),
    );
  }

  @override
  Future<List<PlatformLogo>?> getLogos(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    // 从manifest中获取logo的路径信息
    final iconPath = (await _getManifestDocument(projectPath))
        .getElement('manifest')
        ?.getElement('application')
        ?.getAttribute('android:icon')
        ?.replaceAll('@', '');
    if (iconPath?.isEmpty ?? true) return null;
    // 遍历res下所有文件并过滤出目标图片
    final parentKey = iconPath!.split('/').first;
    final iconRegExp = RegExp(iconPath.replaceAll('/', '|'));
    final dir = Directory(getPlatformFilePath(projectPath, _resPath));
    // 移除不符合条件的文件
    final result = <PlatformLogo>[];
    for (final file in dir.listSync(recursive: true)) {
      final parent = file.parent.path, path = file.path;
      if (!parent.contains(parentKey) || !path.contains(iconRegExp)) continue;
      final name = parent.substring(parent.lastIndexOf('-') + 1);
      final size = await ImageTool.getSize(path);
      if (size == null) continue;
      result.add((name: name, path: path, size: size));
    }
    return result;
  }

  @override
  Future<String?> getPackage(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final content = await _getBuildGradleContent(projectPath);
    return content.regFirstGroup(_packageRegExp.pattern, 1);
  }

  @override
  Future<bool> setPackage(String projectPath, String package) async {
    if (!isPathAvailable(projectPath)) return false;
    var content = await _getBuildGradleContent(projectPath);
    final temp = _packageRegExp.pattern.replaceFirst('(.*)', package);
    content = content.replaceFirst(_packageRegExp, temp.replaceAll('\\', ''));
    return writePlatformFile(projectPath, _buildGradlePath, content);
  }

  @override
  Future<List<PlatformPermission>?> getPermissions(String projectPath) async {
    if (!isPathAvailable(projectPath)) return null;
    final permissions = (await _getManifestDocument(projectPath))
        .getElement('manifest')
        ?.findElements('uses-permission')
        .map((e) => e.getAttribute('android:name')?.split('.').lastOrNull);
    if (permissions?.isEmpty ?? true) return null;
    return (await getFullPermissions())
        ?.where((e) => permissions!.contains(e.value))
        .toList(growable: false);
  }

  @override
  Future<bool> setPermissions(
      String projectPath, List<PlatformPermission> permissions) async {
    if (!isPathAvailable(projectPath)) return false;
    final fragment = await _getManifestFragment(projectPath);
    final fullPermissions = (await getFullPermissions())?.map((e) => e.value);
    if (fullPermissions == null) return false;
    fragment.getElement('manifest')?.children
      ?..removeWhere((e) =>
          e is XmlElement &&
          e.localName.contains('uses-permission') &&
          fullPermissions.contains(
            e.getAttribute('android:name')?.split('.').lastOrNull,
          ))
      ..insertAll(0, permissions.map((e) {
        return XmlElement(XmlName('uses-permission'), [
          XmlAttribute(XmlName('android:name'), 'android.permission.${e.value}')
        ]);
      }));
    return writePlatformFileXml(projectPath, _manifestPath, fragment);
  }

  // 获取签名工具路径
  Future<String?> getJavaKeyToolPath() async {
    final java = Platform.environment['JAVA_HOME'] ??
        Platform.environment['PATH']
            ?.split(';')
            .firstWhere(_jdkRegExp.hasMatch, orElse: () => '');
    if (java == null || java.isEmpty) return null;
    return join(java, java.contains('bin') ? '' : 'bin');
  }

  // 生成android端签名
  Future<bool> genSignKey(AndroidSignKeyForm form) async {
    final arguments = [
      '-genkey',
      '-v',
      '-keystore ${join(form.path, form.alias)}.jks',
      '-alias ${form.alias}',
      '-keyalg ${form.keyAlg}',
      '-keysize ${form.keySize}',
      '-validity ${form.validity}',
      '-storepass ${form.storepass}',
      '-keypass ${form.keypass}',
      '-dname "CN=${form.dNameCN},OU=${form.dNameOU},O=${form.dNameO}, '
          'L=${form.dNameL},T=${form.dNameT},C=${form.dNameC}"',
    ];
    final command = 'keytool ${arguments.join(' ')}';
    final result = await Process.run(command, [],
        runInShell: true, workingDirectory: form.keytoolPath);
    return result.exitCode == 0;
  }
}
