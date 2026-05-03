import 'dart:math' as math;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
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

  final List<Map<String, String>> _posts = [
    {
      'type': 'TWITTER',
      'content': 'Just pushed a new update to the lab. Sketchy lines are now 100% more sketchy. 🎨 #buildinpublic',
      'date': '2h ago',
    },
    {
      'type': 'BLOG',
      'content': 'New Blog Post: Why I prefer wobbly lines over straight ones. It is all about the human touch.',
      'date': 'Yesterday',
    },
    {
      'type': 'LINKEDIN',
      'content': 'Excited to announce that I am exploring the intersection of creative coding and brutalist UI design.',
      'date': '2d ago',
    },
    {'type': 'THOUGHT', 'content': '"Code is just structured sketching." - A reminder for today.', 'date': '3d ago'},
  ];

  @override
  void initState() {
    super.initState();
    _generatePaths();
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

  @override
  Component build(BuildContext context) {
    return aside(classes: 'right-sidebar', [
      svg(
        classes: 'sidebar-left-border-svg',
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
        attributes: {
          'viewBox': '0 0 100 1000',
          'preserveAspectRatio': 'none',
        },
      ),
      h3(classes: 'sidebar-title', [.text('LOGBOOK_')]),
      div(classes: 'posts-feed', [
        for (final post in _posts)
          SketchBox(
            classes: 'post-card',
            padding: '1rem',
            children: [
              div(classes: 'post-header', [
                span(classes: 'post-type', [.text(post['type']!)]),
                span(classes: 'post-date', [.text(post['date']!)]),
              ]),
              p(classes: 'post-content', [.text(post['content']!)]),
            ],
          ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.right-sidebar').styles(
      width: 260.px,
      height: 100.vh,
      position: .fixed(right: 0.px, top: 0.px),
      backgroundColor: const Color('var(--bg)'),
      padding: .symmetric(vertical: 2.rem, horizontal: 1.5.rem),
      display: .flex,
      flexDirection: .column,
      zIndex: ZIndex(101),
      raw: {
        'overflow': 'visible',
      },
    ),
    css('.sidebar-left-border-svg').styles(
      position: Position.absolute(top: .zero, left: (-30).px),
      width: 60.px,
      height: 100.percent,
      raw: {
        'pointer-events': 'none',
        'overflow': 'visible',
        'z-index': '110',
      },
    ),
    css('.sidebar-title').styles(
      fontSize: 1.5.rem,
      margin: Margin.only(bottom: 2.rem),

      textAlign: .center,
      color: const Color('var(--accent)'),
      letterSpacing: 2.px,
    ),
    css('.posts-feed').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 1.5.rem),
      flex: Flex(grow: 1),
      raw: {
        'overflow-y': 'auto',
        'scrollbar-width': 'none',
        '-ms-overflow-style': 'none',
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
      display: .flex,
      justifyContent: .spaceBetween,
      alignItems: .center,

      margin: Margin.only(bottom: 0.5.rem),
    ),
    css('.post-type').styles(
      fontSize: 0.7.rem,
      fontWeight: .w700,
      padding: .symmetric(horizontal: 0.4.rem, vertical: 0.1.rem),
      backgroundColor: const Color('var(--accent)'),
      color: const Color('var(--bg)'),
      fontFamily: const .list([FontFamily('Special Elite')]),
    ),
    css('.post-date').styles(
      fontSize: 0.65.rem,
      color: const Color('var(--text-muted)'),
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
