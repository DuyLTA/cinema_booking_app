import 'package:flutter/material.dart';

/// Simple launch/splash screen for app initialization
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191210),
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// Background blur overlay (top-left)
          Positioned(
            left: -39,
            top: -104,
            child: Container(
              width: 156,
              height: 414.39,
              decoration: ShapeDecoration(
                color: const Color(0x335C0612),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),

          /// Background blur overlay (bottom-right)
          Positioned(
            right: -30,
            top: 725,
            child: Container(
              width: 156,
              height: 414.39,
              decoration: ShapeDecoration(
                color: const Color(0x19FFDF9E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),

          /// Center loading indicator
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CINE BOOKING',
                  style: TextStyle(
                    color: Color(0xFFFEDEAE),
                    fontSize: 32,
                    fontFamily: 'Bebas Neue',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
