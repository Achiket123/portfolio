import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'components/sidebar.dart';
import 'components/right_sidebar.dart';
import 'pages/about.dart';
import 'pages/home.dart';

@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'app-root', [
      const Sidebar(),
      div(classes: 'app-main', [
        const Header(),
        div(classes: 'app-content-layout', [
          div(classes: 'app-page-area', [
            Router(
              routes: [
                Route(path: '/', builder: (context, state) => const Home()),
                Route(path: '/about', builder: (context, state) => const About()),
              ],
            ),
          ]),
        ]),
      ]),
      const RightSidebar(),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css.import(
      'https://fonts.googleapis.com/css2?family=Just+Another+Hand&family=Special+Elite&display=swap',
    ),
    css(':root').styles(
      raw: {
        '--bg': '#FFFFFF',
        '--bg-card': '#FFFFFF',
        '--text': '#000000',
        '--text-muted': '#333333',
        '--accent': '#000000',
        '--accent-dim': 'rgba(0,0,0,0.05)',
        '--border': '#000000',
        '--grid-color': 'rgba(0,0,0,0.05)',
        '--chaos-radius-1': '255px 15px 225px 15px / 15px 225px 15px 255px',
        '--chaos-radius-2': '15px 225px 15px 255px / 255px 15px 225px 15px',
        '--chaos-radius-3': '4% 95% 6% 95% / 95% 4% 92% 5%',
        '--chaos-path-1': 'polygon(2% 2%, 98% 4%, 99% 98%, 4% 96%)',
        '--chaos-path-2': 'polygon(1% 5%, 95% 2%, 98% 94%, 5% 92%)',
        '--chaos-path-3': 'polygon(4% 1%, 99% 3%, 96% 99%, 1% 97%)',
        '--messy-lines': '1.5px 2px 0px 0px var(--border), -1.5px -1.5px 0px 0px var(--border), 2px -1px 0px 0px var(--border)',
      },
    ),
    css('body.dark').styles(
      raw: {
        '--bg': '#0D0D0D',
        '--bg-card': '#141414',
        '--text': '#F0F0F0',
        '--text-muted': '#888888',
        '--accent': '#39FF14',
        '--accent-dim': 'rgba(57,255,20,0.15)',
        '--border': 'rgba(255,255,255,0.4)',
        '--grid-color': 'rgba(57,255,20,0.03)',
      },
    ),
    css('html, body').styles(
      backgroundColor: const Color('var(--bg)'),
      color: const Color('var(--text)'),
      fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
      raw: {
        'transition': 'background-color 0.3s ease, color 0.3s ease',
        'scrollbar-width': 'none',
        '-ms-overflow-style': 'none',
      },
    ),
    css('body::-webkit-scrollbar').styles(
      display: .none,
    ),
    css('h1, h2, h3, h4, h5').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontWeight: .w400,
      lineHeight: 1.1.rem,
    ),
    css('a').styles(
      color: const Color('var(--accent)'),
      textDecoration: TextDecoration(line: .none),
    ),
    css('.app-root').styles(
      minHeight: 100.vh,
      backgroundColor: const Color('var(--bg)'),
      color: const Color('var(--text)'),
      display: .flex,
      raw: {
        'transition': 'background-color 0.3s ease, color 0.3s ease',
      },
    ),
    css('.app-main').styles(
      flex: Flex(grow: 1),
      margin: Spacing.only(left: 260.px, right: 260.px),
      minHeight: 100.vh,
      display: .flex,
      flexDirection: .column,
      raw: {
        'overflow-x': 'hidden',
      },
    ),
    css('.app-content-layout').styles(
      display: .flex,
      flex: Flex(grow: 1),
      position: Position.relative(),
    ),
    css('.app-page-area').styles(
      flex: Flex(grow: 1),
      minWidth: 0.px,
      raw: {
        'max-width': '1400px',
        'margin': '0 auto',
      },
    ),
    css.media(MediaQuery.screen(maxWidth: 1024.px), [
      css('.app-main').styles(margin: Spacing.only(left: .zero, right: .zero)),
    ]),
  ];
}
