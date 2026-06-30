import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:http/http.dart' as http;
import 'package:portfolio/config.dart';

import '../models/blog_post.dart';
import '../components/sketch_box.dart';

class BlogList extends StatefulComponent {
  const BlogList({super.key});

  @override
  State<BlogList> createState() => BlogListState();
}

class BlogListState extends State<BlogList> {
  bool _loading = true;
  String? _error;
  List<BlogPostList> _posts = [];
  String _activeTag = 'all';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    try {
      final response = await http.get(Uri.parse(APIConfig.blogList)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("BODY : ${response.body}");
        final decoded = jsonDecode(response.body) as List;
        setState(() {
          _posts = decoded.map((e) => BlogPostList.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
        return;
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      _loading = false;
      _error = 'Could not load posts.';
    });
  }

  List<String> get _allTags {
    final tags = <String>{'all'};
    for (final post in _posts) {
      tags.addAll(post.tags);
    }
    return tags.toList();
  }

  List<BlogPostList> get _filtered {
    if (_activeTag == 'all') return _posts;
    return _posts.where((post) => post.tags.contains(_activeTag)).toList();
  }

  @override
  Component build(BuildContext context) {
    if (_loading) {
      return main_([
        section(classes: 'section loading-section', [
          p([.text('Loading posts...')]),
        ]),
      ]);
    }

    if (_error != null) {
      return main_([
        section(classes: 'section', [
          p([.text(_error!)]),
        ]),
      ]);
    }

    return main_([
      section(classes: 'section blog-list-section', [
        div(classes: 'blog-header', [
          h1(classes: 'blog-heading', [.text('WRITINGS_')]),
          p(classes: 'blog-subheading', [.text('Notes from building things.')]),
        ]),
        div(classes: 'blog-tag-filter', [
          for (final tag in _allTags)
            button(
              classes: 'tag-btn ${_activeTag == tag ? 'tag-btn-active' : ''}',
              onClick: () => setState(() => _activeTag = tag),
              [.text(tag.toUpperCase())],
            ),
        ]),
        if (_filtered.isEmpty)
          p(classes: 'blog-empty', [.text('No posts found.')])
        else
          div(classes: 'blog-grid', [
            for (final post in _filtered) _postCard(post),
          ]),
      ]),
    ]);
  }

  Component _postCard(BlogPostList post) {
    return SketchBox(
      classes: 'blog-card',
      padding: '1.5rem',
      children: [
        div(classes: 'blog-card-meta', [
          span(classes: 'blog-card-date', [.text(post.date)]),
          span(classes: 'blog-card-read', [.text('${post.readingTimeMinutes} min read')]),
        ]),
        a(href: '/blog-detail?slug=${post.slug}', classes: 'blog-card-title-link', [
          h2(classes: 'blog-card-title', [.text(post.title)]),
        ]),
        p(classes: 'blog-card-desc', [.text(post.description)]),
        div(classes: 'blog-card-tags', [
          for (final tag in post.tags) span(classes: 'blog-tag', [.text(tag)]),
        ]),
        a(href: '/blog-detail?slug=${post.slug}', classes: 'blog-card-link sketch-btn', [
          .text('Read post'),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.blog-list-section').styles(
      margin: .symmetric(horizontal: .auto),
      maxWidth: 900.px,
      padding: .symmetric(horizontal: 2.rem, vertical: 3.rem),
    ),
    css('.blog-header').styles(
      margin: Spacing.only(bottom: 2.rem),
    ),
    css('.blog-heading').styles(
      color: const Color('var(--accent)'),
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 3.5.rem,
      margin: Spacing.only(bottom: 0.5.rem),
    ),
    css('.blog-subheading').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 1.rem,
    ),
    css('.blog-tag-filter').styles(
      display: .flex,
      flexWrap: .wrap,
      gap: Gap(row: 0.5.rem, column: 0.5.rem),
      margin: Spacing.only(bottom: 2.5.rem),
    ),
    css('.tag-btn').styles(
      backgroundColor: Colors.transparent,
      border: Border.all(color: const Color('var(--border)'), width: 1.5.px),
      color: const Color('var(--text-muted)'),
      cursor: .pointer,
      fontSize: 0.75.rem,
      letterSpacing: 1.px,
      padding: .symmetric(horizontal: 0.75.rem, vertical: 0.35.rem),
      raw: {
        'border-radius': 'var(--chaos-radius-3)',
        'transition': 'all 0.2s',
      },
    ),
    css('.tag-btn:hover').styles(
      color: const Color('var(--accent)'),
      raw: {'border-color': 'var(--accent)'},
    ),
    css('.tag-btn-active').styles(
      color: const Color('var(--accent)'),
      raw: {
        'border-color': 'var(--accent)',
        'background': 'var(--accent-dim)',
      },
    ),
    css('.blog-grid').styles(
      display: .flex,
      flexDirection: .column,
      gap: Gap(column: 2.rem),
    ),
    css('.blog-card').styles(
      width: 100.percent,
    ),
    css('.blog-card-meta').styles(
      alignItems: .center,
      color: const Color('var(--text-muted)'),
      display: .flex,
      fontSize: 0.8.rem,
      gap: Gap(column: 1.rem),
      margin: Spacing.only(bottom: 0.75.rem),
    ),
    css('.blog-card-title-link').styles(
      color: const Color('var(--text)'),
    ),
    css('.blog-card-title').styles(
      fontFamily: const .list([FontFamily('Just Another Hand'), FontFamilies.cursive]),
      fontSize: 1.8.rem,
      margin: Spacing.only(bottom: 0.5.rem),
      raw: {'transition': 'color 0.2s'},
    ),
    css('.blog-card-title-link:hover .blog-card-title').styles(
      color: const Color('var(--accent)'),
    ),
    css('.blog-card-desc').styles(
      color: const Color('var(--text-muted)'),
      fontSize: 0.9.rem,
      lineHeight: (1.6).rem,
      margin: Spacing.only(bottom: 1.5.rem),
    ),
    css('.blog-card-tags').styles(
      display: .flex,
      flexWrap: .wrap,
      gap: Gap(column: 0.5.rem),
      margin: Spacing.only(bottom: 1.25.rem),
    ),
    css('.blog-tag').styles(
      border: Border.all(color: const Color('var(--border)'), width: 1.px),
      color: const Color('var(--accent)'),
      fontSize: 0.72.rem,
      letterSpacing: 0.5.px,
      padding: .symmetric(horizontal: 0.5.rem, vertical: 0.2.rem),
      raw: {'border-radius': 'var(--chaos-radius-3)'},
    ),
    css('.blog-card-link').styles(
      display: .inlineBlock,
      fontSize: 0.85.rem,
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
      },
    ),
    css('.sketch-btn:hover').styles(
      backgroundColor: const Color('var(--accent-dim)'),
      raw: {'transform': 'translate(-1px, -1px)'},
    ),
    css('.blog-empty').styles(
      color: const Color('var(--text-muted)'),
    ),
  ];
}
