import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium animated splash screen that uses a cinematic 
/// "rack focus" (blur resolve) and slow-scale entrance.
/// This creates a highly professional, high-end app feel.
class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _blur;
  late final Animation<Offset> _slide;
  bool _showChild = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Fade in gracefully
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );

    // Rack focus effect (starts out-of-focus, resolves to sharp)
    _blur = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    // Cinematic slow scale down (camera lens settling effect)
    _scale = Tween<double>(begin: 1.15, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Subtle upward drift as it resolves
    _slide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // 3 seconds total splash duration before routing
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _showChild = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showChild) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Uses native background colors for a seamless transition into the app
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final logoAsset = isDark 
        ? 'assets/images/logo_stacked_light.png' 
        : 'assets/images/logo_stacked_dark.png';

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Optimization: Avoid ImageFiltered if blur is 0 to save performance
            final blurValue = _blur.value;
            
            Widget logoWidget = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Image.asset(
                logoAsset,
                width: 240,
                fit: BoxFit.contain,
              ),
            );

            if (blurValue > 0) {
              logoWidget = ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurValue,
                  sigmaY: blurValue,
                  tileMode: TileMode.decal,
                ),
                child: logoWidget,
              );
            }

            return Transform.translate(
              offset: _slide.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: logoWidget,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
