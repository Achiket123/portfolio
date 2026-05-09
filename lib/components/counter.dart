import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
        alignItems: .center,
        border: Border.all(color: const Color('var(--border)'), width: 2.px),
        display: .flex,
        padding: .symmetric(vertical: 10.px),
        raw: {
          'border-radius': 'var(--chaos-radius-1)',
          'clip-path': 'var(--chaos-path-2)',
        },
      ),
      css('button', [
        css('&').styles(
          alignItems: .center,
          backgroundColor: Colors.transparent,
          border: Border.all(color: const Color('var(--accent)'), width: 2.px),
          color: const Color('var(--text)'),
          cursor: .pointer,
          display: .flex,
          fontSize: 2.rem,
          height: 2.em,
          justifyContent: .center,
          width: 2.em,
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
        boxSizing: .borderBox,
        color: const Color('var(--accent)'),
        fontSize: 4.rem,
        minWidth: 2.5.em,
        padding: .symmetric(horizontal: 2.rem),
        textAlign: .center,
      ),
    ]),
  ];
}
