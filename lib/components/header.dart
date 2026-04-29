import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    final links = [
      (label: 'Home', href: '#home'),
      (label: 'Work', href: '#experience'),
      (label: 'Projects', href: '#projects'),
      (label: 'Skills', href: '#skills'),
      (label: 'Contact', href: '#contact'),
    ];

    return header(classes: 'top-nav', [
      div(classes: 'top-nav__inner', [
        a(href: '#home', classes: 'brand', [.text('Achiket Kumar')]),
        nav([
          ul([
            for (final link in links)
              li([
                a(href: link.href, [.text(link.label)]),
              ]),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.top-nav').styles(
      position: .sticky(top: 0.px),
      width: 100.percent,
      maxWidth: 1120.px,
      padding: .symmetric(horizontal: 1.5.rem, vertical: 1.rem),
      margin: .symmetric(horizontal: .auto),
    ),
    css('.top-nav__inner').styles(
      alignItems: .center,
      display: .flex,
      padding: .symmetric(horizontal: 1.7.rem, vertical: 0.9.rem),
      flexWrap: .wrap,
      backgroundColor: const Color('#0C141E'),
      justifyContent: .spaceBetween,
      border: Border.all(color: const Color('rgba(255,255,255,0.14)')),
      radius: .all(.circular(999.px)),
    ),
    css('.brand').styles(
      color: const Color('#F5F6FA'),
      fontWeight: .w700,
      textDecoration: TextDecoration(line: .none),
      letterSpacing: 0.4.px,
    ),
    css('.top-nav ul').styles(
      display: .flex,
      flexWrap: .wrap,
      justifyContent: .end,
      margin: .zero,
      padding: .zero,
    ),
    css('.top-nav li').styles(
      margin: .symmetric(horizontal: 1.4.rem, vertical: 0.25.rem),
    ),
    css('.top-nav a').styles(
      color: const Color('#D9E5FF'),
      textDecoration: TextDecoration(line: .none),
      fontSize: 0.95.rem,
    ),
    css('.top-nav a:hover').styles(color: Colors.white),
    css.media(MediaQuery.screen(maxWidth: 760.px), [
      css('.top-nav').styles(
        padding: .symmetric(horizontal: 0.7.rem, vertical: 0.7.rem),
      ),
      css('.top-nav__inner').styles(
        radius: .all(.circular(18.px)),
        justifyContent: .center,
      ),
      css('.brand').styles(width: 100.percent, textAlign: TextAlign.center),
      css('.top-nav nav').styles(width: 100.percent),
      css('.top-nav ul').styles(justifyContent: .center),
      css('.top-nav a').styles(fontSize: 0.9.rem),
    ]),
  ];
}
