import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:expense_tracker_flutter/providers/settings_provider.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuth();
    } else if (state == AppLifecycleState.paused) {
      if (context.read<SettingsProvider>().appLockEnabled) {
        setState(() {
          _isAuthenticated = false;
        });
      }
    }
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    
    if (!settings.appLockEnabled || _isAuthenticated || _isAuthenticating) {
      if (!settings.appLockEnabled && !_isAuthenticated) {
        setState(() => _isAuthenticated = true);
      }
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (canAuthenticate) {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to access your expense tracker',
          biometricOnly: false,
          persistAcrossBackgrounding: true,
        );
        setState(() {
          _isAuthenticated = didAuthenticate;
          _isAuthenticating = false;
        });
      } else {
        setState(() {
          _isAuthenticated = true; // Device doesn't support auth, fallback to open
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!settings.appLockEnabled) {
      return widget.child;
    }

    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'App Locked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _checkAuth,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
