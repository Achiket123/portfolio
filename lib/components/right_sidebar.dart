import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:portfolio/config.dart';
import 'package:portfolio/models/blog_post.dart';

import '../constants/mock_data.dart';
import '../models/portfolio_data.dart';
import 'sketch_box.dart';

class RightSidebar extends StatefulComponent {
  const RightSidebar({super.key});

  @override
  State<RightSidebar> createState() => RightSidebarState();
}

class RightSidebarState extends State<RightSidebar> {
  String _path1 = '';
  String _path2 = '';
  final _random = math.Random();
  PortfolioData? _data;

  // final List<Map<String, String>> _staticPosts = [

  //   {'type': 'THOUGHT', 'content': '"Code is just structured sketching." - A reminder for today.', 'date': '3d ago'},
  // ];

  @override
  void initState() {
    super.initState();
    _generatePaths();
    if (kIsWeb) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.portfolio)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _data = PortfolioData.fromJson(decoded);
        });
        return;
      }
    } catch (e) {
      print('Sidebar API fetch failed: $e');
    }

    try {
      setState(() {
        _data = PortfolioData.fromJson(mockPortfolioData);
      });
    } catch (e) {
      print('Sidebar mock data fallback failed: $e');
    }
  }

  void _generatePaths() {
    final h = 1000.0;
    final w = 100.0;
    _path1 = _createVerticalLine(w / 2, -20, w / 2, h + 20);
    _path2 = _createVerticalLine(w / 2, -20, w / 2, h + 20);
  }

  double _rand(double min, double max) {
    return _random.nextDouble() * (max - min) + min;
  }

  List<math.Point<double>> _wobblyLine(double x1, double y1, double x2, double y2, {int segments = 25}) {
    final points = <math.Point<double>>[];
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      var x = x1 + (x2 - x1) * t;
      var y = y1 + (y2 - y1) * t;
      x += _rand(-15, 15);
      y += _rand(-5, 5);
      points.add(math.Point(x, y));
    }
    return points;
  }

  String _pointsToPath(List<math.Point<double>> points) {
    if (points.isEmpty) return '';
    var d = 'M ${points[0].x} ${points[0].y}';
    for (var i = 1; i < points.length - 1; i++) {
      final xc = (points[i].x + points[i + 1].x) / 2;
      final yc = (points[i].y + points[i + 1].y) / 2;
      d += ' Q ${points[i].x} ${points[i].y} $xc $yc';
    }
    d += ' L ${points.last.x} ${points.last.y}';
    return d;
  }

  String _createVerticalLine(double x1, double y1, double x2, double y2) {
    return _pointsToPath(_wobblyLine(x1, y1, x2, y2));
  }

  String _truncate(String text, {int maxWords = 15}) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}...';
  }

  @override
  Component build(BuildContext context) {
    final List<Map<String, String>> displayPosts = [];

    // Add latest tweet if available

    for (final BlogPostList post in _data?.blog ?? []) {
      displayPosts.add({
        'type': 'Blog',
        'content': _truncate(post.description),
        'date': post.date,
        'slug': post.slug,
      });
    }
    if (_data != null && _data!.twitter.isNotEmpty) {
      // Sort tweets by date descending (latest first)
      final sortedTweets = List<Tweet>.from(_data!.twitter)
        ..sort((tweetA, tweetB) {
          try {
            return DateTime.parse(tweetB.date).compareTo(DateTime.parse(tweetA.date));
          } catch (_) {
            return 0;
          }
        });

      final latestTweet = sortedTweets.first;
      displayPosts.add({
        'type': 'TWITTER',
        'content': _truncate(latestTweet.text),
        'date': latestTweet.date,
      });
    }

    return aside(classes: 'right-sidebar', [
      svg(
        classes: 'sidebar-left-border-svg',
        attributes: {
          'viewBox': '0 0 100 1000',
          'preserveAspectRatio': 'none',
        },
        [
          path(
            d: _path1,
            attributes: {
              'stroke': 'var(--text)',
              'fill': 'none',
              'stroke-width': '2.5',
              'vector-effect': 'non-scaling-stroke',
            },
            [],
          ),
          path(
            d: _path2,
            attributes: {
              'stroke': 'var(--text)',
              'fill': 'none',
              'stroke-width': '1.5',
              'opacity': '0.5',
              'vector-effect': 'non-scaling-stroke',
            },
            [],
          ),
        ],
      ),
      h3(classes: 'sidebar-title', [.text('LOGBOOK_')]),
      div(classes: 'posts-feed', [
        for (final post in displayPosts)
          SketchBox(
            classes: 'post-card',
            padding: '1rem',
            children: [
              div(classes: 'post-header', [
                span(classes: 'post-type', [.text(post['type']!)]),
                span(classes: 'post-date', [.text(post['date']!)]),
              ]),
              p(classes: 'post-content', [.text(post['content']!)]),
              if (post['slug'] != null)
                a(
                  href: '/blog/${post['slug']}',
                  classes: 'sketch-btn',
                  [
                    span([.text('Read More')]),
                  ],
                ),
            ],
          ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.right-sidebar').styles(
      backgroundColor: const Color('var(--bg)'),
      display: .flex,
      flexDirection: .column,
      height: 100.vh,
      padding: .symmetric(vertical: 2.rem, horizontal: 1.5.rem),
      position: .fixed(right: 0.px, top: 0.px),
      width: 260.px,
      zIndex: ZIndex(101),
      raw: {
        'overflow': 'visible',
      },
    ),
    css('.sidebar-left-border-svg').styles(
      height: 100.percent,
      position: Position.absolute(top: .zero, left: (-30).px),
      width: 60.px,
      raw: {
        'overflow': 'visible',
        'pointer-events': 'none',
        'z-index': '110',
      },
    ),
    css('.sidebar-title').styles(
      color: const Color('var(--accent)'),
      fontSize: 1.5.rem,
      letterSpacing: 2.px,
      margin: Margin.only(bottom: 2.rem),
      textAlign: .center,
    ),
    css('.posts-feed').styles(
      display: .flex,
      flex: Flex(grow: 1),
      flexDirection: .column,
      gap: Gap(row: 1.5.rem),
      raw: {
        '-ms-overflow-style': 'none',
        'overflow-y': 'auto',
        'scrollbar-width': 'none',
      },
    ),
    css('.posts-feed::-webkit-scrollbar').styles(
      display: .none,
    ),
    css('.post-card').styles(
      raw: {
        'background': 'var(--bg-card)',
      },
    ),
    css('.post-header').styles(
      alignItems: .center,
      display: .flex,
      justifyContent: .spaceBetween,
      margin: Margin.only(bottom: 0.5.rem),
    ),
    css('.post-type').styles(
      backgroundColor: const Color('var(--accent)'),
      color: const Color('var(--bg)'),
      fontFamily: const .list([FontFamily('Special Elite')]),
      fontSize: 0.7.rem,
      fontWeight: .w700,
      padding: .symmetric(horizontal: 0.4.rem, vertical: 0.1.rem),
    ),
    css('.post-date').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.65.rem,
    ),
    css('.post-content').styles(
      fontSize: 0.85.rem,
      lineHeight: 1.3.rem,
      margin: .zero,
    ),
    css.media(MediaQuery.screen(maxWidth: 1024.px), [
      css('.right-sidebar').styles(display: .none),
    ]),
  ];
}
