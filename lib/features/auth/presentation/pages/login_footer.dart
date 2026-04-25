import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_rounded, color: Colors.green),
            SizedBox(width: 10),
            const Text(
              "Official • Secure • Reliable",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Text(
          "Powered by Government of Telangana",
          style: TextStyle(fontSize: 11, color: Colors.black45),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
