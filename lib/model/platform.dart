import 'package:flutter/foundation.dart';
import 'package:flutter_manager/common/model.dart';
import 'package:flutter_manager/tool/project/platform/platform.dart';

/*
* 平台信息基类
* @author wuxubaiyang
* @Time 2023/12/4 10:33
*/
abstract class PlatformInfo extends BaseModel {
  // 路径
  final String path;

  // 别名
  final String label;

  // 图标
  final List<PlatformLogoTuple> logo;

  PlatformInfo({
    required this.path,
    required this.label,
    required this.logo,
  });
}

/*
* android 平台信息类
* @author wuxubaiyang
* @Time 2023/12/4 10:35
*/
class AndroidPlatformInfo extends PlatformInfo {
  AndroidPlatformInfo({
    required super.path,
    required super.label,
    required super.logo,
  });

  AndroidPlatformInfo copyWith({
    String? path,
    String? label,
    List<PlatformLogoTuple>? logo,
  }) {
    return AndroidPlatformInfo(
      path: path ?? this.path,
      label: label ?? this.label,
      logo: logo ?? this.logo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AndroidPlatformInfo &&
        other.path == path &&
        other.label == label &&
        listEquals(other.logo, logo);
  }

  @override
  int get hashCode => path.hashCode ^ label.hashCode ^ logo.hashCode;
}

/*
* ios 平台信息类
* @author wuxubaiyang
* @Time 2023/12/4 10:35
*/
class IosPlatformInfo extends PlatformInfo {
  IosPlatformInfo({
    required super.path,
    required super.label,
    required super.logo,
  });

  IosPlatformInfo copyWith({
    String? path,
    String? label,
    List<PlatformLogoTuple>? logo,
  }) {
    return IosPlatformInfo(
      path: path ?? this.path,
      label: label ?? this.label,
      logo: logo ?? this.logo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IosPlatformInfo &&
        other.path == path &&
        other.label == label &&
        listEquals(other.logo, logo);
  }

  @override
  int get hashCode => path.hashCode ^ label.hashCode ^ logo.hashCode;
}

/*
* web 平台信息类
* @author wuxubaiyang
* @Time 2023/12/4 10:36
*/
class WebPlatformInfo extends PlatformInfo {
  WebPlatformInfo({
    required super.path,
    required super.label,
    required super.logo,
  });

  WebPlatformInfo copyWith({
    String? path,
    String? label,
    List<PlatformLogoTuple>? logo,
  }) {
    return WebPlatformInfo(
      path: path ?? this.path,
      label: label ?? this.label,
      logo: logo ?? this.logo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebPlatformInfo &&
        other.path == path &&
        other.label == label &&
        listEquals(other.logo, logo);
  }

  @override
  int get hashCode => path.hashCode ^ label.hashCode ^ logo.hashCode;
}

/*
* windows 平台信息类
* @author wuxubaiyang
* @Time 2023/12/4 10:36
*/
class WindowsPlatformInfo extends PlatformInfo {
  WindowsPlatformInfo({
    required super.path,
    required super.label,
    required super.logo,
  });

  WindowsPlatformInfo copyWith({
    String? path,
    String? label,
    List<PlatformLogoTuple>? logo,
  }) {
    return WindowsPlatformInfo(
      path: path ?? this.path,
      label: label ?? this.label,
      logo: logo ?? this.logo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WindowsPlatformInfo &&
        other.path == path &&
        other.label == label &&
        listEquals(other.logo, logo);
  }

  @override
  int get hashCode => path.hashCode ^ label.hashCode ^ logo.hashCode;
}

/*
* macos 平台信息类
* @author wuxubaiyang
* @Time 2023/12/4 10:35
*/
class MacosPlatformInfo extends PlatformInfo {
  MacosPlatformInfo({
    required super.path,
    required super.label,
    required super.logo,
  });

  MacosPlatformInfo copyWith({
    String? path,
    String? label,
    List<PlatformLogoTuple>? logo,
  }) {
    return MacosPlatformInfo(
      path: path ?? this.path,
      label: label ?? this.label,
      logo: logo ?? this.logo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MacosPlatformInfo &&
        other.path == path &&
        other.label == label &&
        listEquals(other.logo, logo);
  }

  @override
  int get hashCode => path.hashCode ^ label.hashCode ^ logo.hashCode;
}

/*
* linux 平台信息类
* @author wuxubaiyang
* @Time 2023/12/4 10:36
*/
class LinuxPlatformInfo extends PlatformInfo {
  LinuxPlatformInfo({
    required super.path,
    required super.label,
    required super.logo,
  });

  LinuxPlatformInfo copyWith({
    String? path,
    String? label,
    List<PlatformLogoTuple>? logo,
  }) {
    return LinuxPlatformInfo(
      path: path ?? this.path,
      label: label ?? this.label,
      logo: logo ?? this.logo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MacosPlatformInfo &&
        other.path == path &&
        other.label == label &&
        listEquals(other.logo, logo);
  }

  @override
  int get hashCode => path.hashCode ^ label.hashCode ^ logo.hashCode;
}
