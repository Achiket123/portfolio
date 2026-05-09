import 'dart:math' as math;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
      (label: 'Pinned Repo', href: '#pinned-repo', icon: _PinnedRepo()),
      (label: 'Github Repo', href: '#github-repo', icon: _GithubRepo()),
      (label: 'Pull Request', href: '#pull-request', icon: _PullRequest()),
      (label: 'Twitter', href: '#twitter', icon: _Twitter()),
    ];

    return aside(classes: 'sidebar', [
      div(classes: 'sidebar-content', [
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
      ]),
      svg(
        classes: 'sidebar-border-svg',
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
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.sidebar').styles(
      backgroundColor: const Color('var(--bg)'),
      display: .flex,
      flexDirection: .column,
      height: 100.vh,
      margin: .only(right: 200.rem),
      position: .fixed(left: 0.px, top: 0.px),
      width: 260.px,
      zIndex: ZIndex(101),
      raw: {
        'overflow': 'visible',
      },
    ),
    css('.sidebar-content').styles(
      display: .flex,
      flex: Flex(grow: 1),
      flexDirection: .column,
      height: 100.percent,
      padding: .symmetric(vertical: 2.rem, horizontal: 2.5.rem),
      raw: {
        'overflow-y': 'auto',
        'overflow-x': 'hidden',
        'scroll-behavior': 'smooth',
        'scrollbar-width': 'none', // Firefox
        '-ms-overflow-style': 'none', // IE/Edge
      },
    ),
    css('.sidebar-content::-webkit-scrollbar').styles(
      display: .none,
    ),
    css('.sidebar-border-svg').styles(
      height: 100.percent,
      position: Position.absolute(top: .zero, right: (-30).px),
      width: 60.px,
      raw: {
        'overflow': 'visible',
        'pointer-events': 'none',
        'z-index': '110',
      },
    ),
    css('.sidebar-profile').styles(
      margin: Spacing.only(bottom: 3.rem),
      textAlign: .center,
    ),
    css('.profile-img-box').styles(
      height: 90.px,
      margin: .symmetric(horizontal: .auto, vertical: .zero),
      padding: .all(5.px),
      width: 90.px,
      raw: {
        'background': 'var(--accent-dim)',
        'border': '2px solid var(--accent)',
        'border-radius': 'var(--chaos-radius-1)',
        'clip-path': 'var(--chaos-path-2)',
      },
    ),
    css('.profile-img-box img').styles(
      height: 100.percent,
      width: 100.percent,
      raw: {
        'border-radius': 'var(--chaos-radius-2)',
        'clip-path': 'var(--chaos-path-3)',
        'filter': 'grayscale(100%) contrast(1.1)',
        'object-fit': 'cover',
      },
    ),
    css('.profile-name').styles(
      color: const Color('var(--accent)'),
      fontSize: 1.3.rem,
      margin: Spacing.only(top: 1.2.rem, bottom: 0.3.rem),
    ),
    css('.profile-sub').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.85.rem,
    ),
    css('.sidebar-nav').styles(
      display: .flex,
      flex: Flex(grow: 1),
      flexDirection: .column,
      gap: Gap(row: 0.8.rem),
    ),
    css('.nav-item').styles(
      alignItems: .center,
      color: const Color('var(--text)'),
      display: .flex,
      gap: Gap(column: 1.rem),
      padding: .symmetric(horizontal: 1.rem, vertical: 0.8.rem),
      raw: {
        'border': '1px solid transparent',
        'transition': 'all 0.2s',
      },
    ),
    css('.nav-item:hover').styles(
      color: const Color('var(--accent)'),
      raw: {
        'background-color': 'var(--accent-dim)',
        'border': '1.5px solid var(--accent)',
        'border-radius': 'var(--chaos-radius-3)',
        'clip-path': 'var(--chaos-path-1)',
      },
    ),
    css('.nav-icon').styles(
      alignItems: .center,
      display: .flex,
      height: 24.px,
      justifyContent: .center,
      width: 24.px,
    ),
    css('.nav-icon svg').styles(
      height: 20.px,
      width: 20.px,
      raw: {'fill': 'none', 'stroke': 'currentColor'},
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
        'border-radius': 'var(--chaos-radius-2)',
        'clip-path': 'var(--chaos-path-3)',
      },
    ),
    css('.footer-quote').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.85.rem,
      fontStyle: .italic,
      lineHeight: 1.3.rem,
      textAlign: .center,
    ),
    css.media(MediaQuery.screen(maxWidth: 1024.px), [
      css('.sidebar').styles(display: .none),
    ]),
  ];
}

class _HomeIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) =>
      svg(attributes: {'viewBox': '0 0 24 24'}, [path(d: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z', [])]);
}

class _ProjectsIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(d: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z', []),
      path(d: 'M14 2v6h6', []),
      path(d: 'M16 13H8', []),
      path(d: 'M16 17H8', []),
      path(d: 'M10 9H8', []),
    ],
  );
}

class _ExpIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(d: 'M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z', []),
    ],
  );
}

class _SkillsIcon extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(d: 'M13 2L3 14h9l-1 8 10-12h-9l1-8z', []),
    ],
  );
}

class _PinnedRepo extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(
        d: 'M14 2l8 8-3 3-2-2-5 5v3l-2 2v-3l-5-5-2 2-3-3 8-8 3 3 5-5z',
        [],
      ),
    ],
  );
}

class _GithubRepo extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(
        d: 'M4 4h16v16H4z M8 8h8v2H8z M8 12h8v2H8z',
        [],
      ),
    ],
  );
}

class _PullRequest extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(
        d: 'M6 3a2 2 0 110 4 2 2 0 010-4zm0 14a2 2 0 110 4 2 2 0 010-4zm12-7a2 2 0 11-4 0 2 2 0 014 0zM6 7v10m0-10c6 0 6-4 8-4m-8 10c6 0 6 4 8 4',
        [],
      ),
    ],
  );
}

class _Twitter extends StatelessComponent {
  @override
  Component build(BuildContext context) => svg(
    attributes: {'viewBox': '0 0 24 24'},
    [
      path(
        d: 'M22 5.8c-.7.3-1.5.5-2.3.6.8-.5 1.4-1.2 1.7-2.1-.8.5-1.6.8-2.5 1-1.5-1.6-4-1.7-5.6-.2-1 .9-1.4 2.3-1 3.6-3.3-.2-6.4-1.7-8.4-4.2-1.1 1.9-.6 4.3 1.2 5.6-.6 0-1.2-.2-1.7-.5 0 2 1.4 3.8 3.4 4.2-.6.2-1.2.2-1.8.1.5 1.7 2.1 3 3.9 3-1.5 1.2-3.4 1.8-5.3 1.8H2c1.9 1.2 4.1 1.9 6.4 1.9 7.7 0 11.9-6.4 11.9-11.9v-.5c.8-.6 1.5-1.3 2-2.1z',
        [],
      ),
    ],
  );
}
