import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometrics and has enrolled biometrics
  Future<bool> hasBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate user using biometrics (fingerprint / face)
  Future<bool> authenticate() async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true, 
          stickyAuth: true, 
        ),
      );
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }
}
