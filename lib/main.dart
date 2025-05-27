import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/erp_instance_provider.dart';
import 'screens/core/splash_screen.dart'; // We'll create this
import 'services/storage_service.dart'; // We'll create this

void main() async {
  // Ensure Flutter bindings are initialized for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service and load initial data
  final storageService = StorageService();
  final initialErpUrl = await storageService.getErpInstanceUrl();
  String? initialAuthToken; // For session/token based auth
  String? initialUserId;
  String? initialEmployeeName;
  String? initialFullName;

  if (initialErpUrl != null && initialErpUrl.isNotEmpty) {
    // If ERP URL exists, try to load session data
    final sessionData = await storageService.getSessionData();
    initialAuthToken = sessionData['sid'];
    initialUserId = sessionData['userId'];
    initialEmployeeName = sessionData['employeeName'];
    initialFullName = sessionData['fullName'];
  }

  runApp(MyApp(
    initialErpUrl: initialErpUrl,
    initialAuthToken: initialAuthToken,
    initialUserId: initialUserId,
    initialEmployeeName: initialEmployeeName,
    initialFullName: initialFullName,
  ));
}

class MyApp extends StatelessWidget {
  final String? initialErpUrl;
  final String? initialAuthToken;
  final String? initialUserId;
  final String? initialEmployeeName;
  final String? initialFullName;

  const MyApp({
    super.key,
    this.initialErpUrl,
    this.initialAuthToken,
    this.initialUserId,
    this.initialEmployeeName,
    this.initialFullName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ErpInstanceProvider(initialErpUrl),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(
            Provider.of<ErpInstanceProvider>(ctx, listen: false), // Pass ErpInstanceProvider
            StorageService(), // Pass StorageService
            initialAuthToken: initialAuthToken,
            initialUserId: initialUserId,
            initialEmployeeName: initialEmployeeName,
            initialFullName: initialFullName,
            // We'll need to initialize ApiService within AuthProvider or pass it
          ),
        ),
        // Add other providers here as needed (e.g., ThemeProvider)
      ],
      child: MaterialApp(
        title: 'Employee ESS',
        theme: ThemeData(
          primarySwatch: Colors.teal, // Or your preferred color
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(), // Start with a splash screen to decide where to go
      ),
    );
  }
}
