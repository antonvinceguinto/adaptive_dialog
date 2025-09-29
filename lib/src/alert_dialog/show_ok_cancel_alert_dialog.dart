import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:adaptive_dialog/src/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Show OK/Cancel alert dialog, whose appearance is adaptive according to platform
///
/// This is convenient wrapper of [showAlertDialog].
/// [barrierDismissible] (default: true) only works for material style,
/// and if it is set to false, pressing OK or Cancel buttons is only way to
/// close alert.
/// [defaultType] only works for cupertino style and if it is specified
/// OK or Cancel button label will be changed to bold.
/// [actionsOverflowDirection] works only for Material style currently.
/// [okTextStyle] and [cancelTextStyle] allow customization of button text styles.
/// All buttons use native blue color for iOS and #FF5D31 color for Android.
@useResult
Future<OkCancelResult> showOkCancelAlertDialog({
  required BuildContext context,
  String? title,
  String? message,
  String? okLabel,
  String? cancelLabel,
  OkCancelAlertDefaultType? defaultType,
  bool isDestructiveAction = false,
  bool barrierDismissible = true,
  @Deprecated('Use `style` instead.') AdaptiveStyle? alertStyle,
  AdaptiveStyle? style,
  @Deprecated('Use `ios` instead. Will be removed in v2.')
  bool useActionSheetForCupertino = false,
  bool useActionSheetForIOS = false,
  bool useRootNavigator = true,
  VerticalDirection actionsOverflowDirection = VerticalDirection.up,
  bool fullyCapitalizedForMaterial = true,
  bool canPop = true,
  PopInvokedWithResultCallback<OkCancelResult>? onPopInvokedWithResult,
  AdaptiveDialogBuilder? builder,
  RouteSettings? routeSettings,
  TextStyle? okTextStyle,
  TextStyle? cancelTextStyle,
}) async {
  final theme = Theme.of(context);
  final adaptiveStyle = style ?? AdaptiveDialog.instance.defaultStyle;
  final isMaterial = adaptiveStyle.isMaterial(theme);
  final isIOSStyle = adaptiveStyle.effectiveStyle(theme) == AdaptiveStyle.iOS;
  
  String defaultCancelLabel() {
    final label = MaterialLocalizations.of(context).cancelButtonLabel;
    return isMaterial ? label : label.capitalizedForce;
  }

  // Custom colors - native blue for iOS, #FF5D31 for Android
  final TextStyle defaultOkTextStyle = isIOSStyle
      ? const TextStyle(color: CupertinoColors.systemBlue)
      : const TextStyle(color: Color(0xFFFF5D31));
  final TextStyle defaultCancelTextStyle = isIOSStyle
      ? const TextStyle(color: CupertinoColors.systemBlue)
      : const TextStyle(color: Color(0xFFFF5D31));

  // Use the same colors for both OK and Cancel buttons - no red destructive color
  final TextStyle finalOkTextStyle = okTextStyle ?? defaultOkTextStyle;
  final TextStyle finalCancelTextStyle = cancelTextStyle ?? defaultCancelTextStyle;

  final result = await showAlertDialog<OkCancelResult>(
    routeSettings: routeSettings,
    context: context,
    title: title,
    message: message,
    barrierDismissible: barrierDismissible,
    style: alertStyle ?? style,
    useActionSheetForIOS: useActionSheetForCupertino || useActionSheetForIOS,
    useRootNavigator: useRootNavigator,
    actionsOverflowDirection: actionsOverflowDirection,
    fullyCapitalizedForMaterial: fullyCapitalizedForMaterial,
    canPop: canPop,
    onPopInvokedWithResult: onPopInvokedWithResult,
    builder: builder,
    actions: [
      AlertDialogAction(
        label: cancelLabel ?? defaultCancelLabel(),
        key: OkCancelResult.cancel,
        isDefaultAction: defaultType == OkCancelAlertDefaultType.cancel,
        textStyle: finalCancelTextStyle,
      ),
      AlertDialogAction(
        label: okLabel ?? MaterialLocalizations.of(context).okButtonLabel,
        key: OkCancelResult.ok,
        isDefaultAction:
            defaultType == null || defaultType == OkCancelAlertDefaultType.ok,
        // Set to false to use our custom colors instead of red destructive
        isDestructiveAction: false,
        textStyle: finalOkTextStyle,
      ),
    ],
  );
  return result ?? OkCancelResult.cancel;
}