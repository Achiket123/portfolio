import 'dart:math' as math;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class SketchBox extends StatefulComponent {
  const SketchBox({
    required this.children,
    this.classes = '',
    this.id,
    this.padding = '2rem',
    this.strokeColor,
    super.key,
  });

  final List<Component> children;
  final String classes;
  final String? id;
  final String padding;
  final String? strokeColor;

  @override
  State<SketchBox> createState() => SketchBoxState();
}

class SketchBoxState extends State<SketchBox> {
  String _path1 = '';
  String _path2 = '';
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _generatePaths();
  }

  void _generatePaths() {
    // We'll use a fixed coordinate system for the SVG (e.g., 1000x1000)
    // and use preserveAspectRatio="none" to stretch it.
    final w = 1000.0;
    final h = 1000.0;
    _path1 = _createHandBox(w, h);
    _path2 = _createHandBox(w, h);
  }

  double _rand(double min, double max) {
    return _random.nextDouble() * (max - min) + min;
  }

  List<math.Point<double>> _wobblyLine(double x1, double y1, double x2, double y2, {int segments = 10}) {
    final points = <math.Point<double>>[];

    for (var i = 0; i <= segments; i++) {
      final t = i / segments;

      var x = x1 + (x2 - x1) * t;
      var y = y1 + (y2 - y1) * t;

      // Add stronger randomness (scaled to our 1000x1000 box)
      x += _rand(-15, 15);
      y += _rand(-15, 15);

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

    // Connect back to start for a closed loop
    final xc = (points.last.x + points.first.x) / 2;
    final yc = (points.last.y + points.first.y) / 2;
    d += ' Q ${points.last.x} ${points.last.y} $xc $yc';
    d += ' Q ${points.first.x} ${points.first.y} ${points[0].x} ${points[0].y}';
    
    return d;
  }

  String _createHandBox(double w, double h) {
    const margin = 15.0;

    final top = _wobblyLine(margin, margin, w - margin, margin, segments: 10);
    final right = _wobblyLine(w - margin, margin, w - margin, h - margin, segments: 10);
    final bottom = _wobblyLine(w - margin, h - margin, margin, h - margin, segments: 10);
    final left = _wobblyLine(margin, h - margin, margin, margin, segments: 10);

    final full = [...top, ...right, ...bottom, ...left];

    return _pointsToPath(full);
  }

  @override
  Component build(BuildContext context) {
    final stroke = component.strokeColor ?? 'var(--text)';

    return div(
      id: component.id,
      classes: 'sketch-box-container ${component.classes}',
      [
        svg(
          classes: 'sketch-svg',
          attributes: {
            'viewBox': '0 0 1000 1000',
            'preserveAspectRatio': 'none',
          },
          [
            path(
              d: _path1,
              attributes: {
                'stroke': stroke,
                'fill': 'none',
                'stroke-width': '2.5',
                'vector-effect': 'non-scaling-stroke',
              },
              [],
            ),
            path(
              d: _path2,
              attributes: {
                'stroke': stroke,
                'fill': 'none',
                'stroke-width': '1.5',
                'opacity': '0.5',
                'vector-effect': 'non-scaling-stroke',
              },
              [],
            ),
          ],
        ),
        div(
          classes: 'sketch-content',
          styles: Styles(
            raw: {'padding': component.padding},
          ),
          [...component.children],
        ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.sketch-box-container').styles(
      backgroundColor: const Color('var(--bg-card)'),
      display: .flex,
      flexDirection: .column,
      position: Position.relative(),
      raw: {
        'overflow': 'visible',
      },
    ),
    css('.sketch-svg').styles(
      position: Position.absolute(top: (-15).px, left: (-15).px),
      raw: {
        'width': 'calc(100% + 30px)',
        'height': 'calc(100% + 30px)',
        'pointer-events': 'none',
        'overflow': 'visible',
        'z-index': '10',
      },
    ),
    css('.sketch-content').styles(
      position: Position.relative(),
      zIndex: ZIndex(2),
    ),
  ];
}
