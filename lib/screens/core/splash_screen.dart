import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/erp_instance_provider.dart';
import '../auth/instance_config_screen.dart'; // We'll create this
import '../auth/login_screen.dart';          // We'll create this
import 'dashboard_screen.dart';        // We'll create this

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Give a slight delay for providers to initialize and to show splash
    await Future.delayed(const Duration(seconds: 2));

    final erpInstanceProvider = Provider.of<ErpInstanceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!mounted) return; // Check if the widget is still in the tree

    if (!erpInstanceProvider.isInstanceConfigured) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => InstanceConfigScreen()),
      );
    } else if (authProvider.isLoggedIn) {
       // Potentially validate token here if needed, or directly go to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Loading Employee ESS...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
