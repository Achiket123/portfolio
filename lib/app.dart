import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'components/header.dart';
import 'pages/home.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      const Header(),
      const Home(),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.main').styles(
      minHeight: 100.vh,
      color: const Color('#F4F7FF'),
      backgroundColor: const Color('#0A1120'),
    ),
  ];
}
