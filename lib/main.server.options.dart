// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:portfolio/components/header.dart' as _header;
import 'package:portfolio/components/right_sidebar.dart' as _right_sidebar;
import 'package:portfolio/components/sidebar.dart' as _sidebar;
import 'package:portfolio/components/sketch_box.dart' as _sketch_box;
import 'package:portfolio/components/sketch_heatmap.dart' as _sketch_heatmap;
import 'package:portfolio/components/sketch_timeline.dart' as _sketch_timeline;
import 'package:portfolio/components/twitter_feed.dart' as _twitter_feed;
import 'package:portfolio/pages/about.dart' as _about;
import 'package:portfolio/pages/home.dart' as _home;
import 'package:portfolio/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {_app.App: ClientTarget<_app.App>('app')},
  styles: () => [
    ..._app.App.styles,
    ..._header.HeaderState.styles,
    ..._right_sidebar.RightSidebarState.styles,
    ..._sidebar.SidebarState.styles,
    ..._sketch_box.SketchBoxState.styles,
    ..._sketch_heatmap.SketchHeatmap.styles,
    ..._sketch_timeline.SketchTimelineState.styles,
    ..._twitter_feed.TwitterFeed.styles,
    ..._about.About.styles,
    ..._home.HomeState.styles,
  ],
);
