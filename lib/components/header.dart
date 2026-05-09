import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Header extends StatefulComponent {
  const Header({super.key});

  @override
  State<Header> createState() => HeaderState();
}

class HeaderState extends State<Header> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Component build(BuildContext context) {
    final links = [
      (label: 'Projects', href: '/#projects'),
      (label: 'Experience', href: '/#experience'),
      (label: 'Skills', href: '/#skills'),
      (label: 'About', href: '/about'),
      (label: 'Blog', href: '/blog'),
    ];

    return header(
      classes: 'site-header',
      [
        div(classes: 'header-inner', [
          div(classes: 'header-left', [
            a(href: '/', classes: 'brand-box', [
              span(classes: 'brand-text', [.text('ACHIKET KUMAR')]),
            ]),
          ]),
          div(classes: 'header-right', [
            nav(classes: 'header-nav', [
              for (final link in links) a(href: link.href, classes: 'nav-link', [.text(link.label.toUpperCase())]),
            ]),
            // button(
            //   classes: 'theme-toggle',
            //   onClick: _toggleTheme,
            //   [
            //     span(classes: 'toggle-icon', [
            //       if (_isDark)
            //         svg(
            //           [
            //             path(
            //               d: 'M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m0-12.728l.707.707m11.314 11.314l.707.707M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z',
            //               [],
            //             ),
            //           ],
            //           attributes: {
            //             'viewBox': '0 0 24 24',
            //             'stroke': 'currentColor',
            //             'fill': 'none',
            //             'stroke-width': '2',
            //           },
            //         )
            //       else
            //         svg(
            //           [
            //             path(
            //               d: 'M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z',
            //               [],
            //             ),
            //           ],
            //           attributes: {
            //             'viewBox': '0 0 24 24',
            //             'stroke': 'currentColor',
            //             'fill': 'none',
            //             'stroke-width': '2',
            //           },
            //         ),
            //     ]),
            //   ],
            // ),
          ]),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.site-header').styles(
      backgroundColor: const Color('var(--bg)'),
      padding: .symmetric(horizontal: 2.rem, vertical: 1.5.rem),
      position: .sticky(top: 0.px),
      width: 100.percent,
      zIndex: ZIndex(100),
      raw: {
        'backdrop-filter': 'blur(8px)',
      },
    ),
    css.media(MediaQuery.screen(minWidth: 1025.px), [
      css('.site-header').styles(
        width: 100.percent,
      ),
    ]),
    css.media(MediaQuery.screen(minWidth: 1401.px), [
      css('.site-header').styles(
        width: 100.percent,
      ),
    ]),
    css('.header-inner').styles(
      alignItems: .center,
      display: .flex,
      justifyContent: .spaceBetween,
      margin: .symmetric(horizontal: .auto),
      maxWidth: 1400.px,
    ),
    css('.brand-box').styles(
      display: .inlineBlock,
      padding: .symmetric(horizontal: 1.rem, vertical: 0.5.rem),
      raw: {
        'border': '2px solid var(--accent)',
        'box-shadow': '4px 4px 0 var(--accent)',
        'clip-path': 'var(--chaos-path-1)',
        'transition': 'all 0.2s',
      },
    ),
    css('.brand-box:hover').styles(
      raw: {
        'box-shadow': '2px 2px 0 var(--accent)',
        'transform': 'translate(2px, 2px)',
      },
    ),
    css('.brand-text').styles(
      color: const Color('var(--accent)'),
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.8.rem,
      fontWeight: .w700,
      letterSpacing: 1.px,
    ),
    css('.header-right').styles(
      alignItems: .center,
      display: .flex,
      gap: Gap(column: 2.5.rem),
    ),
    css('.header-nav').styles(
      alignItems: .center,
      display: .flex,
      gap: Gap(column: 2.rem),
    ),
    css('.nav-link').styles(
      color: const Color('var(--text)'),
      fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
      fontSize: 0.9.rem,
      letterSpacing: 1.px,
      raw: {
        'transition': 'color 0.2s',
      },
    ),
    css('.nav-link:hover').styles(
      color: const Color('var(--accent)'),
    ),
    css('.theme-toggle').styles(
      alignItems: .center,
      backgroundColor: Colors.transparent,
      border: Border.all(color: const Color('var(--border)'), width: 2.px),
      cursor: .pointer,
      display: .flex,
      justifyContent: .center,
      padding: .all(0.6.rem),
      raw: {
        'transition': 'all 0.3s ease',
        'border-radius': 'var(--chaos-radius-3)',
        'clip-path': 'var(--chaos-path-2)',
        'color': 'var(--text)',
      },
    ),
    css('.theme-toggle:hover').styles(
      backgroundColor: const Color('var(--accent-dim)'),
      raw: {'transform': 'rotate(-5deg) scale(1.05)'},
    ),
    css('.toggle-icon').styles(
      alignItems: .center,
      display: .flex,
      height: 24.px,
      justifyContent: .center,
      width: 24.px,
    ),
    css('.toggle-icon svg').styles(
      height: 20.px,
      width: 20.px,
    ),
    css.media(MediaQuery.screen(maxWidth: 768.px), [
      css('.header-nav').styles(display: .none),
      css('.brand-text').styles(fontSize: 1.4.rem),
    ]),
  ];
}
