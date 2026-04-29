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
    directory: 'assets',
  );

   ServerApp.addMiddleware(assetManager.middleware);

  // runApp();

  runApp(
    Document(
      
      title: 'Achiket Kumar | Full Stack Developer',
      styles: [
        css.import(
          'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=Manrope:wght@400;600;700&display=swap',
        ),
        css('html, body').styles(
          width: 150.percent,
          minHeight: 100.vh,
          padding: .zero,
          backgroundColor: const Color('#060910'),
          fontFamily: const .list([FontFamily('Manrope'), FontFamilies.sansSerif]),
        ),
        css('h1, h2, h3, h4').styles(
          margin: .zero,
          fontFamily: const .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
        ),
        css('*').styles(boxSizing: BoxSizing.borderBox),
      ],
      body: const App(),
    ),
  );
}
