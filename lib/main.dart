import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/loading_widget.dart';

class _StaticBlurOverlay extends StatelessWidget {
  final double sigmaX;
  final double sigmaY;

  const _StaticBlurOverlay({required this.sigmaX, required this.sigmaY});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(color: Colors.black.withOpacity(0.05)),
      ),
    );
  }
}

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: ScrollVideoPage()),
);

class ScrollVideoPage extends StatefulWidget {
  const ScrollVideoPage({super.key});

  @override
  _ScrollVideoPageState createState() => _ScrollVideoPageState();
}

class _ScrollVideoPageState extends State<ScrollVideoPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentFrameNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> _loadProgressNotifier = ValueNotifier<double>(
    0.0,
  );
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);

  final int totalFrames = 750;
  final int initialFrames = 30;

  List<Uint8List?> _frameBytes = [];
  List<ui.Image?> _decodedFrames = [];
  bool _isInitialLoadComplete = false;
  bool _isFullyLoaded = false;

  @override
  void initState() {
    super.initState();
    _frameBytes = List<Uint8List?>.filled(totalFrames, null);
    _decodedFrames = List<ui.Image?>.filled(totalFrames, null);
    _loadFramesParallel();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadFramesParallel() async {
    await _loadSequentialBatch(0, initialFrames);
    if (mounted) setState(() => _isInitialLoadComplete = true);
    await _loadRemainingFramesParallel();
  }

  Future<void> _loadSequentialBatch(int start, int end) async {
    for (int i = start; i < end && i < totalFrames; i++) {
      await _loadSingleFrame(i);
      if (mounted) _loadProgressNotifier.value = (i + 1) / totalFrames;
    }
  }

  Future<void> _loadRemainingFramesParallel() async {
    const int batch = 20;
    for (int i = initialFrames; i < totalFrames; i += batch) {
      await Future.wait(
        List.generate(
          batch,
          (j) =>
              (i + j < totalFrames) ? _loadSingleFrame(i + j) : Future.value(),
        ),
      );
      if (mounted) {
        _loadProgressNotifier.value = min(1.0, (i + batch) / totalFrames);
      }
    }
    if (mounted) setState(() => _isFullyLoaded = true);
  }

  Future<void> _loadSingleFrame(int index) async {
    if (_frameBytes[index] != null) return;

    final path =
        'assets/frames/frame_${(index + 1).toString().padLeft(4, '0')}.jpg';
    try {
      final data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();
      final completer = Completer<void>();

      ui.decodeImageFromList(bytes, (ui.Image image) {
        _decodedFrames[index] = image;
        completer.complete();
      });

      await completer.future;
      _frameBytes[index] = bytes;
    } catch (e) {
      debugPrint('Error loading frame $index: $e');
      _frameBytes[index] = Uint8List(0);
    }
  }

  void _onScroll() {
    if (!_isInitialLoadComplete || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final scrollFraction = (_scrollController.offset / maxScroll).clamp(
      0.0,
      1.0,
    );
    final targetFrameIndex = (scrollFraction * (totalFrames - 1)).round().clamp(
      0,
      totalFrames - 1,
    );

    int newIndex = targetFrameIndex;
    if (targetFrameIndex < _decodedFrames.length &&
        _decodedFrames[targetFrameIndex] == null) {
      for (int i = targetFrameIndex - 1; i >= 0; i--) {
        if (_decodedFrames[i] != null) {
          newIndex = i;
          break;
        }
      }
    }

    if (_currentFrameNotifier.value != newIndex) {
      _currentFrameNotifier.value = newIndex;
      if (!_isFullyLoaded) _preloadNearbyFrames(newIndex);
    }

    _scrollProgress.value = scrollFraction;
  }

  void _preloadNearbyFrames(int currentIndex) {
    for (int offset = -10; offset <= 10; offset++) {
      final i = currentIndex + offset;
      if (i >= 0 && i < totalFrames && _decodedFrames[i] == null) {
        _loadSingleFrame(i);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currentFrameNotifier.dispose();
    _loadProgressNotifier.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isInitialLoadComplete
              ? Stack(
                children: [
                  // 1️⃣ Canvas-based frame rendering
                  ValueListenableBuilder<int>(
                    valueListenable: _currentFrameNotifier,
                    builder: (context, frameIndex, _) {
                      return CustomPaint(
                        size: Size(screenWidth, screenHeight),
                        painter: FramePainter(_decodedFrames, frameIndex),
                      );
                    },
                  ),

                  // 2️⃣ Blur overlay
                  const _StaticBlurOverlay(sigmaX: 5, sigmaY: 5),

                  // 3️⃣ Gradient & Titles remain widgets (efficient)
                  ValueListenableBuilder<double>(
                    valueListenable: _scrollProgress,
                    builder: (context, progress, _) {
                      final nameT = ((progress - 0.2) / 0.3).clamp(0.0, 1.0);
                      final projectsT = ((progress - 0.45) / 0.25).clamp(
                        0.0,
                        1.0,
                      );

                      return IgnorePointer(
                        ignoring: true,
                        child: Container(
                          height: screenHeight,
                          width: screenWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(
                                  0,
                                  ui.lerpDouble(0, -screenHeight / 2.5, nameT)!,
                                ),
                                child: Transform.scale(
                                  scale: ui.lerpDouble(1.0, 0.7, nameT)!,
                                  child: const Text(
                                    "ACHIKET KUMAR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: Curves.easeInOut.transform(projectsT),
                                child: const Text(
                                  "PROJECTS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 4️⃣ Tan Path Widgets Left
                  ValueListenableBuilder<double>(
                    valueListenable: _scrollProgress,
                    builder: (context, progress, _) {
                      return _buildTanPathWidgets(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        progress: progress,
                        isLeftSide: true,
                      );
                    },
                  ),

                  // 5️⃣ Tan Path Widgets Right
                  ValueListenableBuilder<double>(
                    valueListenable: _scrollProgress,
                    builder: (context, progress, _) {
                      return _buildTanPathWidgets(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        progress: progress,
                        isLeftSide: false,
                      );
                    },
                  ),

                  // 6️⃣ Transparent scroll area
                  NotificationListener<ScrollNotification>(
                    onNotification: (_) => true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: screenHeight * 10,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentFrameNotifier,
                      builder: (context, frameIndex, _) {
                        final progress = frameIndex / max(1, totalFrames - 1);
                        const double start = 0.90;
                        const double end = 1.0;

                        double t = 0;
                        if (progress >= start && progress <= end) {
                          t = (progress - start) / (end - start);
                        } else if (progress > end) {
                          t = 1.0;
                        }

                        // 3D waking-up transform
                        final double translateY = (1 - t) * screenHeight;
                        final double rotateX = -(1 - t) * (pi / 3);
                        final double rotateZ = -(1 - t) * 0.1;
                        final double scale = 0.7 + 0.3 * t;

                        final Matrix4 transform =
                            Matrix4.identity()
                              ..setEntry(3, 2, 0.0015)
                              ..translate(0.0, translateY)
                              ..rotateX(rotateX)
                              ..rotateZ(rotateZ)
                              ..scale(scale);

                        // Horizontal card animation parameters
                        final double cardStartOffset = 250.0; // offscreen start
                        final double cardSpacing =
                            20.0; // spacing between cards

                        return Container(
                          decoration: BoxDecoration(color: Colors.black),
                          alignment: Alignment.center,
                          transform: transform,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon + Title moving up (waking up effect)
                              Transform.translate(
                                offset: Offset(0, -t * 150),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.rocket_launch,
                                      color: Colors.white,
                                      size: 80,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "OPEN SOURCE CONTRIBUTIONS",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Contribution cards coming from right → left
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    final cardT = ((progress - 0.82) * 5 -
                                            index * 0.1)
                                        .clamp(0.0, 1.0);
                                    final dx = cardStartOffset * (1 - cardT);
                                    final opacity = Curves.easeInOut.transform(
                                      cardT,
                                    );
                                    final scale =
                                        ui.lerpDouble(0.8, 1.0, cardT)!;

                                    return Transform.translate(
                                      offset: Offset(dx, 0),
                                      child: Opacity(
                                        opacity: opacity,
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: cardSpacing,
                                            ),
                                            child: _buildOpenSourceCard(index),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              : const Center(child: LoadingWidget()),
    );
  }

  Widget _buildOpenSourceCard(int index) {
    final titles = [
      "Flutter UI Library",
      "Go AI Agent",
      "OpenCV Plugin",
      "Neovim Plugin",
      "Portfolio Website",
    ];
    final subtitles = [
      "Custom Flutter Widgets",
      "Multi-agent AI system",
      "Computer Vision Utils",
      "Editor Enhancements",
      "Personal Portfolio",
    ];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return Container(
      width: 250,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[index % colors.length].withOpacity(0.8),
            colors[index % colors.length].withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titles[index % titles.length],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitles[index % subtitles.length],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- TAN PATH WIDGETS -----------------

  Widget _buildTanPathWidgets({
    required double screenWidth,
    required double screenHeight,
    required double progress,
    required bool isLeftSide,
  }) {
    final double startX = screenWidth / 2;
    final double startY = screenHeight;
    final double maxAngle = pi / 2.5;

    // Increase horizontal distance based on screen width
    // Example: 0.15 on small screens, up to ~0.35 on large screens
    final double horizontalDistance =
        screenWidth * 0.25; // adjust multiplier as needed

    final double verticalDistance = screenHeight * 0.7;
    final double curveIntensity = screenHeight * 0.1;
    final curve = Curves.easeInOutCubic;

    // Adjust widgetHalfWidth based on responsive container width
    final double widgetHalfWidth =
        screenWidth * 0.175; // half of containerWidth

    const double spacingBetweenContainers = 0.18;

    return Stack(
      children: List.generate(3, (index) {
        final offset = index * spacingBetweenContainers;
        double adjustedProgress = (progress - offset).clamp(0.0, 1.0);

        if (adjustedProgress <= 0) return const SizedBox.shrink();

        // Smooth easing for position
        adjustedProgress = curve.transform(adjustedProgress);

        // Tan curve movement
        final double xAngle = adjustedProgress * maxAngle;
        double mathY = isLeftSide ? -tan(-xAngle) : tan(xAngle);
        mathY = mathY.clamp(-6.0, 6.0);

        final adjustedBaseY = startY - (adjustedProgress * verticalDistance);
        final adjustedTargetY = adjustedBaseY - (mathY * curveIntensity);

        // 🔹 Centered path calculation with increased spread
        final double horizontalOffset = horizontalDistance * adjustedProgress;
        final pathCenter =
            isLeftSide ? startX - horizontalOffset : startX + horizontalOffset;

        // Reactive opacity
        final fadeIn = Curves.easeIn.transform(
          (adjustedProgress * 2).clamp(0.0, 1.0),
        );
        final fadeOut =
            1 -
            Curves.easeOut.transform(
              ((adjustedProgress - 0.5) * 2).clamp(0.0, 1.0),
            );
        final double opacity = (adjustedProgress <= 0.5) ? fadeIn : fadeOut;

        // Scale & rotation
        final scale = ui.lerpDouble(0.7, 1.0, opacity)!;
        final rotation = (1.0 - adjustedProgress) * (isLeftSide ? -0.12 : 0.12);

        // Final positions
        final double finalLeftPosition = pathCenter - widgetHalfWidth;
        final double smoothY = adjustedTargetY + 60 * (1 - adjustedProgress);

        return Positioned(
          left: finalLeftPosition,
          top: smoothY - 100,
          child: IgnorePointer(
            ignoring: opacity < 0.95,
            child: Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..scale(scale)
                    ..rotateZ(rotation),
              child: _buildAnimatedContainer(isLeftSide, opacity),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedContainer(bool isLeftSide, double opacity) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    // 🔹 Responsive container dimensions
    double containerWidth = sw * 0.35; // 35% of screen width
    double containerHeight = sh * 0.25; // 25% of screen height
    final iconSize = sh * 0.08;
    final titleFontSize = sh * 0.03; // 3% of screen height
    final subtitleFontSize = sh * 0.017; // 1.7% of screen height
    final spacing1 = sh * 0.02; // spacing between icon and title
    final spacing2 = sh * 0.01; // spacing between title and subtitle

    return Opacity(
      opacity: opacity, // directly reactive
      child: InkWell(
        onHover: (hover) {
          if (hover) {
            setState(() {
              containerWidth *= 0.1;
            });
          } else {
            setState(() {
              containerWidth = sw * 0.35;
            });
          }
        },

        child: Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isLeftSide ? Colors.blue : Colors.orange).withOpacity(
                  0.3 * opacity,
                ),
                blurRadius: 5.0,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isLeftSide
                    ? Colors.blue.withOpacity(0.8 * opacity)
                    : Colors.orange.withOpacity(0.8 * opacity),
                isLeftSide
                    ? Colors.blue.withOpacity(0.4 * opacity)
                    : Colors.orange.withOpacity(0.4 * opacity),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2 * opacity),
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLeftSide ? Icons.code : Icons.design_services,
                  color: Colors.white.withOpacity(opacity),
                  size: iconSize,
                ),
                SizedBox(height: spacing1),
                Text(
                  isLeftSide ? 'Development' : 'Design',
                  style: TextStyle(
                    color: Colors.white.withOpacity(opacity),
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing2),
                ElevatedButton(
                  onPressed: () {
                    print("Hello World");
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.green),
                  ),
                  child: Text(
                    isLeftSide ? 'Building Solutions' : 'Creating Experiences',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8 * opacity),
                      fontSize: subtitleFontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- CANVAS PAINTER -----------------
class FramePainter extends CustomPainter {
  final List<ui.Image?> frames;
  final int currentIndex;

  FramePainter(this.frames, this.currentIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final frame = (currentIndex < frames.length) ? frames[currentIndex] : null;
    if (frame == null) return;

    final paint = Paint()..filterQuality = FilterQuality.low;
    final rect = Offset.zero & size;

    canvas.drawImageRect(
      frame,
      Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble()),
      rect,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant FramePainter oldDelegate) =>
      oldDelegate.currentIndex != currentIndex || oldDelegate.frames != frames;
}
