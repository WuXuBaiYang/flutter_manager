import 'package:flutter/material.dart';
import 'package:flutter_manager/model/environment.dart';

/*
* 环境标签组件
* @author wuxubaiyang
* @Time 2023/11/28 18:57
*/
class EnvironmentBadge extends StatelessWidget {
  // 环境信息
  final Environment environment;

  const EnvironmentBadge({
    super.key,
    required this.environment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(children: [
        const FlutterLogo(size: 12),
        const SizedBox(width: 6),
        Text(
          environment.version,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ]),
    );
  }
}
