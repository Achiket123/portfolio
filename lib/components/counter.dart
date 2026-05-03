import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return div([
      div(classes: 'counter', [
        button(
          onClick: () {
            setState(() => count--);
          },
          [.text('-')],
        ),
        span([.text('$count')]),
        button(
          onClick: () {
            setState(() => count++);
          },
          [.text('+')],
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.counter', [
      css('&').styles(
        display: .flex,
        padding: .symmetric(vertical: 10.px),
        border: Border.all(color: const Color('var(--border)'), width: 2.px),
        alignItems: .center,
        raw: {
          'border-radius': 'var(--chaos-radius-1)',
          'clip-path': 'var(--chaos-path-2)',
        },
      ),
      css('button', [
        css('&').styles(
          display: .flex,
          width: 2.em,
          height: 2.em,
          border: Border.all(color: const Color('var(--accent)'), width: 2.px),
          cursor: .pointer,
          justifyContent: .center,
          alignItems: .center,
          fontSize: 2.rem,
          backgroundColor: Colors.transparent,
          color: const Color('var(--text)'),
          raw: {
            'border-radius': 'var(--chaos-radius-3)',
            'clip-path': 'var(--chaos-path-1)',
            'transition': 'all 0.2s',
          },
        ),
        css('&:hover').styles(
          backgroundColor: const Color('var(--accent-dim)'),
          raw: {'transform': 'scale(1.1) rotate(5deg)'},
        ),
      ]),
      css('span').styles(
        minWidth: 2.5.em,
        padding: .symmetric(horizontal: 2.rem),
        boxSizing: .borderBox,
        color: const Color('var(--accent)'),
        textAlign: .center,
        fontSize: 4.rem,
      ),
    ]),
  ];
}
