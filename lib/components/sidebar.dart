import 'dart:math' as math;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class Sidebar extends StatefulComponent {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  String _path1 = '';
  String _path2 = '';
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _generatePaths();
  }

  void _generatePaths() {
    final h = 1000.0;
    final w = 100.0; // Use a smaller width scale so +/- 15 units is significant
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

      // Add stronger horizontal randomness for the "hand-drawn" look
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
    final points = _wobblyLine(x1, y1, x2, y2);
    return _pointsToPath(points);
  }

  @override
  Component build(BuildContext context) {
    final navItems = [
      (label: 'Home', href: '/', icon: _HomeIcon()),
      (label: 'Projects', href: '#projects', icon: _ProjectsIcon()),
      (label: 'Experience', href: '#experience', icon: _ExpIcon()),
      (label: 'Skills', href: '#skills', icon: _SkillsIcon()),
    ];

    return aside(classes: 'sidebar', [
      div(classes: 'sidebar-profile', [
        div(classes: 'profile-img-box', [
          img(src: '/assets/achiket.png', alt: 'Achiket Kumar'),
        ]),
        h3(classes: 'profile-name', [.text('Achiket Kumar')]),
        p(classes: 'profile-sub', [.text('Dev Lab Journal v1.0')]),
      ]),
      nav(classes: 'sidebar-nav', [
        for (final item in navItems)
          a(
            href: item.href,
            classes: 'nav-item',
            [
              span(classes: 'nav-icon', [item.icon]),
              span(classes: 'nav-label', [.text(item.label)]),
            ],
          ),
      ]),
      div(classes: 'sidebar-footer', [
        p(classes: 'footer-quote', [.text('"Code is just structured sketching."')]),
      ]),
      svg(
        classes: 'sidebar-border-svg',
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
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.sidebar').styles(
      width: 260.px,
      height: 100.vh,
      position: .fixed(left: 0.px, top: 0.px),
      backgroundColor: const Color('var(--bg)'),
      padding: .symmetric(vertical: 2.rem, horizontal: 1.5.rem),
      display: .flex,
      flexDirection: .column,
      zIndex: ZIndex(101),
      raw: {
        'overflow': 'visible',
      },
    ),
    css('.sidebar-border-svg').styles(
      position: Position.absolute(top: .zero, right: (-30).px),
      width: 60.px,
      height: 100.percent,
      raw: {
        'pointer-events': 'none',
        'overflow': 'visible',
        'z-index': '110',
      },
    ),
    css('.sidebar-profile').styles(
      textAlign: .center,
      margin: Spacing.only(bottom: 3.rem),
    ),
    css('.profile-img-box').styles(
      width: 90.px,
      height: 90.px,
      margin: .symmetric(horizontal: .auto, vertical: .zero),
      padding: .all(5.px),
      raw: {
        'border': '2px solid var(--accent)',
        'clip-path': 'var(--chaos-path-2)',
        'border-radius': 'var(--chaos-radius-1)',
        'background': 'var(--accent-dim)',
      },
    ),
    css('.profile-img-box img').styles(
      width: 100.percent,
      height: 100.percent,
      raw: {
        'object-fit': 'cover',
        'clip-path': 'var(--chaos-path-3)',
        'border-radius': 'var(--chaos-radius-2)',
        'filter': 'grayscale(100%) contrast(1.1)',
      },
    ),
    css('.profile-name').styles(
      fontSize: 1.3.rem,
      margin: Spacing.only(top: 1.2.rem, bottom: 0.3.rem),
      color: const Color('var(--accent)'),
    ),
    css('.profile-sub').styles(
      fontSize: 0.85.rem,
      color: const Color('var(--text-muted)'),
    ),
    css('.sidebar-nav').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 0.8.rem),
      flex: Flex(grow: 1),
    ),
    css('.nav-item').styles(
      display: .flex,
      alignItems: .center,
      gap: Gap(column: 1.rem),
      padding: .symmetric(horizontal: 1.rem, vertical: 0.8.rem),
      color: const Color('var(--text)'),
      raw: {
        'transition': 'all 0.2s',
        'border': '1px solid transparent',
      },
    ),
    css('.nav-item:hover').styles(
      color: const Color('var(--accent)'),
      raw: {
        'border': '1.5px solid var(--accent)',
        'clip-path': 'var(--chaos-path-1)',
        'border-radius': 'var(--chaos-radius-3)',
        'background-color': 'var(--accent-dim)',
      },
    ),
    css('.nav-icon').styles(
      width: 24.px,
      height: 24.px,
      display: .flex,
      alignItems: .center,
      justifyContent: .center,
    ),
    css('.nav-icon svg').styles(
      width: 20.px,
      height: 20.px,
      raw: {'stroke': 'currentColor', 'fill': 'none'},
    ),
    css('.nav-label').styles(
      fontSize: 1.rem,
      fontWeight: .w500,
      letterSpacing: 1.px,
    ),
    css('.sidebar-footer').styles(
      margin: Spacing.only(top: .auto),
      padding: .all(1.2.rem),
      raw: {
        'border': '2px solid var(--border)',
        'clip-path': 'var(--chaos-path-3)',
        'border-radius': 'var(--chaos-radius-2)',
      },
    ),
    css('.footer-quote').styles(
      fontSize: 0.85.rem,
      color: const Color('var(--text-muted)'),
      textAlign: .center,
      fontStyle: .italic,
      lineHeight: 1.3.rem,
    ),
    css.media(MediaQuery.screen(maxWidth: 1024.px), [
      css('.sidebar').styles(display: .none),
    ]),
  ];
}

class _HomeIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) =>
      svg([path(d: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z', [])], attributes: {'viewBox': '0 0 24 24'});
}

class _ProjectsIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    [
      path(d: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z', []),
      path(d: 'M14 2v6h6', []),
      path(d: 'M16 13H8', []),
      path(d: 'M16 17H8', []),
      path(d: 'M10 9H8', []),
    ],
    attributes: {'viewBox': '0 0 24 24'},
  );
}

class _ExpIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    [
      path(d: 'M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z', []),
    ],
    attributes: {'viewBox': '0 0 24 24'},
  );
}

class _SkillsIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    [
      path(d: 'M13 2L3 14h9l-1 8 10-12h-9l1-8z', []),
    ],
    attributes: {'viewBox': '0 0 24 24'},
  );
}
