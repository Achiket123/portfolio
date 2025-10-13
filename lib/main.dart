import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MaterialApp(home: ScrollVideoPage()));

class ScrollVideoPage extends StatefulWidget {
  const ScrollVideoPage({super.key});

  @override
  _ScrollVideoPageState createState() => _ScrollVideoPageState();
}

class _ScrollVideoPageState extends State<ScrollVideoPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentFrameNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> _scrollFractionNotifier = ValueNotifier<double>(
    0.0,
  );

  final int totalFrames = 1500;
  final int initialFrames = 50;
  final int batchSize1 = 100;
  final int batchSize2 = 200;

  List<Uint8List> _frameBytes = [];
  bool _isInitialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    _loadFramesInBatches();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadFramesInBatches() async {
    // 1. Load the initial batch
    await _loadBatch(0, initialFrames);
    setState(() {
      _isInitialLoadComplete = true;
    });

    // 2. Load the remaining frames in the background
    await _loadBatch(initialFrames, initialFrames + batchSize1);
    await _loadBatch(
      initialFrames + batchSize1,
      initialFrames + batchSize1 + batchSize2,
    );
    // You can continue this pattern to load the rest of the frames
    await _loadBatch(initialFrames + batchSize1 + batchSize2, totalFrames);
  }

  Future<void> _loadBatch(int start, int end) async {
    for (int i = start; i < end; i++) {
      if (i >= totalFrames) break; // Ensure we don't go out of bounds
      String path =
          'assets/frames/frame_${(i + 1).toString().padLeft(4, '0')}.png';
      try {
        final ByteData data = await rootBundle.load(path);
        _frameBytes.add(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('Error loading frame $i: $e');
      }
    }
  }

  void _onScroll() {
    if (!_isInitialLoadComplete) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final newScrollFraction = (_scrollController.offset / maxScroll).clamp(
      0.0,
      1.0,
    );

    // The key change here is to map the scroll position to the *available* frames.
    final availableFrames = _frameBytes.length;
    final newFrameIndex = min(
      availableFrames - 1,
      (newScrollFraction * totalFrames).floor(),
    );

    // Update the ValueNotifiers
    _currentFrameNotifier.value = newFrameIndex;
    _scrollFractionNotifier.value = newScrollFraction;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currentFrameNotifier.dispose();
    _scrollFractionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isInitialLoadComplete
              ? Stack(
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: _currentFrameNotifier,
                    builder: (context, frameIndex, child) {
                      if (frameIndex >= _frameBytes.length) {
                        // Show a temporary blank or loading screen if frames are not yet loaded
                        return Container(color: Colors.black);
                      }
                      return Positioned.fill(
                        child: Image.memory(
                          _frameBytes[frameIndex],
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      );
                    },
                  ),
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 10,
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollFractionNotifier,
                      builder: (context, fraction, child) {
                        return LinearProgressIndicator(
                          value: fraction,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                          minHeight: 6,
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
}
