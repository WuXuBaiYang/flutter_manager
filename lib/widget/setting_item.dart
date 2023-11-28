import 'package:flutter/material.dart';
import 'package:flutter_manager/provider/setting.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

/*
* 设置项子项
* @author wuxubaiyang
* @Time 2023/11/28 11:18
*/
class SettingItem extends StatelessWidget {
  // 设置项下标
  final SettingIndexTuple indexTuple;

  // 子元素
  final Widget child;

  const SettingItem({
    super.key,
    required this.indexTuple,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<SettingProvider, SettingIndexTuple?>(
      selector: (_, provider) => provider.indexTuple,
      builder: (_, tuple, __) {
        return Shimmer.fromColors(
          enabled: _enabledShimmer(tuple),
          baseColor: Theme.of(context).primaryColor,
          highlightColor: Theme.of(context).highlightColor,
          period: context.read<SettingProvider>().clearDelay,
          child: child,
        );
      },
    );
  }

  // 验证是否选中
  bool _enabledShimmer(SettingIndexTuple? tuple) {
    if (tuple == null) return false;
    return tuple.index == indexTuple.index &&
        tuple.subIndexs.any(indexTuple.subIndexs.contains);
  }
}
