import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../models/portfolio_data.dart';
import 'sketch_box.dart';

class TwitterFeed extends StatelessComponent {
  final List<Tweet> tweets;

  const TwitterFeed({required this.tweets, super.key});
  @override
  Component build(BuildContext context) {
    if (tweets.isEmpty) return div([]);

    return section(id: 'twitter', classes: 'section', [
      div(classes: 'section-header', [
        span(classes: 'section-label', [.text('Recent Signals_')]),
        h2(classes: 'section-title', [.text('Twitter Feed')]),
      ]),
      div(classes: 'twitter-grid', [
        for (final tweet in tweets)
          SketchBox(
            classes: 'tweet-card',
            padding: '1.5rem',
            children: [
              p(classes: 'tweet-date', [.text(tweet.date)]),
              p(classes: 'tweet-text', [.text(tweet.text)]),
              if (tweet.images.isNotEmpty && tweet.images.first.isNotEmpty)
                div(classes: 'tweet-images', [
                  for (final imgUrl in tweet.images)
                    if (imgUrl.isNotEmpty) img(src: imgUrl, classes: 'tweet-image', alt: 'Tweet image'),
                ]),
              div(classes: 'tweet-footer', [
                a(
                  href: tweet.url,
                  target: Target.blank,
                  classes: 'tweet-link',
                  [.text('View Signal ->>')],
                ),
              ]),
            ],
          ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.twitter-grid').styles(
      display: .grid,
      gap: Gap(row: 2.rem, column: 2.rem),
      raw: {'grid-template-columns': 'repeat(auto-fill, minmax(300px, 1fr))'},
    ),
    css('.tweet-card').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 1.rem),
    ),
    css('.tweet-date').styles(
      color: const Color('var(--text-muted)'),
      fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
      fontSize: 0.8.rem,
    ),
    css('.tweet-text').styles(
      fontSize: 1.rem,
      lineHeight: 1.5.rem,
      raw: {'white-space': 'pre-wrap'},
    ),
    css('.tweet-images').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(row: 0.5.rem),
      margin: Spacing.only(top: 0.5.rem),
    ),
    css('.tweet-image').styles(
      radius: .all(Radius.circular(4.px)),
      width: 100.percent,
      raw: {
        'border': '1px solid var(--border)',
        'clip-path': 'var(--chaos-path-1)',
      },
    ),
    css('.tweet-footer').styles(
      margin: Spacing.only(top: .auto),
    ),
    css('.tweet-link').styles(
      color: const Color('var(--accent)'),
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.2.rem,
    ),
  ];
}
