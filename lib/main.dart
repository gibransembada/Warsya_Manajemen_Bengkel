import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/test_firebase_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/create_workshop_screen.dart';
import 'screens/workshop_profile_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/work_orders_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/spare_part_purchase_history_screen.dart';
import 'screens/spare_part_dashboard_screen.dart';
import 'screens/service_screen.dart';
import 'screens/financial_report_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'MYBENGKEL',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/create-workshop': (context) => const CreateWorkshopScreen(),
          '/workshop-profile': (context) => const WorkshopProfileScreen(),
          '/test': (context) => const TestFirebaseScreen(),
          '/work_orders': (context) => const WorkOrdersScreen(),
          '/customers': (context) => const CustomersScreen(),
          '/spare-part-purchase-history': (context) =>
              const SparePartPurchaseHistoryScreen(),
          '/spare-part-dashboard': (context) =>
              const SparePartDashboardScreen(),
          '/service': (context) => const ServiceScreen(),
          '/financial-report': (context) => const FinancialReportScreen(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyBengkel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Selamat Datang di MyBengkel'),
      ),
    );
  }
}
