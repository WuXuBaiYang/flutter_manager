import 'dart:io';
import 'package:flutter_manager/tool/image.dart';
import 'package:flutter_manager/tool/tool.dart';
import 'package:xml/xml.dart';
import 'platform.dart';

// android平台信息元组
typedef AndroidPlatformInfoTuple = ();

/*
* Android平台工具类
* @author wuxubaiyang
* @Time 2023/11/29 14:55
*/
class AndroidPlatformTool extends PlatformTool<AndroidPlatformInfoTuple> {
  @override
  PlatformType get platform => PlatformType.android;

  @override
  String keyFilePath = 'app/build.gradle';

  // AndroidManifest.xml相对路径
  final String _manifestPath = 'app/src/main/AndroidManifest.xml';

  // 资源目录
  final String _resPath = 'app/src/main/res';

  // package匹配真正则
  final _packageRegExp = RegExp(r'applicationId "(.*)"');

  // 读取manifest文件信息
  Future<XmlDocument> _getManifestDocument(String projectPath) =>
      readPlatformFileXml(projectPath, _manifestPath);

  // 获取manifest文件fragment
  Future<XmlDocumentFragment> _getManifestFragment(String projectPath) =>
      readPlatformFileXmlFragment(projectPath, _manifestPath);

  // 获取build.gradle文件内容
  Future<String> _getBuildGradleContent(String projectPath) =>
      readPlatformFile(projectPath, keyFilePath);

  @override
  Future<PlatformInfoTuple<AndroidPlatformInfoTuple>?> getPlatformInfo(
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
  Future<List<PlatformLogoTuple>?> getLogos(String projectPath) async {
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
    final result = <PlatformLogoTuple>[];
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
    // TODO:
    return super.setPackage(projectPath, package);
  }

  @override
  Future<List<PlatformPermissionTuple>?> getPermissions(
      String projectPath) async {
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
      String projectPath, List<PlatformPermissionTuple> permissions) async {
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
}
