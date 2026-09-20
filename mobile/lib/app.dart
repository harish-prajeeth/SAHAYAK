import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/theme.dart';

class SurakshitApp extends StatelessWidget {
  const SurakshitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Surakshit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: auth.user != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}
