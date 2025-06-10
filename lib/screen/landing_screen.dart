import 'package:flutter/material.dart';
import 'package:jetpack_joy/screen/setting_screen.dart';
import 'package:jetpack_joy/screen/prologue_scene.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/landing_screen.png',
              fit: BoxFit.fill,
            ),
          ),
          // Content positioned at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.8
                    ), // Adjust opacity for better visibility
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        Colors.white.withOpacity(0.8)), // Slightly more visible
              ),
              margin:
                  const EdgeInsets.only(bottom: 60), // Margin from the bottom
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModernButton(
                    context,
                    label: 'Start Game',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrologueScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildModernButton(
                    context,
                    label: 'Settings',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
