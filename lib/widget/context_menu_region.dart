import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

/*
* 自定义上下文菜单区域
* @author wuxubaiyang
* @Time 2023/11/28 9:16
*/
class CustomContextMenuRegion extends StatelessWidget {
  final ContextMenu contextMenu;
  final Widget child;
  final void Function(dynamic value)? onItemSelected;

  const CustomContextMenuRegion({
    super.key,
    required this.contextMenu,
    required this.child,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    Offset mousePosition = Offset.zero;

    return Listener(
      onPointerDown: (event) {
        mousePosition = event.position;
      },
      child: GestureDetector(
        onSecondaryTap: () => _showMenu(context, mousePosition),
        child: child,
      ),
    );
  }

  void _showMenu(BuildContext context, Offset mousePosition) async {
    final menu =
        contextMenu.copyWith(position: contextMenu.position ?? mousePosition);
    final value = await showContextMenu(context, contextMenu: menu);
    onItemSelected?.call(value);
  }
}
