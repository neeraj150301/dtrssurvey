import 'package:dtrs_survey/core/storage/secure_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dtrs_survey/features/auth/presentation/pages/login_page.dart';
import 'package:dtrs_survey/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dtrs_survey/features/auth/data/models/auth_models.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool up = false;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    controller =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 3),
          reverseDuration: const Duration(milliseconds: 2300),
        )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) controller.reverse();
          if (status == AnimationStatus.dismissed) controller.forward();
        });

    controller.forward();
  }

  @override
  void dispose() {
    // Dispose of the AnimationController
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 2 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final username = prefs.getString('username');
    final id = prefs.getInt('id');
    final role = prefs.getString('role');
    final isActive = prefs.getBool('isActive');
    final fullName = prefs.getString('fullName');
    final token = await SecureStorageHelper.getToken();

    if (!mounted) return;

    if (phoneNumber != null && token != null) {
      // User is logged in, navigate to Dashboard
      final user = User(
        phoneNumber: phoneNumber,
        username: username ?? "",
        id: id ?? 0,
        fullName: fullName ?? "N/A",
        role: role ?? "N/A",
        isActive: isActive ?? false,
      );

      // context.read<DashboardBloc>().add(LoadDashboardData(phone: phoneNumber));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardPage(user: user)),
      );
    } else {
      // User is not logged in, navigate to Login Page
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: const Offset(0, 0.24),
            ).animate(controller),
            child: Image.asset('assets/login_images/TS_RS-LOGO.png'),
          ),
        ),
      ),
    );
  }
}
