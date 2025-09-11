import 'package:adaptive_dialog/src/action_callback.dart';
import 'package:adaptive_dialog/src/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'sheet_action.dart';

class CupertinoModalActionSheet<T> extends StatelessWidget {
  const CupertinoModalActionSheet({
    super.key,
    required this.onPressed,
    required this.actions,
    this.title,
    this.message,
    this.cancelLabel,
    required this.canPop,
    required this.onPopInvokedWithResult,
  });

  final ActionCallback<T> onPressed;
  final List<SheetAction<T>> actions;
  final String? title;
  final String? message;
  final String? cancelLabel;
  final bool canPop;
  final PopInvokedWithResultCallback<T>? onPopInvokedWithResult;

  @override
  Widget build(BuildContext context) {
    // Custom orange color for the theme
    const Color customOrangeColor = Color(0xFFFF5D31);
    
    final title = this.title;
    final message = this.message;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: 1,
        child: CupertinoActionSheet(
          title: title == null ? null : Text(title),
          message: message == null ? null : Text(message),
          // Cancel button should keep default styling for better UX
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: !actions.any((a) => a.isDefaultAction),
            onPressed: () => onPressed(null),
            child: Text(
              cancelLabel ??
                  MaterialLocalizations.of(context)
                      .cancelButtonLabel
                      .capitalizedForce,
            ),
          ),
          actions: actions
              .map(
                (a) {
                  // Determine the text style with proper color priority:
                  // 1. If destructive action -> use red
                  // 2. If custom color in textStyle -> use that
                  // 3. Otherwise -> use orange theme color
                  TextStyle finalTextStyle = a.textStyle;
                  
                  if (a.isDestructiveAction) {
                    // Destructive actions should remain red
                    finalTextStyle = a.textStyle.copyWith(color: CupertinoColors.destructiveRed);
                  } else if (a.textStyle.color == null) {
                    // Apply orange color only if no custom color is specified
                    finalTextStyle = a.textStyle.copyWith(color: customOrangeColor);
                  }
                  
                  return CupertinoActionSheetAction(
                    // Don't use isDestructiveAction flag since we're handling colors manually
                    isDestructiveAction: false,
                    isDefaultAction: a.isDefaultAction,
                    onPressed: () => onPressed(a.key),
                    child: Text(
                      a.label,
                      style: finalTextStyle,
                    ),
                  );
                },
              )
              .toList(),
        ),
      ),
    );
  }
}