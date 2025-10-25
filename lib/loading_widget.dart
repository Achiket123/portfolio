import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// --- 1. NEW DYNAMIC BLOB LOADER ---

class BlobLoader extends StatefulWidget {
  final Color color;
  final double size;

  const BlobLoader({super.key, required this.color, required this.size});

  @override
  State<BlobLoader> createState() => _BlobLoaderState();
}

class _BlobLoaderState extends State<BlobLoader> with TickerProviderStateMixin {
  late AnimationController _pulseController; // Controls scale/blob
  late AnimationController _popController; // Controls vertical movement
  late Animation<double> _pulseAnimation;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Pulse/Blob Controller (Slow, organic)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Pop Controller (Faster, subtle bounce)
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _popAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      // Moves up by 8 pixels
      CurvedAnimation(parent: _popController, curve: Curves.easeInOutSine),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _popController]),
      builder: (context, child) {
        // Outer Blob/Pulse Effect
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.color.withOpacity(0.5 * _pulseAnimation.value),
                width: 3.0 * _pulseAnimation.value,
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
            ),
            child: Center(
              // Inner Pop Effect
              child: Transform.translate(
                offset: Offset(0, _popAnimation.value),
                child: Container(
                  width: widget.size / 3,
                  height: widget.size / 3,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _popController.dispose();
    super.dispose();
  }
}

// ------------------------------------------------------------------
// --- 2. THE CIRCULAR REVEAL TRANSITION WRAPPER (Updated to use BlobLoader) ---
// ------------------------------------------------------------------

class CircularRevealWrapper extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Duration transitionDuration;
  final Color accentColor;

  const CircularRevealWrapper({
    Key? key,
    required this.isLoading,
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.accentColor = const Color.fromARGB(255, 8, 70, 10),
  }) : super(key: key);

  @override
  State<CircularRevealWrapper> createState() => _CircularRevealWrapperState();
}

class _CircularRevealWrapperState extends State<CircularRevealWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;
  late Animation<double> _loaderFadeAnimation;

  bool _showContent = false;
  double _maxRadius = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );

    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCirc));

    _loaderFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _showContent = !widget.isLoading;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _maxRadius = sqrt(size.width * size.width + size.height * size.height) / 2;
  }

  @override
  void didUpdateWidget(CircularRevealWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isLoading && !widget.isLoading) {
      setState(() => _showContent = true);
      _controller.forward(from: 0.0);
    } else if (!oldWidget.isLoading && widget.isLoading) {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _showContent = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentRadius = _maxRadius * _revealAnimation.value;
        final size = MediaQuery.of(context).size;
        final center = Offset(size.width / 2, size.height / 2);

        // 1. Content (Revealed by the expanding circle)
        Widget content = ClipPath(
          clipper: CircleRevealClipper(center: center, radius: currentRadius),
          child: Opacity(
            opacity: _revealAnimation.value.clamp(0.2, 1.0),
            child: widget.child,
          ),
        );

        // 2. Loading Overlay (Fades out quickly)
        Widget loadingOverlay = IgnorePointer(
          ignoring: _controller.value > 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Opacity(
                  opacity: _loaderFadeAnimation.value,
                  child: Container(
                    color: Colors.black.withOpacity(
                      _loaderFadeAnimation.value * 0.9,
                    ),
                    child: BlobLoader(
                      color: Colors.green,
                      size: 80, // Slightly larger for better visual impact
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Yammettee Kudaassaaii...🥵🥵🥵",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );

        return Stack(
          children: [
            if (_showContent) content,
            if (widget.isLoading || _controller.isAnimating) loadingOverlay,
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// --- 3. CUSTOM CLIPPER FOR CIRCULAR REVEAL (UNCHANGED) ---

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}
