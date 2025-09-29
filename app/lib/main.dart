import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: HerBalanceApp()));
}

class HerBalanceApp extends StatelessWidget {
  const HerBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Herbalance',
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}
