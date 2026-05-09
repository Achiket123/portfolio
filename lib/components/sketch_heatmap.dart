import 'dart:math' as math;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/portfolio_data.dart';

class SketchHeatmap extends StatelessComponent {
  final ContributionCalendar calendar;

  const SketchHeatmap({required this.calendar, super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'sketch-heatmap-container', [
      div(classes: 'heatmap-header', [
        h3(classes: 'heatmap-title', [.text('Contribution Heatmap')]),
        span(classes: 'heatmap-total', [.text('${calendar.totalContributions} contributions in the last year')]),
      ]),
      div(classes: 'heatmap-grid-wrapper', [
        div(classes: 'heatmap-grid', [
          for (var week in calendar.weeks)
            div(classes: 'heatmap-column', [
              for (var day in week.contributionDays) _HeatmapDay(day: day, maxCount: _findMaxCount()),
            ]),
        ]),
      ]),
      div(classes: 'heatmap-legend', [
        span([.text('Less')]),
        for (var i = 0; i <= 4; i++) _HeatmapLegendBox(level: i),
        span([.text('More')]),
      ]),
    ]);
  }

  int _findMaxCount() {
    int max = 1;
    for (var week in calendar.weeks) {
      for (var day in week.contributionDays) {
        if (day.contributionCount > max) {
          max = day.contributionCount;
        }
      }
    }
    return max;
  }

  @css
  static List<StyleRule> get styles => [
    css('.sketch-heatmap-container').styles(
      margin: .symmetric(vertical: 2.rem),
      padding: .all(1.5.rem),
      backgroundColor: const Color('var(--bg-card)'),
      raw: {
        'border': '2px solid var(--border)',
        'border-radius': 'var(--chaos-radius-2)',
      },
    ),
    css('.heatmap-header').styles(
      display: .flex,
      justifyContent: .spaceBetween,
      alignItems: .baseline,
      margin: Spacing.only(bottom: 1.rem),
      flexWrap: .wrap,
    ),
    css('.heatmap-total').styles(
      fontSize: 0.9.rem,
      color: const Color('var(--text-muted)'),
      fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
    ),
    css('.heatmap-title').styles(
      fontSize: 1.8.rem,
    ),
    css('.heatmap-grid-wrapper').styles(
      raw: {
        'overflow-x': 'auto',
        'padding-bottom': '1rem',
      },
    ),
    css('.heatmap-grid').styles(
      display: .flex,
      gap: Gap(column: 4.px),
    ),
    css('.heatmap-column').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 4.px),
    ),
    css('.heatmap-legend').styles(
      display: .flex,
      alignItems: .center,
      justifyContent: .end,
      gap: Gap(column: 8.px),
      margin: Spacing.only(top: 1.rem),
      fontSize: 0.8.rem,
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
    ),
    css('.heatmap-day').styles(
      width: 14.px,
      height: 14.px,
      cursor: .pointer,
    ),
    css('.heatmap-day:hover path').styles(
      raw: {'stroke': 'var(--accent)', 'stroke-width': '4'},
    ),
    css('.legend-box').styles(
      width: 12.px,
      height: 12.px,
    ),
  ];
}

class _HeatmapDay extends StatefulComponent {
  final ContributionDay day;
  final int maxCount;

  const _HeatmapDay({required this.day, required this.maxCount});

  @override
  State<_HeatmapDay> createState() => _HeatmapDayState();
}

class _HeatmapDayState extends State<_HeatmapDay> {
  String _path = '';
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _path = _generateWobblySquare(100, 100);
  }

  String _generateWobblySquare(double w, double h) {
    const margin = 5.0;
    final points = <math.Point<double>>[];

    // Top
    for (var i = 0; i <= 4; i++) {
      points.add(math.Point(margin + (w - 2 * margin) * i / 4 + _rand(-3, 3), margin + _rand(-3, 3)));
    }
    // Right
    for (var i = 1; i <= 4; i++) {
      points.add(math.Point(w - margin + _rand(-3, 3), margin + (h - 2 * margin) * i / 4 + _rand(-3, 3)));
    }
    // Bottom
    for (var i = 3; i >= 0; i--) {
      points.add(math.Point(margin + (w - 2 * margin) * i / 4 + _rand(-3, 3), h - margin + _rand(-3, 3)));
    }
    // Left
    for (var i = 3; i >= 1; i--) {
      points.add(math.Point(margin + _rand(-3, 3), margin + (h - 2 * margin) * i / 4 + _rand(-3, 3)));
    }

    var d = 'M ${points[0].x} ${points[0].y}';
    for (var i = 1; i < points.length; i++) {
      final xc = (points[i - 1].x + points[i].x) / 2;
      final yc = (points[i - 1].y + points[i].y) / 2;
      d += ' Q ${points[i - 1].x} ${points[i - 1].y} $xc $yc';
    }
    d += ' Z';
    return d;
  }

  double _rand(double min, double max) {
    return _random.nextDouble() * (max - min) + min;
  }

  String _getColor() {
    final int count = component.day.contributionCount;

    // Level 0 (no activity)
    if (count == 0) return '#898989';

    final double ratio = component.day.contributionCount / component.maxCount;

    // Map ratio → levels (same as switch)
    if (ratio < 0.25) return '#4d4d4d'; // level 1
    if (ratio < 0.5) return '#999999'; // level 2
    if (ratio < 0.75) return '#111111'; // level 3
    return '#e6e6e6'; // level 4
  }

  @override
  Component build(BuildContext context) {
    final color = _getColor();

    return div(
      classes: 'heatmap-day',
      attributes: {'title': '${component.day.contributionCount} contributions on ${component.day.date}'},
      [
        svg(
          attributes: {
            'viewBox': '0 0 100 100',
            'width': '14',
            'height': '14',
          },
          [
            path(
              d: _path,
              attributes: {
                'fill': color,
                'stroke': 'var(--border)',
                'stroke-width': '2',
              },
              [],
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatmapLegendBox extends StatelessComponent {
  final int level;
  const _HeatmapLegendBox({required this.level});

  @override
  Component build(BuildContext context) {
    String color;
    switch (level) {
      case 0:
        color = '#898989';
        break; // dark grey (no black)
      case 1:
        color = '#737373';
        break;
      case 2:
        color = '#999999';
        break;
      case 3:
        color = '#bfbfbf';
        break;
      case 4:
        color = '#e6e6e6';
        break; // near white
      default:
        color = '#4d4d4d';
    }

    return div(classes: 'legend-box', [
      svg(
        attributes: {
          'viewBox': '0 0 100 100',
          'width': '12',
          'height': '12',
        },
        [
          path(
            d: 'M 10 10 Q 50 5 90 10 Q 95 50 90 90 Q 50 95 10 90 Q 5 50 10 10 Z', // Fixed wobbly square for legend
            attributes: {
              'fill': color,
              'stroke': 'var(--border)',
              'stroke-width': '4',
            },
            [],
          ),
        ],
      ),
    ]);
  }
}
