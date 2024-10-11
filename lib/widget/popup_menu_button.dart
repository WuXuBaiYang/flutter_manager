import 'package:flutter/material.dart';

/*
* 自定义PopupMenuButton
* @author wuxubaiyang
* @Time 2023/12/6 8:48
*/
class CustomPopupMenuButton<T> extends PopupMenuButton<T> {
  const CustomPopupMenuButton.filled({
    super.key,
    required super.itemBuilder,
    super.initialValue,
    super.onOpened,
    super.onSelected,
    super.onCanceled,
    super.tooltip,
    super.elevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.padding = const EdgeInsets.all(8.0),
    super.child,
    super.splashRadius,
    super.icon,
    super.iconSize,
    super.offset = Offset.zero,
    super.enabled = true,
    super.shape,
    super.color,
    super.iconColor,
    super.enableFeedback,
    super.constraints,
    super.position,
    super.clipBehavior = Clip.none,
  });

  @override
  PopupMenuButtonState<T> createState() => _CustomPopupMenuButtonState<T>();
}

/*
* 自定义PopupMenuButton-状态
* @author wuxubaiyang
* @Time 2023/12/6 8:48
*/
class _CustomPopupMenuButtonState<T> extends PopupMenuButtonState<T> {
  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final bool enableFeedback = widget.enableFeedback ??
        PopupMenuTheme.of(context).enableFeedback ??
        true;

    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null) {
      return Tooltip(
        message:
            widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          onTap: widget.enabled ? showButtonMenu : null,
          canRequestFocus: _canRequestFocus,
          radius: widget.splashRadius,
          enableFeedback: enableFeedback,
          child: widget.child,
        ),
      );
    }

    return IconButton.filled(
      icon: widget.icon ?? Icon(Icons.adaptive.more),
      padding: widget.padding,
      splashRadius: widget.splashRadius,
      visualDensity: VisualDensity.compact,
      iconSize: widget.iconSize ?? popupMenuTheme.iconSize ?? iconTheme.size,
      tooltip:
          widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: widget.enabled ? showButtonMenu : null,
      enableFeedback: enableFeedback,
    );
  }

  bool get _canRequestFocus {
    final NavigationMode mode =
        MediaQuery.maybeNavigationModeOf(context) ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled;
      case NavigationMode.directional:
        return true;
    }
  }
}
