import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Green Bar
        Container(
          width: double.infinity,
          color: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'Agricultural Structures Survey',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),

        // Top Logos Row
        Container(
          decoration: const BoxDecoration(color: AppColors.cardBackground),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        'assets/login_images/left.jpg',
                      ),
                    ),
                    Image.asset(
                      'assets/login_images/TS_RS-LOGO.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),

                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        'assets/login_images/right.jpg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Image.asset('assets/login_images/center.png', fit: BoxFit.contain),
      ],
    );
  }
}
