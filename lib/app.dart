import 'package:auth_bio/data/controller/auth_provider.dart';
import 'package:auth_bio/presentation/screen/dashboard.dart';
import 'package:auth_bio/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthBioApp extends StatefulWidget {
  const AuthBioApp({super.key});

  @override
  State<AuthBioApp> createState() => _AuthBioAppState();
}

class _AuthBioAppState extends State<AuthBioApp> {
  bool _biometricTried = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_biometricTried) {
      _tryBiometric();
      _biometricTried = true;
    }
  }

  Future<void> _tryBiometric() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.tryBiometricUnlock(); // Will show user selection dialog if multiple users exist
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Biometric Auth',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          switch (auth.status) {
            case AuthStatus.uninitialized:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case AuthStatus.authenticated:
              return const Dashboard(); 
            case AuthStatus.unauthenticated:
            default:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}
