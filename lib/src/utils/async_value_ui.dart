import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/domain/app_user.dart';
import 'package:synthecure/src/localization/string_hardcoded.dart';
import 'package:synthecure/src/utils/alert_dialogs.dart';

extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    debugPrint(
        'isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    }
  }

  void showAlertDialogDeleteUser(
      BuildContext context, AppUser model) {
    debugPrint(
        'isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    } else if (!isLoading && !hasError) {
      context.pop();
      context.pop();

      showExceptionAlertDialog(
        context: context,
        title: "User Deleted",
        exception:
            "${model.email} has been successfully deleted.",
      );
    }
  }

  void showAlertDialogAddUser(
      BuildContext context, String email) {
    debugPrint(
        'isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    } else if (!isLoading && !hasError) {
      context.pop();

      showExceptionAlertDialog(
        context: context,
        title: "User Added!",
        exception: "$email has been successfully added.",
      );
    }
  }

  void showAlertDialogAddHospital(
      BuildContext context, String name) {
    debugPrint(
        'isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    } else if (!isLoading && !hasError) {
      context.pop();

      showExceptionAlertDialog(
        context: context,
        title: "Hospital Added!",
        exception: "$name has been successfully created.",
      );
    }
  }

  void showAlertDialogDelete(BuildContext context,
      {required String message, required String title}) {
    debugPrint(
        'isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    } else if (!isLoading && !hasError) {
      context.pop();
      context.pop();

      showExceptionAlertDialog(
        context: context,
        title: title,
        exception: message,
      );
    }
  }

  void showAlertDialogUpdate(BuildContext context,
      {required String message, required String title}) {
    debugPrint(
        'isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    } else if (!isLoading && !hasError) {
      context.pop();

      showExceptionAlertDialog(
        context: context,
        title: title,
        exception: message,
      );
    }
  }
}
