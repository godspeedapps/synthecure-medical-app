//import 'package:auth_widget_builder/auth_widget_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore:depend_on_referenced_packages
import 'package:synthecure/src/repositories/firebase_auth_repository.dart';
import 'package:synthecure/src/localization/string_hardcoded.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'src/app.dart';
import 'src/repositories/onboarding_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  //await ScanbotSdk.initScanbotSdk(ScanbotSdkConfig(licenseKey: LICENSE_KEY));
  // turn off the # in the URLs on the web
  final sharedPreferences =
      await SharedPreferences.getInstance();
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors
  registerErrorHandlers();
  // * Entry point of the app

  final container = ProviderContainer(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(
        OnboardingRepository(sharedPreferences),
      ),
    ],
  );
  // ✅ Make sure the status bar is enabled
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Preload the adminProvider
  try {
    if (container
            .read(authRepositoryProvider)
            .currentUser !=
        null) {
      await container.read(isAdminProvider.notifier).checkIsAdmin();
    }
  } catch (e) {
    print('Error preloading admin: $e');
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

void registerErrorHandlers() {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError =
      (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('An error occurred'.hardcoded),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
