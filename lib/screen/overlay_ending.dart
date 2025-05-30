import 'dart:async';
import 'package:flutter/material.dart';

class PrologueOverlayEnding extends StatefulWidget {
  final VoidCallback onDone;

  const PrologueOverlayEnding({super.key, required this.onDone});

  @override
  State<PrologueOverlayEnding> createState() => _PrologueOverlayState();
}

class _PrologueOverlayState extends State<PrologueOverlayEnding> {
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
              child: Image.asset('assets/images/prologue_next_3.png'),
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
