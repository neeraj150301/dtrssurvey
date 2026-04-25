import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/login_images/bg_grey.png',
            fit: BoxFit.fitHeight,
            cacheWidth: MediaQuery.of(context).size.width.toInt(),
          ),
        ),
        SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 18),
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
                const SizedBox(height: 18),

                Text(
                  'తెలంగాణ రైతు విద్యుత్ పంపిణీ సంస్థ',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 65, 109, 56),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'RYTHU POWER',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 65, 109, 56),
                    fontWeight: FontWeight.w900,
                    fontSize: 46,
                    letterSpacing: 2.2,
                  ),
                ),
                Text(
                  'DISTRIBUTION COMPANY OF TELANGANA LIMITED',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 28, 98, 155),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'A Government of Telangana Undertaking',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 28, 98, 155),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
