import 'package:auth_bio/app.dart';
import 'package:auth_bio/data/controller/auth_provider.dart';
import 'package:auth_bio/data/service/auth_service.dart';
import 'package:auth_bio/data/service/bio_metric_service.dart';
import 'package:auth_bio/data/service/secure_storage_service.dart';
import 'package:auth_bio/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  final storageService = SecureStorageService();
  final biometricService = BiometricService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            storageService: storageService,
            biometricService: biometricService,
          )..tryBiometricUnlock(), 
        ),
      ],
      child: const AuthBioApp(),
    ),
  );
}
