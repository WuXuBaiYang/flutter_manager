import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:provider/provider.dart';

/*
* 设置项子项
* @author wuxubaiyang
* @Time 2023/11/28 11:18
*/
class SettingItem extends StatelessWidget {
  // 设置项下标
  final int index;

  // 别名
  final String label;

  // 内容体
  final Widget? content;

  // 子元素
  final Widget? child;

  const SettingItem({
    super.key,
    required this.index,
    required this.label,
    this.child,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<SettingProvider, int?>(
      selector: (_, provider) => provider.index,
      builder: (_, index, __) {
        return ListTile(
          trailing: child,
          subtitle: content,
          title: Text(label),
          isThreeLine: content != null,
          selected: index == this.index,
        );
      },
    );
  }
}
