import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/data/contribution_class.dart';
import 'package:portfolio/data/project_class.dart';
import 'package:portfolio/loading_widget.dart';
import 'package:typing_text/typing_text.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'animated_container_paint.dart';
import 'card_painter.dart';

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
  final List<Project> pinnedProjects = [
    const Project(
      title: 'dost',
      description:
          'An autonomous AI agent for streamlining software development workflows.',
      github: 'https://github.com/Achiket123/dost',
      deployedUrl: '',
    ),
    const Project(
      title: 'mushin',
      description:
          'A productivity app promoting digital wellness by controlling app access.',
      github: 'https://github.com/Achiket123/mushin',
      deployedUrl: '',
    ),
    const Project(
      title: 'shazam',
      description:
          'A lightweight Go backend for music recognition, inspired by Shazam.',
      github: 'https://github.com/Achiket123/shazam',
      deployedUrl: '',
    ),
    const Project(
      title: 'soundsalike',
      description:
          'An open-source backend for music recognition using audio fingerprinting.',
      github: 'https://github.com/Achiket123/soundsalike',
      deployedUrl: '',
    ),
    const Project(
      title: 'chatbot',
      description:
          'A Flutter chatbot application integrated with the Gemini API.',
      github: 'https://github.com/Achiket123/chatbot',
      deployedUrl: '',
    ),
    const Project(
      title: 'c-text-editor',
      description:
          'A terminal-based text editor built from scratch in C, inspired by Vim.',
      github: 'https://github.com/Achiket123/c-text-editor',
      deployedUrl: '',
    ),
  ];

  final List<ContributionClass> openSourceContributions = [
    const ContributionClass(
      repoName: 'theopenlane/riverboat',
      repoUrl: 'https://github.com/theopenlane/riverboat',
      description: 'Add Slack job integration and worker',
      prLink:
          'https://github.com/theopenlane/riverboat/pulls/Achiket123', // NOTE: Using a general PR link as the specific number isn't visible
    ),
    const ContributionClass(
      repoName: 'sysadminsmedia/homebox',
      repoUrl: 'https://github.com/sysadminsmedia/homebox',
      description:
          'fix(i18n): fallback to English for missing or empty translations',
      prLink:
          'https://github.com/sysadminsmedia/homebox/pull/864', // PR number #864 is visible
    ),
    const ContributionClass(
      repoName: 'AzureAD/microsoft-authentication-library-for-go',
      repoUrl:
          'https://github.com/AzureAD/microsoft-authentication-library-for-go',
      description: 'Contributed to authentication library for Go',
      prLink:
          'https://github.com/AzureAD/microsoft-authentication-library-for-go/pulls/Achiket123',
    ),
    const ContributionClass(
      repoName: 'Prateek9876/NagarVikas',
      repoUrl: 'https://github.com/Prateek9876/NagarVikas',
      description: 'Created issue for Localization Feature',
      prLink:
          'https://github.com/Prateek9876/NagarVikas/issues', // This was an issue, linking to issues page
    ),
  ];
  final List<String> _skills = const [
    "Flutter",
    "Dart",
    "GoLang",
    "Node.js",
    "REST APIs",
    "Firebase",
    "Docker",
    "Microservices",
    "UI/UX",
    "Git",
    "State Management",
    "Web Sockets",
  ];
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

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
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
              ? Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    // Manually scroll the background scroll view
                    _scrollController.jumpTo(
                      (_scrollController.offset + event.scrollDelta.dy).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                    );
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  children: [
                    // This scroll view MUST be at the bottom of the stack to receive
                    // gestures that pass through the layers above it.
                    NotificationListener<ScrollNotification>(
                      onNotification: (_) => false,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: screenHeight * 10,
                          color: Colors.transparent,
                        ),
                      ),
                    ),

                    // ✅ FIX: Wrap the purely visual background layers in IgnorePointer.
                    // This allows scroll and tap gestures to pass through them to the
                    // widgets underneath (the scroll view and the interactive cards).
                    IgnorePointer(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _currentFrameNotifier,
                        builder: (context, frameIndex, _) {
                          return CustomPaint(
                            size: Size(screenWidth, screenHeight),
                            painter: FramePainter(_decodedFrames, frameIndex),
                          );
                        },
                      ),
                    ),

                    // The blur overlay is already correctly wrapped in IgnorePointer.
                    const _StaticBlurOverlay(sigmaX: 5, sigmaY: 5),

                    // This text/title overlay is also correctly wrapped in IgnorePointer.
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
                                Transform(
                                  transform:
                                      Matrix4.identity()..translate(
                                        0.0,
                                        ui.lerpDouble(
                                          0,
                                          -screenHeight / 5,
                                          nameT.clamp(0.0, 1.0),
                                        )!,
                                      ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale:
                                            ui.lerpDouble(
                                              1.0,
                                              0.9,
                                              nameT.clamp(0.0, 1.0),
                                            )!,
                                        child: Text(
                                          "ACHIKET KUMAR",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 60,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Opacity(
                                        opacity:
                                            ui.lerpDouble(
                                              1.0,
                                              0.0,
                                              nameT.clamp(0.0, 1.0),
                                            )!,
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            ui.lerpDouble(
                                              0,
                                              -80,
                                              nameT.clamp(0.0, 1.0),
                                            )!,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: RichText(
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      letterSpacing: 1.2,
                                                    ),
                                                    children: [
                                                      const TextSpan(
                                                        text: "A passionate ",
                                                      ),
                                                      WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: IntrinsicWidth(
                                                          child: Align(
                                                            alignment:
                                                                Alignment
                                                                    .center,
                                                            child: TypingText(
                                                              words: const [
                                                                "Flutter Dev",
                                                                "Go Dev",
                                                                "Blogger",
                                                              ],
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.85,
                                                                    ),
                                                                fontSize: 22,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                letterSpacing:
                                                                    1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                width: 500,
                                                child: Text(
                                                  "I am Achiket Kumar, a highly motivated and skilled Full Stack Developer, with a passion for building robust, scalable applications. My experience is centered around the Flutter framework for mobile and web development, complemented by a strong backend foundation in Node.js and emerging proficiency in GoLang, which I proactively sought to learn for microservice development.",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.75),
                                                    fontSize: 16,
                                                    height: 1.4,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: Curves.easeInOut.transform(
                                          projectsT,
                                        ),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        return _buildTanPathWidgets(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          progress: progress,
                          isLeftSide: true,
                          projects: pinnedProjects.sublist(3, 6),
                        );
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        return _buildTanPathWidgets(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          progress: progress,
                          isLeftSide: false,
                          projects: pinnedProjects.sublist(0, 3),
                        );
                      },
                    ),

                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        const double fadeStart = 0.90;
                        const double fadeEnd = 1;
                        final double fadeT =
                            (progress - fadeStart) / (fadeEnd - fadeStart);
                        final double opacity = fadeT.clamp(0.0, 1.0);
                        return IgnorePointer(
                          ignoring: true,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              color: Colors.black,
                              width: screenWidth,
                              height: screenHeight,
                            ),
                          ),
                        );
                      },
                    ),

                    IgnorePointer(
                      ignoring:
                          false, // <-- CRITICAL CHANGE: Allows clicks on the cards
                      child: ValueListenableBuilder<int>(
                        valueListenable: _currentFrameNotifier,
                        builder: (context, frameIndex, _) {
                          final progress = frameIndex / max(1, totalFrames - 1);
                          // ... (rest of your animation logic is unchanged)
                          const double start = 0.90;
                          const double end = 1.0;
                          double t = 0;
                          if (progress >= start && progress <= end) {
                            t = (progress - start) / (end - start);
                          } else if (progress > end) {
                            t = 1.0;
                          }
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
                          final double cardStartOffset = 250.0;
                          final double cardSpacing = 20.0;

                          return SizedBox.expand(
                            child: Align(
                              alignment: Alignment.center,
                              child: Transform(
                                transform: transform,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          openSourceContributions.length,
                                          (index) {
                                            final contribution =
                                                openSourceContributions[index];
                                            final cardT = ((progress - 0.82) *
                                                        5 -
                                                    index * 0.1)
                                                .clamp(0.0, 1.0);
                                            final dx =
                                                cardStartOffset * (1 - cardT);
                                            final opacity = Curves.easeInOut
                                                .transform(cardT);
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
                                                      left:
                                                          index == 0
                                                              ? 0
                                                              : cardSpacing, // Add spacing between cards
                                                      right: cardSpacing,
                                                    ),
                                                    // Call the updated widget with the contribution data
                                                    child: _buildOpenSourceCard(
                                                      contribution,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
              : const Center(child: LoadingWidget()),
    );
  }

  Widget _buildOpenSourceCard(ContributionClass contribution) {
    const double cardWidth = 280; // Increased width slightly for longer names
    const double cardHeight =
        120; // Increased height for more description space

    // Helper function to launch URLs (can be moved to the State class)
    Future<void> _launchURL(String url) async {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        onTap: () => _launchURL(contribution.prLink), // Make the card clickable
        borderRadius: BorderRadius.circular(
          12,
        ), // Match splash effect to card shape
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(cardWidth, cardHeight),
              painter: CardPainter(
                contribution.repoName.hashCode,
              ), // Use hashcode for variety
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Repository Name
                  Text(
                    contribution.repoName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Contribution Description
                  Expanded(
                    child: Text(
                      contribution.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTanPathWidgets({
    required double screenWidth,
    required double screenHeight,
    required double progress,
    required bool isLeftSide,
    required List<Project> projects,
  }) {
    final double startX = screenWidth / 2;
    final double startY = screenHeight;
    final double maxAngle = pi / 2.5;
    final double horizontalDistance = screenWidth * 0.25;
    final double verticalDistance = screenHeight * 0.7;
    final double curveIntensity = screenHeight * 0.1;
    final curve = Curves.easeInOutCubic;
    final double widgetHalfWidth = screenWidth * 0.175;
    const double spacingBetweenContainers = 0.18;

    return Stack(
      children: List.generate(projects.length, (index) {
        final offset = index * spacingBetweenContainers;
        double adjustedProgress = (progress - offset).clamp(0.0, 1.0);
        if (adjustedProgress <= 0) return const SizedBox.shrink();

        adjustedProgress = curve.transform(adjustedProgress);
        final double xAngle = adjustedProgress * maxAngle;
        double mathY = isLeftSide ? -tan(-xAngle) : tan(xAngle);
        mathY = mathY.clamp(-6.0, 6.0);
        final adjustedBaseY = startY - (adjustedProgress * verticalDistance);
        final adjustedTargetY = adjustedBaseY - (mathY * curveIntensity);
        final double horizontalOffset = horizontalDistance * adjustedProgress;
        final pathCenter =
            isLeftSide ? startX - horizontalOffset : startX + horizontalOffset;
        final fadeIn = Curves.easeIn.transform(
          (adjustedProgress * 2).clamp(0.0, 1.0),
        );
        final fadeOut =
            1 -
            Curves.easeOut.transform(
              ((adjustedProgress - 0.5) * 2).clamp(0.0, 1.0),
            );
        final double opacity = (adjustedProgress <= 0.5) ? fadeIn : fadeOut;
        final scale = ui.lerpDouble(0.7, 1.0, opacity)!;
        final rotation = (1.0 - adjustedProgress) * (isLeftSide ? -0.12 : 0.12);
        final double finalLeftPosition = pathCenter - widgetHalfWidth;
        final double smoothY = adjustedTargetY + 60 * (1 - adjustedProgress);

        return Positioned(
          left: finalLeftPosition,
          top: smoothY - 100,
          child: Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..scale(scale)
                  ..rotateZ(rotation),

            child: Listener(
              behavior: HitTestBehavior.translucent,
              child: _buildAnimatedContainer(
                isLeftSide,
                opacity,
                projects[index],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedContainer(
    bool isLeftSide,
    double opacity,
    Project project,
  ) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    double containerWidth = sw * 0.35;
    double containerHeight = sh * 0.25;

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(containerWidth, containerHeight),
            painter: AnimatedContainerPainter(
              isLeftSide: isLeftSide,
              opacity: opacity,
              containerWidth: containerWidth,
              containerHeight: containerHeight,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    project.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(opacity),
                      fontSize: sh * 0.03,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: sh * 0.015),
                  Text(
                    project.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70.withOpacity(opacity * 0.7),
                      fontSize: sh * 0.015,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed:
                        () => _launchURL(
                          project.github,
                        ), // Launch the project's GitHub URL
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'View on GitHub',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9 * opacity),
                        fontSize: sh * 0.015,
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
}

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
