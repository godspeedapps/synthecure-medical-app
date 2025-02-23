import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package
import 'package:synthecure/src/features/auth/sign_in_screen_controller.dart';
import 'package:synthecure/src/utils/async_value_ui.dart';
import '../../constants/app_sizes.dart';
import '../../constants/keys.dart';
import 'email_password/email_password_sign_in_form_type.dart';
import 'email_password/email_password_sign_in_screen.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  // Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key anonymousButtonKey = Key(Keys.anonymous);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      signInScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
       
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Lottie animation as the background
         
             Positioned.fill(
        
              child: Lottie.network(
                'https://lottie.host/efdf3103-b77d-4b0e-be9c-6c697054cceb/V0TUeFOwwP.json', // Replace with your Lottie file path
               // Ensure it covers the entire screen
              ),
            ),
           
            // Main content
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
               
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        const Image(
                          height: 30,
                          image: AssetImage("assets/Synthecure_Logo.jpg",),
                        ),
                         
                    const EmailPasswordSignInContents(
                      formType: EmailPasswordSignInFormType.signIn,
                    ),
                      ],
                    ),
                  
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
