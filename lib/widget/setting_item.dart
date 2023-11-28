import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:provider/provider.dart';

/*
* 设置项子项
* @author wuxubaiyang
* @Time 2023/11/28 11:18
*/
class SettingItem extends StatelessWidget {
  // 别名
  final String label;

  // 内容体
  final Widget? content;

  // 子元素
  final Widget? child;

  const SettingItem({
    required super.key,
    required this.label,
    this.child,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<SettingProvider, Key?>(
      selector: (_, provider) => provider.selectedKey,
      builder: (_, key, __) {
        return ListTile(
          trailing: child,
          subtitle: content,
          title: Text(label),
          selected: key == super.key,
          isThreeLine: content != null,
        );
      },
    );
  }
}
