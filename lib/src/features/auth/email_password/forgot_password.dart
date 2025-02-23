import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/features/auth/email_password/string_validators.dart';
import 'package:synthecure/src/localization/string_hardcoded.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

import '../../../widgets/primary_button.dart';
import '../../../constants/app_sizes.dart';
import 'email_password_sign_in_controller.dart';
import 'email_password_sign_in_screen.dart';
import 'email_password_sign_in_validators.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword>
    with EmailAndPasswordValidators {
  final _formKey = GlobalKey<FormState>();

  var _submitted = false;

  final _emailController = TextEditingController();
  String get email => _emailController.text;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller =
          ref.read(emailPasswordSignInControllerProvider.notifier);
      await controller.reset(email: email);

      // ignore: use_build_context_synchronously


      if(context.mounted) {
        showCupertinoDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Reset link sent'),
              content: const Text('Please check your email'),
              actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
             
              ],
            );
          });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      emailPasswordSignInControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(emailPasswordSignInControllerProvider);

    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              CupertinoIcons.xmark,
              size: 25,
            )),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              width: min(constraints.maxWidth, 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  gapH32,
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Please enter your email address to reset your password',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  gapH32,
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        key: EmailPasswordSignInScreen.emailKey,
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'johndoe@gmail.com'.hardcoded,
                          enabled: !state.isLoading,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            !_submitted ? null : emailErrorText(email ?? ''),
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        keyboardAppearance: Brightness.light,
                        inputFormatters: <TextInputFormatter>[
                          ValidatorInputFormatter(
                              editingValidator: EmailEditingRegexValidator()),
                        ],
                      ),
                    ),
                  ),
                  gapH48,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: PrimaryButton(
                      text: 'Reset Password',
                      isLoading: state.isLoading,
                      onPressed: state.isLoading ? null : () => _submit(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
