import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthecure/src/routing/app_router.dart';
import 'package:synthecure/src/theme/theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return  MaterialApp.router(
        routerConfig: goRouter,
        theme: synthecureTheme,
        debugShowCheckedModeBanner: false,
        
        
    );
  }
}
