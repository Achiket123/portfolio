import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'section about-section', [
      div(classes: 'section-header', [
        span(classes: 'section-label', [.text('Behind the Sketch_')]),
        h2(classes: 'section-title', [.text('About Jaspr & This Portfolio')]),
      ]),
      div(classes: 'about-grid', [
        div(classes: 'sketch-card', [
          ol(classes: 'about-list', [
            li([
              h3([.text('DOCUMENTATION_')]),
              p([
                .text('Jaspr\'s '),
                a(href: 'https://docs.jaspr.site', [.text('official documentation')]),
                .text(' provides you with all information you need to get started.'),
              ]),
            ]),
            li([
              h3([.text('COMMUNITY_')]),
              p([
                .text('Got stuck? Ask your question on the official '),
                a(href: 'https://discord.gg/XGXrGEk4c6', [.text('Discord server')]),
                .text(' for the Jaspr community.'),
              ]),
            ]),
            li([
              h3([.text('ECOSYSTEM_')]),
              p([
                .text(
                    'Get official packages and integrations for your project like jaspr_router, jaspr_tailwind or jaspr_riverpod.'),
              ]),
            ]),
          ]),
        ]),
        div(classes: 'sketch-card availability-card', [
          h3([.text('Experimental Build')]),
          p([
            .text(
                'This portfolio is a live experiment in "Sketched UI" — combining hand-drawn aesthetics with the power of Dart & Jaspr.'),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.about-section').styles(
      margin: .symmetric(horizontal: .auto),
      maxWidth: 1120.px,
      padding: .symmetric(horizontal: 2.rem, vertical: 4.rem),
    ),
    css('.about-grid').styles(
      display: .grid,
      gap: Gap(row: 2.rem, column: 2.rem),
      raw: {'grid-template-columns': 'repeat(auto-fit, minmax(300px, 1fr))'},
    ),
    css('.about-list').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 1.5.rem),
    ),
    css('.about-list h3').styles(
      color: const Color('var(--accent)'),
      fontSize: 1.5.rem,
      margin: Spacing.only(bottom: 0.5.rem),
    ),
    css('.about-list p').styles(
      color: const Color('var(--text-muted)'),
      lineHeight: 1.5.rem,
    ),
    css('.sketch-card').styles(
      backgroundColor: const Color('var(--bg-card)'),
      padding: .all(2.rem),
      raw: {
        'border': '1.5px solid var(--border)',
        'clip-path': 'var(--chaos-path-3)',
        'border-radius': 'var(--chaos-radius-1)',
      },
    ),
    css('.availability-card').styles(
      backgroundColor: const Color('var(--accent)'),
      color: const Color('var(--bg)'),
      raw: {
        'border': '2px solid var(--border)',
        'clip-path': 'var(--chaos-path-1)',
        'border-radius': 'var(--chaos-radius-2)',
      },
    ),
    css('.availability-card h3').styles(color: const Color('var(--bg)')),
    css('.availability-card p').styles(color: const Color('var(--bg)')),
  ];
}
