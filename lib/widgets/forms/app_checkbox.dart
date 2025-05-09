import 'package:flutter/material.dart';
import '../../app/theme/color_theme.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool enabled;
  final Widget? customLabel;

  const AppCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
    this.customLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: enabled ? (newValue) => onChanged(newValue ?? false) : null,
                activeColor: ColorTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            const SizedBox(width: 12),
            customLabel ??
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? ColorTheme.textPrimary : ColorTheme.textHint,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
} 