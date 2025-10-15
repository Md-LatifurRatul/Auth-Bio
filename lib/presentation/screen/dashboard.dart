import 'package:auth_bio/data/controller/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _biometricEnabled = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final enabled = await auth.storageService.getBiometricUsers();
    setState(() {
      _biometricEnabled = auth.user != null && enabled.containsKey(auth.user!.uid);
    });
  }

  Future<void> _toggleBiometric() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    setState(() => _loading = true);

    if (_biometricEnabled) {
      // Disable biometric for this user
      await auth.storageService.removeBiometricUser(auth.user!.uid);
      setState(() => _biometricEnabled = false);
    } else {
      // Enable biometric for this user
      final hasBio = await auth.biometricService.hasBiometrics();
      if (hasBio) {
        final ok = await auth.biometricService.authenticate();
        if (ok) {
          await auth.storageService.addBiometricUser(auth.user!.uid, auth.role);
          setState(() => _biometricEnabled = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biometric authentication failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Biometric authentication not available on this device"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.role;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user?.email ?? ''}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Role: $role',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
      Icon(
  Icons.fingerprint, 
  size: 64,
  color: _biometricEnabled ? Colors.indigo : Colors.grey, // grey if disabled
),

            const SizedBox(height: 12),
            Text(
              _biometricEnabled
                  ? 'Biometric Authenticated ✅'
                  : 'Biometric Not Enabled ❌',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _toggleBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(_biometricEnabled ? 'Disable Biometric' : 'Enable Biometric'),
                  ),
          ],
        ),
      ),
    );
  }
}
