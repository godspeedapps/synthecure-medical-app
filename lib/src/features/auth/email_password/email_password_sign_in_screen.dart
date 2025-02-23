import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synthecure/src/features/auth/email_password/email_password_sign_in_controller.dart';
import 'package:synthecure/src/features/auth/email_password/email_password_sign_in_validators.dart';
import 'package:synthecure/src/features/auth/email_password/string_validators.dart';
import 'package:synthecure/src/localization/string_hardcoded.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';

import '../../../widgets/custom_text_button.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/responsive_scrollable_card.dart';
import '../../../constants/app_sizes.dart';
import '../../../routing/app_router.dart';
import 'email_password_sign_in_form_type.dart';


/// Email & password sign in screen.
/// Wraps the [EmailPasswordSignInContents] widget below with a [Scaffold] and
/// [AppBar] with a title.
class EmailPasswordSignInScreen extends StatelessWidget {
  const EmailPasswordSignInScreen({super.key, required this.formType});
  final EmailPasswordSignInFormType formType;

  // * Keys for testing using find.byKey()
  static const emailKey = Key('email');
  static const passwordKey = Key('password');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In'.hardcoded, style: Theme.of(context).textTheme.titleSmall,)),
      body: EmailPasswordSignInContents(
        formType: formType,
      ),
    );
  }
}

/// A widget for email & password authentication, supporting the following:
/// - sign in
/// - register (create an account)
class EmailPasswordSignInContents extends ConsumerStatefulWidget {
  const EmailPasswordSignInContents({
    super.key,
    required this.formType,
  });

  /// The default form type to use.
  final EmailPasswordSignInFormType formType;
  @override
  ConsumerState<EmailPasswordSignInContents> createState() =>
      _EmailPasswordSignInContentsState();
}

class _EmailPasswordSignInContentsState
    extends ConsumerState<EmailPasswordSignInContents>
    with EmailAndPasswordValidators {
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String get email => _emailController.text;
  String get password => _passwordController.text;

  // local variable used to apply AutovalidateMode.onUserInteraction and show
  // error hints only when the form has been submitted
  // For more details on how this is implemented, see:
  // https://codewithandrea.com/articles/flutter-text-field-form-validation/
  var _submitted = false;
  // track the formType as a local state variable
  late final _formType = widget.formType;

  @override
  void dispose() {
    // * TextEditingControllers should be always disposed
    _node.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller =
          ref.read(emailPasswordSignInControllerProvider.notifier);
      await controller.submit(
        email: email,
        password: password,
        formType: _formType,
      );
    }
  }

  void _emailEditingComplete() {
    if (canSubmitEmail(email)) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    if (!canSubmitEmail(email)) {
      _node.previousFocus();
      return;
    }
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      emailPasswordSignInControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(emailPasswordSignInControllerProvider);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
      child: ResponsiveScrollableCard(
        child: FocusScope(
          node: _node,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                gapH8,
                // Email field
                TextFormField(
                  key: EmailPasswordSignInScreen.emailKey,
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email'.hardcoded,
                    hintText: 'Email'.hardcoded,
                    enabled: !state.isLoading,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      !_submitted ? null : emailErrorText(email ?? ''),
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  keyboardAppearance: Brightness.light,
                  onEditingComplete: () => _emailEditingComplete(),
                  inputFormatters: <TextInputFormatter>[
                    ValidatorInputFormatter(
                        editingValidator: EmailEditingRegexValidator()),
                  ],
                ),
                gapH8,
                // Password field
                TextFormField(
                  key: EmailPasswordSignInScreen.passwordKey,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: _formType.passwordLabelText,
                    enabled: !state.isLoading,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (password) => !_submitted
                      ? null
                      : passwordErrorText(password ?? '', _formType),
                  obscureText: true,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  keyboardAppearance: Brightness.light,
                  onEditingComplete: () => _passwordEditingComplete(),
                ),
                gapH32,
                PrimaryButton(
                  text: _formType.primaryButtonText,
                  isLoading: state.isLoading,
                  onPressed: state.isLoading ? null : () => _submit(),
                ),
                gapH12,
                 Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                   children:  [
                     CustomTextButton(
                      text: 'Forgot Password?',
                      style: const TextStyle(color: Colors.black),
                      onPressed: () => context.goNamed(AppRoute.forgotPassword.name),
                ),
                   ],
                 ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
