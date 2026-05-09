library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  final assetManager = AssetManager(
    directory: 'web/assets',
  );

  ServerApp.addMiddleware(assetManager.middleware);

  runApp(
    Document(
      title: 'Achiket Kumar | Full Stack Developer',
      meta: {
        'viewport': 'width=device-width, initial-scale=1.0',
        'description': 'Full-stack engineer building digital blueprints from messy thoughts.',
      },
      head: [
        link(rel: 'apple-touch-icon', href: '/assets/favicon_io/apple-touch-icon.png', attributes: {'sizes': '180x180'}),
        link(rel: 'icon', type: 'image/png', href: '/assets/favicon_io/favicon-32x32.png', attributes: {'sizes': '32x32'}),
        link(rel: 'icon', type: 'image/png', href: '/assets/favicon_io/favicon-16x16.png', attributes: {'sizes': '16x16'}),
        link(rel: 'manifest', href: '/assets/favicon_io/site.webmanifest'),
      ],
      styles: [
        css.import(
          'https://fonts.googleapis.com/css2?family=Just+Another+Hand&family=Special+Elite&display=swap',
        ),
        css('html, body').styles(
          backgroundColor: const Color('var(--bg)'),
          color: const Color('var(--text)'),
          fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
          margin: .zero,
          minHeight: 100.vh,
          padding: .zero,
          width: 100.percent,
          raw: {
            'background-image': 'linear-gradient(var(--grid-color) 1px, transparent 1px), linear-gradient(90deg, var(--grid-color) 1px, transparent 1px)',
            'background-size': '40px 40px',
            'transition': 'background-color 0.3s ease, color 0.3s ease',
          },
        ),
        css('*, *::before, *::after').styles(
          boxSizing: BoxSizing.borderBox,
          margin: .zero,
          padding: .zero,
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
        css('h1, h2, h3, h4, h5').styles(
          fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
          fontWeight: .w400,
          margin: .zero,
        ),
        css('a').styles(
          color: const Color('var(--accent)'),
          textDecoration: TextDecoration(line: .none),
        ),
        css('ul').styles(
          listStyle: ListStyle.none,
          margin: .zero,
          padding: .zero,
        ),
        css('img').styles(
          raw: {'display': 'block'},
        ),
      ],
      body: const App(),
    ),
  );
}
