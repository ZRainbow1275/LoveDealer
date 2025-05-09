import 'package:flutter/material.dart';
import '../../app/theme/color_theme.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final bool isLoading;
  final String? tooltip;

  const AppIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40.0,
    this.iconSize = 24.0,
    this.isLoading = false,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? ColorTheme.primaryColor;
    final iColor = iconColor ?? ColorTheme.buttonText;

    final buttonWidget = Material(
      color: bgColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        splashColor: iColor.withOpacity(0.1),
        child: SizedBox(
          height: size,
          width: size,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize * 0.8,
                    height: iconSize * 0.8,
                    child: CircularProgressIndicator(
                      color: iColor,
                      strokeWidth: 2.0,
                    ),
                  )
                : Icon(
                    icon,
                    color: iColor,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}