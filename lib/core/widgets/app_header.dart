import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleFont = width * 0.052;
    final subTitleFont = width * 0.068;
    final smallFont = width * 0.040;
    final tinyFont = width * 0.034;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/login_images/bg_grey.png',
            fit: BoxFit.cover,
            cacheWidth: width.toInt(),
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
                      height: width * 0.12,
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
                  maxLines: 1,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 65, 109, 56),
                    fontWeight: FontWeight.w900,
                    fontSize: titleFont,
                    letterSpacing: 1.5,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,

                  child: Text(
                    'TELANGANA RYTHU POWER',
                    maxLines: 1,

                    style: TextStyle(
                      color: const Color.fromARGB(255, 65, 109, 56),
                      fontWeight: FontWeight.w900,
                      fontSize: subTitleFont,
                      // letterSpacing: 2.2,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,

                  child: Text(
                    'DISTRIBUTION COMPANY LIMITED',
                    maxLines: 1,

                    style: TextStyle(
                      color: const Color.fromARGB(255, 28, 98, 155),
                      fontWeight: FontWeight.bold,
                      fontSize: smallFont,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'A Government of Telangana Undertaking',
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 28, 98, 155),
                      fontWeight: FontWeight.bold,
                      fontSize: tinyFont,
                    ),
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
