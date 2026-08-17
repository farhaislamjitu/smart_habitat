import 'package:flutter/material.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animateLogo = false;
  bool _animateText = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _navigateToNextScreen();
  }

  void _startAnimations() async {
    // Stage 1: Logo scale-up drops in quickly
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _animateLogo = true);

    // Stage 2: Text fades and slides up shortly after
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) setState(() => _animateText = true);
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color lightTealTop = Color(0xFF00A294);
    const Color lightTealBottom = Color(0xFF00897B);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightTealTop, lightTealBottom],
          ),
        ),
        child: Stack(
          children: [
            // Central Branding Element Area
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with elegant decorative glow backdrop
                  AnimatedScale(
                    scale: _animateLogo ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: _animateLogo ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // FIXED: Switched curve style parameter from textAnchorCurve to easeOut
                  AnimatedPadding(
                    padding: EdgeInsets.only(top: _animateText ? 0 : 20),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: _animateText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        'Smart Habitat',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Premium linear loading bar resting at the bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
