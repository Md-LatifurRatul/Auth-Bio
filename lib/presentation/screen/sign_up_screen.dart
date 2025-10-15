import 'package:auth_bio/data/controller/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  String _selectedRole = 'user';
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            DropdownButton<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('Normal User')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);

                      final err = await auth.signUp(
                        _emailC.text.trim(),
                        _passC.text.trim(),
                        role: _selectedRole,
                      );

                      setState(() => _loading = false);

                      if (err != null) {
                        _showMessage("Signup failed: $err", isError: true);
                      } else {
                        _showMessage("Signup successful!");
                        // Clear fields
                        _emailC.clear();
                        _passC.clear();
                        setState(() => _selectedRole = 'user');
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
