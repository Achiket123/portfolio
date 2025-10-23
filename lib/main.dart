import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Note: Assuming these external packages and local files are available in your project structure:
import 'package:typing_text/typing_text.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// -----------------------------------------------------------------------------
// MOCK/DEPENDENCY CLASSES (Included for completeness)
// -----------------------------------------------------------------------------

class Project {
  final String title;
  final String description;
  final String github;
  final String deployedUrl;

  const Project({
    required this.title,
    required this.description,
    required this.github,
    required this.deployedUrl,
  });
}

class ContributionClass {
  final String repoName;
  final String repoUrl;
  final String description;
  final String prLink;

  const ContributionClass({
    required this.repoName,
    required this.repoUrl,
    required this.description,
    required this.prLink,
  });
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}

class AnimatedContainerPainter extends CustomPainter {
  final bool isLeftSide;
  final double opacity;
  final double containerWidth;
  final double containerHeight;

  AnimatedContainerPainter({
    required this.isLeftSide,
    required this.opacity,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Mock implementation for demo. In a real app, this would draw the complex shape/lines.
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.15 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant AnimatedContainerPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class CardPainter extends CustomPainter {
  final int seed;

  CardPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    // Mock implementation for demo. In a real app, this would draw the complex card background.
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CardPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

// -----------------------------------------------------------------------------
// MAIN IMPLEMENTATION
// -----------------------------------------------------------------------------

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
      prLink: 'https://github.com/theopenlane/riverboat/pulls/Achiket123',
    ),
    const ContributionClass(
      repoName: 'sysadminsmedia/homebox',
      repoUrl: 'https://github.com/sysadminsmedia/homebox',
      description:
          'fix(i18n): fallback to English for missing or empty translations',
      prLink: 'https://github.com/sysadminsmedia/homebox/pull/864',
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
      prLink: 'https://github.com/Prateek9876/NagarVikas/issues',
    ),
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
        'assets/frames/frame_${(index + 1).toString().padLeft(4, '0')}.webp';
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
                    NotificationListener<ScrollNotification>(
                      onNotification: (_) => false,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          // Increased height to accommodate 4 more sections and transitions
                          height: screenHeight * 15,
                          color: Colors.transparent,
                        ),
                      ),
                    ),
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
                    const _StaticBlurOverlay(sigmaX: 5, sigmaY: 5),
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
                                Positioned(
                                  top: screenHeight * 0.3,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Opacity(
                                        opacity:
                                            ui.lerpDouble(
                                              1.0,
                                              0.0,
                                              (progress * 2).clamp(0.0, 1.0),
                                            )!,
                                        child: Transform.scale(
                                          scale:
                                              ui.lerpDouble(
                                                1.0,
                                                0.9,
                                                nameT.clamp(0.0, 1.0),
                                              )!,
                                          child: const Text(
                                            "ACHIKET KUMAR",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 60,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
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
                                                    fontWeight: FontWeight.w400,
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
                                                              Alignment.center,
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
                        // Increased delay for the black screen fade-in (was 0.60 to 0.65)
                        const double fadeStart = 0.65;
                        const double fadeEnd = 0.70;
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

                    // --- START: New Sliding Sections for sequential flow ---

                    // Open Source: Enters: 0.70 to 0.74. Exits: 0.74 to 0.78.
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        const double sectionStart = 0.70;
                        const double sectionExitStart = 0.74;
                        const double sectionEnd = 0.78;

                        if (progress < sectionStart)
                          return const SizedBox.shrink();

                        final slideInT = ((progress - sectionStart) /
                                (sectionExitStart - sectionStart))
                            .clamp(0.0, 1.0);
                        final slideOutT = ((progress - sectionExitStart) /
                                (sectionEnd - sectionExitStart))
                            .clamp(0.0, 1.0);

                        return Positioned.fill(
                          child: _buildSlidingSection(
                            screenWidth,
                            screenHeight,
                            section: 'open_source',
                            slideInProgress: slideInT,
                            slideOutProgress: slideOutT,
                          ),
                        );
                      },
                    ),

                    // Work Experience: Enters: 0.78 to 0.82. Exits: 0.82 to 0.86.
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        const double sectionStart = 0.78;
                        const double sectionExitStart = 0.82;
                        const double sectionEnd = 0.86;

                        if (progress < sectionStart)
                          return const SizedBox.shrink();

                        final slideInT = ((progress - sectionStart) /
                                (sectionExitStart - sectionStart))
                            .clamp(0.0, 1.0);
                        final slideOutT = ((progress - sectionExitStart) /
                                (sectionEnd - sectionExitStart))
                            .clamp(0.0, 1.0);

                        return Positioned.fill(
                          child: _buildSlidingSection(
                            screenWidth,
                            screenHeight,
                            section: 'work_experience',
                            slideInProgress: slideInT,
                            slideOutProgress: slideOutT,
                          ),
                        );
                      },
                    ),

