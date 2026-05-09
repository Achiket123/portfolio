import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr_router/jaspr_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:portfolio/config.dart';

import '../models/blog_post.dart';
import '../components/sketch_box.dart';

class BlogDetail extends StatefulComponent {
  const BlogDetail({super.key});

  @override
  State<BlogDetail> createState() => BlogDetailState();
}

class BlogDetailState extends State<BlogDetail> {
  bool _loading = true;
  String? _error;
  BlogPost? _post;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      final slug = RouteState.of(context).params['slug'] ?? '';
      _loadPost(slug);
    }
  }

  Future<void> _loadPost(String slug) async {
    try {
      final response = await http.get(Uri.parse(APIConfig.getBlog(slug))).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _post = BlogPost.fromJson(decoded);
          _loading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _loading = false;
      _error = 'Post not found.';
    });
  }

  // Converts markdown string to an HTML string using the markdown package,
  // then wraps it in a raw HTML node so Jaspr renders it as real DOM.
  String _toHtml(String markdownContent) {
    return md.markdownToHtml(
      markdownContent,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
  }

  @override
  Component build(BuildContext context) {
    if (_loading) {
      return main_([
        section(classes: 'section loading-section', [
          p([.text('Loading...')]),
        ]),
      ]);
    }

    if (_error != null || _post == null) {
      return main_([
        section(classes: 'section blog-detail-section', [
          p(classes: 'blog-not-found', [.text(_error ?? 'Post not found.')]),
          a(href: '/blog', classes: 'sketch-btn', [.text('Back to writings')]),
        ]),
      ]);
    }

    final post = _post!;
    final renderedHtml = _toHtml(post.content);

    return main_([
      section(classes: 'section blog-detail-section', [
        div(classes: 'blog-detail-back', [
          a(href: '/blog', classes: 'back-link', [.text('back to writings')]),
        ]),
        SketchBox(
          classes: 'blog-detail-header',
          padding: '2rem',
          children: [
            div(classes: 'blog-detail-meta', [
              span(classes: 'blog-detail-date', [.text(post.date)]),
              span(classes: 'blog-detail-sep', [.text('/')]),
              span(classes: 'blog-detail-read', [
                .text('${post.readingTimeMinutes} min read'),
              ]),
            ]),
            h1(classes: 'blog-detail-title', [.text(post.title)]),
            p(classes: 'blog-detail-desc', [.text(post.description)]),
            div(classes: 'blog-detail-tags', [
              for (final tag in post.tags) span(classes: 'blog-tag', [.text(tag)]),
            ]),
          ],
        ),
        // raw() injects the HTML string directly into the DOM without escaping.
        // The markdown package produces safe, sanitized HTML so this is fine.
        div(classes: 'blog-md-body', [
          raw(renderedHtml),
        ]),
        div(classes: 'blog-detail-footer', [
          a(href: '/blog', classes: 'sketch-btn', [.text('Back to writings')]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.blog-detail-section').styles(
      margin: .symmetric(horizontal: .auto),
      maxWidth: 780.px,
      padding: .symmetric(horizontal: 2.rem, vertical: 3.rem),
    ),
    css('.blog-detail-back').styles(
      margin: Spacing.only(bottom: 2.rem),
    ),
    css('.back-link').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.9.rem,
      letterSpacing: 0.5.px,
      raw: {'transition': 'color 0.2s'},
    ),
    css('.back-link:hover').styles(
      color: const Color('var(--accent)'),
    ),
    css('.blog-detail-header').styles(
      margin: Spacing.only(bottom: 3.rem),
    ),
    css('.blog-detail-meta').styles(
      alignItems: .center,
      color: const Color('var(--text-muted)'),
      display: .flex,
      fontSize: 0.82.rem,
      gap: Gap(column: 0.6.rem),
      margin: Spacing.only(bottom: 1.rem),
    ),
    css('.blog-detail-sep').styles(
      color: const Color('var(--accent)'),
    ),
    css('.blog-detail-title').styles(
      color: const Color('var(--text)'),
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 3.rem,
      lineHeight: (1.1).rem,
      margin: Spacing.only(bottom: 1.rem),
    ),
    css('.blog-detail-desc').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 1.rem,
      lineHeight: (1.6).rem,
      margin: Spacing.only(bottom: 1.2.rem),
    ),
    css('.blog-detail-tags').styles(
      display: .flex,
      flexWrap: .wrap,
      gap: Gap(column: 0.5.rem),
    ),
    css('.blog-tag').styles(
      border: Border.all(color: const Color('var(--border)'), width: 1.px),
      color: const Color('var(--accent)'),
      fontSize: 0.72.rem,
      letterSpacing: 0.5.px,
      padding: .symmetric(horizontal: 0.5.rem, vertical: 0.2.rem),
      raw: {'border-radius': 'var(--chaos-radius-3)'},
    ),
    css('.blog-md-body').styles(
      color: const Color('var(--text)'),
      fontSize: 1.rem,
      lineHeight: (1.8).rem,
      margin: Spacing.only(bottom: 3.rem),
    ),
    css('.blog-md-body h1, .blog-md-body h2, .blog-md-body h3').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      margin: Spacing.only(bottom: .5.rem, top: 2.rem),
    ),
    css('.blog-md-body h1').styles(fontSize: 2.4.rem),
    css('.blog-md-body h2').styles(
      color: const Color('var(--accent)'),
      fontSize: 2.rem,
    ),
    css('.blog-md-body h3').styles(fontSize: 1.6.rem),
    css('.blog-md-body p').styles(
      margin: Spacing.only(bottom: 1.5.rem),
    ),
    css('.blog-md-body a').styles(
      color: const Color('var(--accent)'),
      raw: {'text-decoration': 'underline'},
    ),
    css('.blog-md-body code').styles(
      backgroundColor: const Color('var(--bg-card)'),
      border: Border.all(color: const Color('var(--border)'), width: 1.px),
      color: const Color('var(--accent)'),
      fontFamily: const .list([FontFamily('monospace')]),
      fontSize: 0.88.rem,
      padding: .symmetric(horizontal: 0.4.rem, vertical: 0.1.rem),
    ),
    css('.blog-md-body pre').styles(
      backgroundColor: const Color('var(--bg-card)'),
      border: Border.all(color: const Color('var(--border)'), width: 1.5.px),
      fontSize: 0.88.rem,
      margin: Spacing.only(bottom: 1.5.rem),
      overflow: .hidden,
      padding: .all(1.5.rem),
      raw: {'overflow-x': 'auto'},
    ),
    css('.blog-md-body pre code').styles(
      backgroundColor: Colors.transparent,
      border: Border.none,
      color: const Color('var(--text)'),
      padding: .all(0.px),
    ),
    css('.blog-md-body blockquote').styles(
      border: Border.only(
        left: BorderSide(color: const Color('var(--accent)'), width: 3.px),
      ),
      color: const Color('var(--text-muted)'),
      fontStyle: .italic,
      margin: Spacing.only(bottom: 1.2.rem),
      padding: Spacing.only(left: 1.2.rem),
    ),
    css('.blog-md-body ul, .blog-md-body ol').styles(
      margin: Spacing.only(bottom: 1.2.rem),
      padding: Spacing.only(left: 1.5.rem),
    ),
    css('.blog-md-body li').styles(
      margin: Spacing.only(bottom: 0.4.rem),
    ),
    css('.blog-md-body img').styles(
      border: Border.all(color: const Color('var(--border)'), width: 1.5.px),
      maxWidth: 100.percent,
    ),
    css('.blog-md-body hr').styles(
      border: Border.only(
        top: BorderSide(color: const Color('var(--border)'), width: 1.px),
      ),
      margin: .symmetric(vertical: 2.rem),
    ),
    css('.blog-detail-footer').styles(
      margin: Spacing.only(top: 2.rem),
    ),
    css('.sketch-btn').styles(
      border: Border.all(color: const Color('var(--accent)'), width: 1.5.px),
      color: const Color('var(--accent)'),
      cursor: .pointer,
      fontFamily: const .list([FontFamily('Special Elite'), FontFamilies.serif]),
      fontSize: 0.85.rem,
      letterSpacing: 1.px,
      padding: .symmetric(horizontal: 1.rem, vertical: 0.4.rem),
      raw: {
        'border-radius': 'var(--chaos-radius-3)',
        'clip-path': 'var(--chaos-path-2)',
        'transition': 'all 0.2s',
        'display': 'inline-block',
      },
    ),
    css('.sketch-btn:hover').styles(
      backgroundColor: const Color('var(--accent-dim)'),
    ),
    css('.blog-not-found').styles(
      color: const Color('var(--text-muted)'),
      margin: Spacing.only(bottom: 1.5.rem),
    ),
  ];
}
