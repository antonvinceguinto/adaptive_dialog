import 'package:adaptive_dialog/src/action_callback.dart';
import 'package:adaptive_dialog/src/modal_action_sheet/sheet_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Used for specifying showAlertDialog's actions.
@immutable
class AlertDialogAction<T> {
  const AlertDialogAction({
    required this.key,
    required this.label,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.textStyle = const TextStyle(),
  });

  final T key;
  final String label;

  /// Make font weight to bold(Only works for CupertinoStyle).
  final bool isDefaultAction;

  /// Make font color to destructive/error color(red).
  final bool isDestructiveAction;

  /// Change textStyle to another from default.
  ///
  /// Recommended to keep null.
  final TextStyle textStyle;
}

extension AlertDialogActionEx<T> on AlertDialogAction<T> {
  Widget convertToIOSDialogAction({
    required ActionCallback<T> onPressed,
  }) {
    // Custom orange color for the theme
    const Color customOrangeColor = Color(0xFFFF5D31);
    
    // Check if we have a custom color in textStyle
    final bool hasCustomColor = textStyle.color != null;
    
    // Determine the final text style with proper color priority:
    // 1. If destructive action -> use red
    // 2. If custom color in textStyle -> use that
    // 3. Otherwise -> use orange theme color
    TextStyle finalTextStyle = textStyle;
    
    if (isDestructiveAction) {
      // Destructive actions should remain red
      finalTextStyle = textStyle.copyWith(color: CupertinoColors.destructiveRed);
    } else if (!hasCustomColor) {
      // Apply orange color only if no custom color is specified
      finalTextStyle = textStyle.copyWith(color: customOrangeColor);
    }
    
    // Don't use isDestructiveAction flag if we're handling colors manually
    // This prevents CupertinoDialogAction from overriding our custom styles
    return CupertinoDialogAction(
      isDefaultAction: isDefaultAction,
      isDestructiveAction: false, // Handle colors manually via textStyle
      textStyle: finalTextStyle,
      onPressed: () => onPressed(key),
      child: Text(label),
    );
  }

  Widget convertToMacOSDialogAction({
    required ActionCallback<T> onPressed,
  }) {
    return PushButton(
      controlSize: ControlSize.large,
      secondary: isDestructiveAction || !isDefaultAction,
      onPressed: () => onPressed(key),
      child: Text(
        label,
        style: isDestructiveAction
            ? textStyle.copyWith(color: CupertinoColors.destructiveRed)
            : textStyle,
      ),
    );
  }

  Widget convertToMaterialDialogAction({
    required ActionCallback<T> onPressed,
    required Color destructiveColor,
    required bool fullyCapitalized,
  }) {
    // For Material, properly merge the destructive color with the custom textStyle
    TextStyle finalTextStyle = textStyle;
    if (isDestructiveAction) {
      finalTextStyle = textStyle.copyWith(color: destructiveColor);
    }
    
    return TextButton(
      child: Text(
        fullyCapitalized ? label.toUpperCase() : label,
        style: finalTextStyle,
      ),
      onPressed: () => onPressed(key),
    );
  }
}

extension AlertDialogActionListEx<T> on List<AlertDialogAction<T>> {
  List<SheetAction<T>> convertToSheetActions() =>
      where((a) => a.key != OkCancelResult.cancel)
          .map(
            (a) => SheetAction(
              key: a.key,
              label: a.label,
              isDefaultAction: a.isDefaultAction,
              isDestructiveAction: a.isDestructiveAction,
              textStyle: a.textStyle,
            ),
          )
          .toList();

  String? findCancelLabel() {
    try {
      return firstWhere((a) => a.key == OkCancelResult.cancel).label;
      // ignore: avoid_catching_errors
    } on StateError {
      return null;
    }
  }
}

// Result type of [showOkAlertDialog] or [showOkCancelAlertDialog].
enum OkCancelResult {
  ok,
  cancel,
}