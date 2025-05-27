import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart'; // For logout navigation

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) { // Check if widget is still in tree
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${authProvider.currentFullName ?? 'User'}!",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            if(authProvider.currentEmployeeName != null)
              Text("Employee ID: ${authProvider.currentEmployeeName}"),
            const SizedBox(height: 20),
            const Text("App Dashboard - Features coming soon!"),
            // TODO: Add navigation to other features
            // e.g., ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())), child: Text("View Profile"))
          ],
        ),
      ),
      // TODO: Add BottomNavigationBar or Drawer for feature navigation
    );
  }
}
