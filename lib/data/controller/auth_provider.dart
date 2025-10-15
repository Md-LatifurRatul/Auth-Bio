import 'package:auth_bio/data/service/auth_service.dart';
import 'package:auth_bio/data/service/bio_metric_service.dart';
import 'package:auth_bio/data/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final SecureStorageService storageService;
  final BiometricService biometricService;

  AuthStatus status = AuthStatus.uninitialized;
  User? user;
  String role = 'user';

  AuthProvider({
    required this.authService,
    required this.storageService,
    required this.biometricService,
  }) {
    _init();
  }

  Future<void> _init() async {

    user = authService.currentUser;
    if (user != null) {
      role = await storageService.getUserRole(user!.uid) ?? 'user';
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }


  Future<String?> signUp(String email, String password, {String role = 'user'}) async {
    try {
      final cred = await authService.signUp(email, password);
      user = cred.user;

      await storageService.setUserRoleForUid(user!.uid, role);
      this.role = role;

   
      final hasBio = await biometricService.hasBiometrics();
      if (hasBio) {
        await storageService.addBiometricUser(user!.uid, role);
      }

      status = AuthStatus.authenticated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await authService.signIn(email, password);
      user = cred.user;

      role = await storageService.getUserRole(user!.uid) ?? 'user';
      status = AuthStatus.authenticated;
      notifyListeners();

      final hasBio = await biometricService.hasBiometrics();
      if (hasBio) {
        await storageService.addBiometricUser(user!.uid, role);
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

 
  Future<bool> tryBiometricUnlock() async {
    final users = await storageService.getBiometricUsers();
    if (users.isEmpty) return false;

    final available = await biometricService.hasBiometrics();
    if (!available) return false;

    final ok = await biometricService.authenticate();
    if (!ok) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

 
    final selectedUid = await showUserSelection(users.keys.toList());
    if (selectedUid == null) return false;

    role = users[selectedUid]!;


    user = authService.currentUser;
    status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }


  Future<String?> showUserSelection(List<String> uids) async {
    return await showDialog<String>(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: uids.map((uid) {
              return ListTile(
                title: Text(uid),
                onTap: () => Navigator.of(context).pop(uid),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