                    // Blogs: Enters: 0.86 to 0.90. Exits: 0.90 to 0.94.
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        const double sectionStart = 0.86;
                        const double sectionExitStart = 0.90;
                        const double sectionEnd = 0.94;

                        if (progress < sectionStart)
                          return const SizedBox.shrink();

                        final slideInT = ((progress - sectionStart) /
                                (sectionExitStart - sectionStart))
                            .clamp(0.0, 1.0);
                        final slideOutT = ((progress - sectionExitStart) /
                                (sectionEnd - sectionExitStart))
                            .clamp(0.0, 1.0);

                        return Positioned.fill(
                          child: _buildSlidingSection(
                            screenWidth,
                            screenHeight,
                            section: 'blogs',
                            slideInProgress: slideInT,
                            slideOutProgress: slideOutT,
                          ),
                        );
                      },
                    ),

                    // Contact: Enters: 0.94 to 1.0. Stays pinned.
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, progress, _) {
                        const double sectionStart = 0.94;

                        if (progress < sectionStart)
                          return const SizedBox.shrink();

                        final slideInT = ((progress - sectionStart) /
                                (1.0 - sectionStart))
                            .clamp(0.0, 1.0);

                        // No slide-out phase for the final section
                        return Positioned.fill(
                          child: _buildSlidingSection(
                            screenWidth,
                            screenHeight,
                            section: 'contact',
                            slideInProgress: slideInT,
                            slideOutProgress: 0.0,
                          ),
                        );
                      },
                    ),

                    // --- END: New Sliding Sections Logic ---
                  ],
                ),
              )
              : const Center(child: LoadingWidget()),
    );
  }

  // New unified section builder to handle slide in and slide out
  Widget _buildSlidingSection(
    double screenWidth,
    double screenHeight, {
    required String section,
    required double slideInProgress,
    required double slideOutProgress,
  }) {
    // 1. Determine which content widget to build (using renamed content getters)
    Widget content;
    switch (section) {
      case 'open_source':
        content = _getOpenSourceContent(screenWidth, slideInProgress);
        break;
      case 'work_experience':
        content = _getWorkExperienceContent(screenWidth, slideInProgress);
        break;
      case 'blogs':
        content = _getBlogsContent(screenWidth, slideInProgress);
        break;
      case 'contact':
        content = _getContactContent(screenWidth, slideInProgress);
        break;
      default:
        return const SizedBox.shrink();
    }

    // 2. Calculate Vertical Translation
    // Slide in: screenHeight (off-screen bottom) -> 0.0 (center/pinned position)
    final double slideInCurve = Curves.easeOutCubic.transform(slideInProgress);
    double translationY = ui.lerpDouble(screenHeight, 0.0, slideInCurve)!;

    // Slide out: 0.0 (center/pinned position) -> -screenHeight (off-screen top)
    if (slideOutProgress > 0.0) {
      final double slideOutCurve = Curves.easeInCubic.transform(
        slideOutProgress,
      );
      // Overwrite translation to slide out from the pinned position (0.0)
      translationY = ui.lerpDouble(0.0, -screenHeight, slideOutCurve)!;
    }

    // 3. Calculate Opacity
    double opacity = 1.0;
    // Fade in while sliding in
    if (slideInProgress < 1.0) {
      opacity = slideInCurve;
    }
    // Fade out while sliding out
    if (slideOutProgress > 0.0) {
      // Use the inverse of slideOutProgress to control opacity
      opacity = 1.0 - slideOutProgress;
    }

    // Ensure content disappears when it's supposed to be off-screen
    final bool ignoring = opacity < 0.01;

    // 4. Return the translated and opaque content
    return IgnorePointer(
      ignoring: ignoring,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, translationY),
          child: content,
        ),
      ),
    );
  }

  // Refactored helper function for Open Source Content
  Widget _getOpenSourceContent(
    double screenWidth,
    double progress, // Now receives slideInProgress
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rocket_launch, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          const Text(
            "OPEN SOURCE CONTRIBUTIONS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: openSourceContributions.length,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              itemBuilder: (context, index) {
                // Staggered animation for each card uses the progress
                final cardDelay = index * 0.1;
                final cardProgress = (progress - cardDelay).clamp(0.0, 1.0);
                final cardOpacity = Curves.easeOut.transform(cardProgress);

                // Slide from right (horizontal entrance animation)
                final slideOffset = (1 - cardProgress) * 100;

                return Padding(
                  padding: EdgeInsets.only(left: slideOffset, right: 20),
                  child: Opacity(
                    opacity: cardOpacity,
                    child: _buildOpenSourceCard(openSourceContributions[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Refactored helper function for Work Experience Content
  Widget _getWorkExperienceContent(
    double screenWidth,
    double progress, // Now receives slideInProgress
  ) {
    final experiences = [
      {
        'company': 'Tech Corp',
        'role': 'Senior Flutter Developer',
        'duration': '2023 - Present',
        'description': 'Leading mobile app development team',
      },
      {
        'company': 'StartupXYZ',
        'role': 'Full Stack Developer',
        'duration': '2021 - 2023',
        'description': 'Built scalable microservices with Go',
      },
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work_outline, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          const Text(
            "WORK EXPERIENCE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ...experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            final cardDelay = index * 0.15;
            final cardProgress = (progress - cardDelay).clamp(0.0, 1.0);
            final cardOpacity = Curves.easeOut.transform(cardProgress);
            // Slide from left (internal entrance animation)
            final slideOffset = (1 - cardProgress) * 50;

            return Padding(
              padding: EdgeInsets.only(bottom: 20, left: slideOffset),
              child: Opacity(
                opacity: cardOpacity,
                child: Container(
                  width: screenWidth * 0.6,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp['role']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${exp['company']} • ${exp['duration']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        exp['description']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Refactored helper function for Blogs Content
  Widget _getBlogsContent(
    double screenWidth,
    double progress, // Now receives slideInProgress
  ) {
    final blogs = [
      {
        'title': 'Building Scalable Flutter Apps',
        'date': 'Oct 2024',
        'url': 'https://yourblog.com/flutter-scalable',
      },
      {
        'title': 'Microservices with Go',
        'date': 'Sep 2024',
        'url': 'https://yourblog.com/go-microservices',
      },
      {
        'title': 'State Management Best Practices',
        'date': 'Aug 2024',
        'url': 'https://yourblog.com/state-management',
      },
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.article_outlined, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          const Text(
            "MY BLOGS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: blogs.length,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              itemBuilder: (context, index) {
                final blog = blogs[index];
                final cardDelay = index * 0.1;
                final cardProgress = (progress - cardDelay).clamp(0.0, 1.0);
                final cardOpacity = Curves.easeOut.transform(cardProgress);
                final slideOffset = (1 - cardProgress) * 100;

                return Padding(
                  padding: EdgeInsets.only(left: slideOffset, right: 20),
                  child: Opacity(
                    opacity: cardOpacity,
                    child: InkWell(
                      onTap: () => _launchURL(blog['url']!),
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              blog['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              blog['date']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            const Row(
                              children: [
                                Text(
                                  'Read More',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Refactored helper function for Contact Content
  Widget _getContactContent(
    double screenWidth,
    double progress, // Now receives slideInProgress
  ) {
    final socials = [
      {
        'icon': Icons.code,
        'name': 'GitHub',
        'url': 'https://github.com/Achiket123',
      },
      {
        'icon': Icons.work,
        'name': 'LinkedIn',
        'url': 'https://linkedin.com/in/achiket-kumar',
      },
      {
        'icon': Icons.language,
        'name': 'Twitter',
        'url': 'https://twitter.com/achiket',
      },
      {
        'icon': Icons.email,
        'name': 'Email',
        'url': 'mailto:achiket@example.com',
      },
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.connect_without_contact,
            color: Colors.white,
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            "GET IN TOUCH",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Let's build something amazing together",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          // Resume Download Button
          ElevatedButton.icon(
            onPressed:
                () => _launchURL(
                  'https://drive.google.com/file/d/YOUR_RESUME_ID/view',
                ),
            icon: const Icon(Icons.download),
            label: const Text('Download Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "CONNECT WITH ME",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Social Icons
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children:
                socials.asMap().entries.map((entry) {
                  final index = entry.key;
                  final social = entry.value;
                  final iconDelay = index * 0.1;
                  final iconProgress = (progress - iconDelay).clamp(0.0, 1.0);
                  final iconOpacity = Curves.easeOut.transform(iconProgress);
                  final scale = ui.lerpDouble(0.5, 1.0, iconProgress)!;

                  return Opacity(
                    opacity: iconOpacity,
                    child: Transform.scale(
                      scale: scale,
                      child: InkWell(
                        onTap: () => _launchURL(social['url']! as String),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                social['icon']! as IconData,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                social['name']! as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 60),
          Text(
            "© 2024 Achiket Kumar. All rights reserved.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenSourceCard(ContributionClass contribution) {
    const double cardWidth = 280;
    const double cardHeight = 120;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        onTap: () => _launchURL(contribution.prLink),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(cardWidth, cardHeight),
              painter: CardPainter(contribution.repoName.hashCode),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
          // Replaced the generic Transform with Matrix4.identity() with two simpler, specialized Transforms
          // for potential performance benefits.
          child: Transform.rotate(
            angle: rotation,
            alignment: Alignment.center,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                child: _buildAnimatedContainer(
                  isLeftSide,
                  opacity,
                  projects[index],
                ),
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
                    onPressed: () => _launchURL(project.github),
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
