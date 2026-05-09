import 'dart:math' as math;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class SketchTimeline extends StatefulComponent {
  const SketchTimeline({required this.children, super.key});

  final List<Component> children;

  @override
  State<SketchTimeline> createState() => SketchTimelineState();
}

class SketchTimelineState extends State<SketchTimeline> {
  String _path = '';
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _generatePath();
  }

  void _generatePath() {
    // 100x1000 coordinate system for the vertical line
    final points = <math.Point<double>>[];
    const segments = 20;
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = 50.0 + (_random.nextDouble() * 10 - 5);
      final y = t * 1000.0;
      points.add(math.Point(x, y));
    }

    var d = 'M ${points[0].x} ${points[0].y}';
    for (var i = 1; i < points.length - 1; i++) {
      final xc = (points[i].x + points[i + 1].x) / 2;
      final yc = (points[i].y + points[i + 1].y) / 2;
      d += ' Q ${points[i].x} ${points[i].y} $xc $yc';
    }
    d += ' L ${points.last.x} ${points.last.y}';
    _path = d;
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'sketch-timeline-container', [
      svg(
        classes: 'sketch-timeline-svg',
        attributes: {
          'viewBox': '0 0 100 1000',
          'preserveAspectRatio': 'none',
        },
        [
          path(
            d: _path,
            attributes: {
              'stroke': 'var(--border)',
              'fill': 'none',
              'stroke-width': '2',
              'stroke-dasharray': '8 6',
              'vector-effect': 'non-scaling-stroke',
            },
            [],
          ),
        ],
      ),
      div(classes: 'sketch-timeline-content', [
        ...component.children,
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.sketch-timeline-container').styles(
      position: Position.relative(),
      padding: Spacing.only(left: 2.5.rem),
      margin: Spacing.only(left: 2.5.rem),
      raw: {'overflow': 'visible'},
    ),
    css('.sketch-timeline-svg').styles(
      position: Position.absolute(left: (-15).px, top: 0.px),
      width: 30.px,
      height: 100.percent,
      raw: {'pointer-events': 'none', 'overflow': 'visible', 'z-index': '1'},
    ),
  ];
}
