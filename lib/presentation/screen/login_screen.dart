import 'package:auth_bio/data/controller/auth_provider.dart';
import 'package:auth_bio/presentation/screen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);

                      final err = await auth.signIn(
                        _emailC.text.trim(),
                        _passC.text.trim(),
                      );

                      setState(() => _loading = false);

                      if (err != null) {
                        _showMessage("Login failed: $err", isError: true);
                      } else {
                        _showMessage("Login successful!");

                        
                        _emailC.clear();
                        _passC.clear();

                       
                        final users = await auth.storageService.getBiometricUsers();
                        if (users.containsKey(auth.user!.uid)) {
                          final ok = await auth.biometricService.authenticate();
                          if (!ok) {
                            _showMessage("Biometric authentication failed", isError: true);
                          }
                        }
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              ),
              child: const Text('Create new account'),
            ),
          ],
        ),
      ),
    );
  }
}
