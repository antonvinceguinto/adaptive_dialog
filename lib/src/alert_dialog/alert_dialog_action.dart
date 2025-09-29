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
    // For iOS, always use native blue color by setting isDestructiveAction to false
    // This ensures all buttons (including destructive ones) use the native blue color
    return CupertinoDialogAction(
      isDefaultAction: isDefaultAction,
      isDestructiveAction: false, // Always false to use native blue color
      textStyle: textStyle,
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
    // Custom Android color - 0xFFFF5D31
    const Color customAndroidColor = Color(0xFFFF5D31);
    
    return TextButton(
      child: Text(
        fullyCapitalized ? label.toUpperCase() : label,
        style: textStyle.copyWith(
          // Always use the custom Android color, even for destructive actions
          color: customAndroidColor,
        ),
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