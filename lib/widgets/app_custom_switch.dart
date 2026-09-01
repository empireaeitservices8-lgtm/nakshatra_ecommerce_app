import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class AppCustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;

  const AppCustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final switchWidget = Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AppPalette.emerald,
      activeTrackColor: (activeColor ?? AppPalette.emerald).withOpacity(0.35),
      inactiveThumbColor: inactiveColor ?? Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade200,
    );

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          switchWidget,
        ],
      );
    }

    return switchWidget;
  }
}
