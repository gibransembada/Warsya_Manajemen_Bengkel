import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mybengkel/screens/welcome_screen.dart';
import 'package:mybengkel/screens/login_screen.dart';
import 'package:mybengkel/screens/main_screen.dart';
import 'package:mybengkel/screens/create_workshop_screen.dart';
import 'package:mybengkel/providers/auth_provider.dart' as AppAuthProvider;

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Beri sedikit jeda agar tidak terasa janggal
    await Future.delayed(const Duration(milliseconds: 50));

    final prefs = await SharedPreferences.getInstance();
    // Cek apakah pengguna sudah pernah melihat welcome screen
    final bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    debugPrint('AuthWrapper: hasSeenWelcome = $hasSeenWelcome');

    if (!hasSeenWelcome) {
      debugPrint('AuthWrapper: Menuju WelcomeScreen');
      // Jika belum, arahkan ke WelcomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      // Jika sudah, cek status login
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('AuthWrapper: Firebase user = ${user?.uid}');
      if (user != null) {
        debugPrint('AuthWrapper: User sudah login, refresh data...');
        // WAJIB: Ambil data user lengkap dari Firestore sebelum ke dashboard
        await Provider.of<AppAuthProvider.AuthProvider>(context, listen: false)
            .refreshUser();

        if (!context.mounted) return;

        final user =
            Provider.of<AppAuthProvider.AuthProvider>(context, listen: false)
                .user;
        if (user?.workshopId == null || user!.workshopId!.isEmpty) {
          debugPrint(
              'AuthWrapper: User belum punya bengkel, menuju CreateWorkshopScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateWorkshopScreen()),
          );
          return;
        }

        debugPrint('AuthWrapper: Menuju MainScreen');
        // Jika sudah login dan punya bengkel, ke MainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        debugPrint('AuthWrapper: User belum login, menuju LoginScreen');
        // Jika belum login, ke LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan layar loading sementara proses navigasi
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
