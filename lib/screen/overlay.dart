import 'dart:async';
import 'package:flutter/material.dart';

class PrologueOverlay extends StatefulWidget {
  final VoidCallback onDone;

  const PrologueOverlay({super.key, required this.onDone});

  @override
  State<PrologueOverlay> createState() => _PrologueOverlayState();
}

class _PrologueOverlayState extends State<PrologueOverlay> {
  int tapCount = 0;
  bool isTapEnabled = false;

  @override
  void initState() {
    super.initState();
    // Nonaktifkan tap selama 5 detik
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isTapEnabled = true;
      });
    });
  }

  void _handleTap() {
    if (!isTapEnabled) return;

    setState(() {
      tapCount++;
    });

    if (tapCount >= 1) {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: Image.asset('assets/images/prologue_next_2.png'),
            ),
            if (!isTapEnabled)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
