import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/features/auth/sign_in_screen_controller.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

import '../../widgets/primary_button.dart';
import '../../constants/keys.dart';
import '../../constants/strings.dart';
import '../../routing/app_router.dart';


class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key anonymousButtonKey = Key(Keys.anonymous);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      signInScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(signInScreenControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            width: min(constraints.maxWidth, 600),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 32.0),
                // Sign in text or loading UI
                SizedBox(
                  height: 50.0,
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const Text(
                          Strings.signIn,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 32.0, fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(height: 32.0),
                PrimaryButton(
                  key: emailPasswordButtonKey,
                  text: Strings.signInWithEmailPassword,
                  onPressed: state.isLoading
                      ? null
                      : () => context.goNamed(AppRoute.emailPassword.name),
                ),
            
              ],
            ),
          );
        }),
      ),
    );
  }
}
