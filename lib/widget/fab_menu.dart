import 'package:flutter/material.dart';

/*
* fab菜单按钮
* @author wuxubaiyang
* @Time 2025/6/17 11:02
*/
class FabMenuButton extends StatefulWidget {
  // 菜单元素集合
  final List<Widget> items;

  // 按钮元素
  final Widget child;

  // 动画时长
  final Duration duration;

  // 约束
  final BoxConstraints constraints;

  // 颜色
  final Color? color;

  // 菜单颜色
  final Color? menuColor;

  const FabMenuButton({
    super.key,
    required this.items,
    required this.child,
    this.color,
    this.menuColor,
    this.duration = const Duration(milliseconds: 180),
    this.constraints = const BoxConstraints(
      maxWidth: 140,
      maxHeight: 240,
      minWidth: 50,
      minHeight: 50,
    ),
  });

  @override
  State<FabMenuButton> createState() => _FabMenuButtonState();
}

class _FabMenuButtonState extends State<FabMenuButton> {
  // 鼠标是否悬停
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primaryContainer;
    final color = widget.color ?? primaryColor;
    final menuColor = widget.menuColor ?? primaryColor;
    return MouseRegion(
      onExit: (_) => updateHover(false),
      onEnter: (_) => updateHover(true),
      child: ConstrainedBox(
        constraints: widget.constraints,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          color: isHover ? menuColor : color,
          child: AnimatedSize(
            duration: widget.duration,
            child: AnimatedSwitcher(
              duration: widget.duration,
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  // 构建子元素内容
  Widget _buildContent() {
    if (!isHover) return widget.child;
    return Column(mainAxisSize: MainAxisSize.min, children: widget.items);
  }

  // 更新悬停状态
  void updateHover(bool isHover) {
    setState(() => this.isHover = isHover);
  }
}
