import 'package:flutter/material.dart';
import '../../app/theme/color_theme.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? icon;
  final bool iconAfterText;

  const AppTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    this.icon,
    this.iconAfterText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorToUse = textColor ?? ColorTheme.primaryColor;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorToUse,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: colorToUse,
                strokeWidth: 2.0,
              ),
            )
          : icon == null
              ? Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: colorToUse,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: iconAfterText
                      ? [
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: fontWeight,
                              color: colorToUse,
                            ),
                          ),
                          const SizedBox(width: 4),
                          icon!,
                        ]
                      : [
                          icon!,
                          const SizedBox(width: 4),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: fontWeight,
                              color: colorToUse,
                            ),
                          ),
                        ],
                ),
    );
  }
} 