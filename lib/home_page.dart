import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _controller;
  final ScrollController _scrollController = ScrollController();

  bool _isVideoInitialized = false;
  double _scrollHeight = 5000.0;

  final ValueNotifier<double> _videoProgress = ValueNotifier<double>(0.0);
  int _scrollDirection = 0;
  Timer? _debounceTimer;
  Timer? _seekTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/bg.mp4');

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.pause();

      // Calculate scroll height based on video duration
      final durationSeconds = _controller.value.duration.inSeconds;
      _scrollHeight = durationSeconds * 100.0;

      _scrollController.addListener(_onScroll);

      setState(() => _isVideoInitialized = true);
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  void _onScroll() {
    if (!_isVideoInitialized || !_controller.value.isInitialized) return;

    final offset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (maxScroll <= 0) return;

    // Calculate the percentage scrolled (0.0 to 1.0)
    final percentScrolled = (offset / maxScroll).clamp(0.0, 1.0);

    // Determine scroll direction
    final newDirection =
        percentScrolled > _videoProgress.value
            ? 1
            : (percentScrolled < _videoProgress.value ? -1 : 0);

    if (newDirection != _scrollDirection) {
      setState(() {
        _scrollDirection = newDirection;
      });
    }

    // Update progress value (this won't cause jitter since it's just a value change)
    _videoProgress.value = percentScrolled;

    // Throttle video seeking to reduce jitter
    _seekTimer?.cancel();
    _seekTimer = Timer(const Duration(milliseconds: 50), () {
      if (!mounted || !_controller.value.isInitialized) return;

      final targetPosition = Duration(
        milliseconds:
            (percentScrolled * _controller.value.duration.inMilliseconds)
                .toInt(),
      );
      _controller.seekTo(targetPosition);
    });

    // Reset direction indicator
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _scrollDirection = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _seekTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _videoProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isVideoInitialized
              ? Stack(
                children: [
                  // Fixed video background
                  Positioned.fill(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),

                  // Scrollable transparent overlay
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: _scrollHeight,
                      color: Colors.transparent,
                    ),
                  ),

                  // Scroll direction indicator (only when scrolling)
                  if (_scrollDirection != 0)
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _scrollDirection == 1
                                  ? Colors.blue.withOpacity(0.8)
                                  : Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _scrollDirection == 1
                                  ? Icons.fast_forward
                                  : Icons.fast_rewind,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _scrollDirection == 1 ? 'Forward' : 'Backward',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Progress bar at bottom
                  Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _videoProgress,
                      builder: (context, progress, child) {
                        final position = Duration(
                          milliseconds:
                              (progress *
                                      _controller.value.duration.inMilliseconds)
                                  .toInt(),
                        );

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.duration),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _scrollDirection == 1
                                        ? Colors.blue
                                        : _scrollDirection == -1
                                        ? Colors.orange
                                        : Colors.white,
                                  ),
                                  minHeight: 6,
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
              : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
